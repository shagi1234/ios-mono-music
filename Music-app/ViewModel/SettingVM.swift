//
//  SettingVM.swift
//  Music-app
//
//  Created by SURAY on 19.04.2024.
//

import Foundation
import Resolver

class SettingVM: ObservableObject{
    @Injected var repo : HomeRepo
    @Published var profile : LoggedUserModel?
    @Published var inProgress: Bool = false
    @Published var noConnection: Bool = false
    @Published var promoCode: String = ""
    @Published var message: String = ""
    @Published var isEditing: Bool = false
    @Published var inProgressSubscriptions: Bool = false
    @Published var subsciptions = [SubscriptionModel]()
    @Published var registerPayment: RegisterPaymentModel?
    @Published var showPopup: Bool = false
    @Published var showWebview: Bool = false
    @Published var selectedId: Int64?
    @Published var succesOpenBank: Bool = true
    @Published var error: Bool = false
    @Published var payMeth = [PaymentMethod]()
    @Published var contactUsProgress: Bool = false
    @Published var contactSuccess: Bool = false
    @Published var contactError: Bool = false
    @Published var promoProgress: Bool = false
    @Published var promoMessage: String = ""
    @Published var promoError: Bool = false

    func getProfile(){
        inProgress = true
        noConnection = false
        
        repo.getProfile() { [weak self] resp in
            self?.inProgress.toggle()
            
            switch resp {
            case .success(let success):
                self?.inProgress = false
                self?.profile = success
                Defaults.fullName = success.fullName
                Defaults.birthDay = success.birthDay
                Defaults.subsEndDate = success.subscriptionEndDate
                Defaults.subsType = success.subscription?.name ?? ""
            case .failure(_):
                self?.noConnection = true
            }
        }
    }
    
    func getSubscribtions(){
        inProgressSubscriptions = true
        noConnection = false
        
        repo.getSubscriptions() { [weak self] resp in
            self?.inProgressSubscriptions.toggle()
            
            switch resp {
            case .success(let success):
                self?.subsciptions = success
                self?.inProgressSubscriptions = false
            case .failure(_):
                self?.noConnection = true
            }
        }
    }
    
    
    func checkPromoCode(){
        promoProgress = true
        promoError = false
        self.promoMessage = ""
        repo.checkPromoCode(code: promoCode) { [weak self] resp in
            self?.inProgress.toggle()
            switch resp {
            case .success(_):
                self?.promoProgress = false
                self?.promoMessage = "earned"
//                Defaults.subsHasEnded = true
                Defaults.logged = true
            case .failure(_):
                self?.promoMessage = "failMessage"
                self?.promoProgress = false
            }
        }
    }
    
  
    
    func registerPayment(subscriptionId: Int64, paymentType: String){
        showWebview = false
        inProgress = true
        repo.registerPayment(subscriptionId: subscriptionId, paymentType: paymentType) { [weak self] resp in
            switch resp {
            case .success(let success):
                self?.registerPayment = success
                print(success)
                self?.showPopup = false
                self?.showWebview = true
                self?.inProgress = false
            case .failure(let failure):
                self?.error = true
                self?.inProgress = false
                print(failure)
            }
        }
    }
    

    func contactUs(){
        self.contactUsProgress = true
        self.contactSuccess = false
        self.contactError = false
        repo.contactUs(message: self.message) { [weak self] resp in
            switch resp {
            case .success(_):
                self?.contactUsProgress = false
                self?.contactSuccess = true
            case .failure(let failure):
                self?.contactUsProgress = false
                self?.contactError = true
                print(failure)
            }
        }
    }
    
    
    func getPaymentMethods(){
        repo.getpaymentMethods { [weak self] resp in
            switch resp {
            case .success(let success):
                self?.payMeth = success
                debugPrint(success)
            case .failure(let failure):
                debugPrint(failure)
            }
        }
    }
}
