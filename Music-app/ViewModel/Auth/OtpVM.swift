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
            
            print("📱 Phone: \(Defaults.phone)")
            
            switch resp {
            case .success(let val):
                DispatchQueue.main.async {
                    print("✅ OTP Verification Success")
                    
                    Defaults.token = "Bearer " + val.access
                    Defaults.refreshToken = val.refresh
                    
                    let subsEndDate = val.user.subscriptionEndDate ?? ""
                    Defaults.subsEndDate = subsEndDate
                    Defaults.subsType = val.user.subscription?.name ?? ""
                    
                    print("📅 Subscription End Date: \(subsEndDate)")
                    print("📅 Subscription Type: \(val.user.subscription?.name ?? "none")")
                    
                    let hasExpired = self.checkIfSubscriptionExpired(endDateString: subsEndDate)
                    Defaults.subsHasEnded = hasExpired
                    
                    print("   - Subscription Status: \(hasExpired ? "EXPIRED" : "ACTIVE")")
                    
                    let isFirstTime = val.loggedFirstTime ?? false
                    Defaults.loggedFirstTime = isFirstTime
                    self.loggedFirstTime = isFirstTime
                    self.success = true
                    
                    print("   - First Time Login: \(isFirstTime)")
                    
                    UserDefaults.standard.synchronize()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        NotificationCenter.default.post(name: NSNotification.Name("ClearAuthNavigation"), object: nil)
                        self.inProgress = false
                        self.timer?.invalidate()
                        self.timer = nil
                        self.endBackgroundTask()
                        
                        Defaults.logged = true
                        
                        UserDefaults.standard.synchronize()
                    }
                }
            case .failure(let error):
                print("❌ API Error: \(error)")
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
            print("⚠️ No subscription end date provided")
            return false
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current
        
        guard let endDate = dateFormatter.date(from: endDateString) else {
            print("❌ Failed to parse date: \(endDateString)")
            return false
        }
        
        // Set to end of day (23:59:59)
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        
        guard let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) else {
            return false
        }
        
        let currentDate = Date()
        let hasExpired = currentDate > endOfDay
        
        print("📅 Subscription Check During Login:")
        print("   - End Date: \(endDateString)")
        print("   - End of Day: \(endOfDay)")
        print("   - Current: \(currentDate)")
        print("   - Expired: \(hasExpired)")
        
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
