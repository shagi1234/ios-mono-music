import Foundation
import Resolver
import Alamofire

class OtpVM: ObservableObject {
    @Injected var authRepo : AuthRepo
    @Published var inProgress = false
    @Published var success = false
    @Published var timeRemaining = 59
    @Published var loggedFirstTime: Bool = false
    @Published var token: String = ""
    @Published var refreshToken: String = ""
    @Published var failMessage : String?
    @Published var otpText = ""
    var timer: Timer?
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    func verify(otp: String) {
        inProgress = true
        timer?.invalidate()
        timer = nil
        
        authRepo.checkOtp(otp: otp) { [weak self] resp in
            guard let self = self else { return }

            switch resp {
            case .success(let val):
                DispatchQueue.main.async {
                    Defaults.token = "Bearer " + val.access
                    Defaults.refreshToken = val.refresh

                    let subsEndDate = val.user.subscriptionEndDate ?? ""
                    Defaults.subsEndDate = subsEndDate
                    Defaults.subsType = val.user.subscription?.name ?? ""

                    let hasExpired = self.checkIfSubscriptionExpired(endDateString: subsEndDate)
                    Defaults.subsHasEnded = hasExpired

                    let isFirstTime = val.loggedFirstTime ?? false
                    Defaults.loggedFirstTime = isFirstTime
                    self.loggedFirstTime = isFirstTime

                    Defaults.logged = true
                    UserDefaults.standard.synchronize()

                    self.success = true

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        NotificationCenter.default.post(name: NSNotification.Name("ClearAuthNavigation"), object: nil)
                        self.inProgress = false
                        self.timer?.invalidate()
                        self.timer = nil
                        self.endBackgroundTask()
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.inProgress = false
                    self.startTimer()

                    if self.otpText.isEmpty {
                        self.failMessage = "empty_otp"
                    } else {
                        self.failMessage = "failMessage"
                    }
                }
                debugPrint(error)
            }
        }
    }
    
    private func checkIfSubscriptionExpired(endDateString: String) -> Bool {
        guard !endDateString.isEmpty else {
            return false
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current

        guard let endDate = dateFormatter.date(from: endDateString) else {
            return false
        }

        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current

        guard let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) else {
            return false
        }

        let currentDate = Date()
        let hasExpired = currentDate > endOfDay

        return hasExpired
    }
    
    func retry(){
        inProgress = true
        
        authRepo.sendOtp(phone: Defaults.phone) { [weak self] resp in
            self?.inProgress = false
            
            switch resp {
            case .success(_):
                self?.resetTimer()
                
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
    
    func startTimer(){
        beginBackgroundTask()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
    }
    
    @objc func tick(){
        if(timeRemaining > 0){
            timeRemaining -= 1
        } else {
            timer?.invalidate()
            endBackgroundTask()
        }
    }
    
    func resetTimer() {
        timer?.invalidate()
        timeRemaining = 59
        startTimer()
    }
    
    func beginBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "OtpTimer") {
            self.endBackgroundTask()
        }
    }
    
    func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
}
