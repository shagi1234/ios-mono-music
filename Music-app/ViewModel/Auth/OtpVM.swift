//
//  OtpVM.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 15.08.2023.
//

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
    
    func verify(otp: String){
        inProgress = true
        timer?.invalidate()
        timer = nil
        
        authRepo.checkOtp( otp: otp) { [weak self] resp in
            self?.inProgress = false
            self?.startTimer()
            print(Defaults.phone)
            switch resp {
            case .success(let val):
                Defaults.token = "Bearer " + val.access
                Defaults.refreshToken = val.refresh
                Defaults.subsEndDate = val.user.subscriptionEndDate ?? ""
                Defaults.subsType = val.user.subscription?.name ?? ""
                self?.loggedFirstTime = val.loggedFirstTime ?? false
                self?.success = true
            case .failure(let error):
                if self?.otpText.isEmpty ?? true {
                    self?.failMessage = "empty_otp"
                } else{
                    self?.failMessage = "failMessage"
                }
                debugPrint(error)
            }
        }
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
