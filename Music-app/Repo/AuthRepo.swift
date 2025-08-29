//
//  AuthRepo.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 16.08.2023.
//

import Foundation
import Alamofire

class AuthRepo{
    func sendOtp(phone: String, completion: @escaping (Result<MessageModel, AFError>) -> () ){
        Network.perform( endpoint: Endpoints.sendOtp(phone: phone),  completionHandler: completion)
    }
    
    func checkOtp(otp: String, completion: @escaping (Result<Token , AFError>) -> () ){
        Network.perform( endpoint: Endpoints.checkOtp(otp: otp),  completionHandler: completion)
    }
    
    func updateProfile(profile: ProfileModel, completion: @escaping (Result<LoggedUserModel, AFError>) -> () ){
        Network.perform( endpoint: Endpoints.profileUpdate(profile: profile),  completionHandler: completion)
    }
    
    func subscribetoFreePlan( completion: @escaping (Result<MessageModel, AFError>) -> () ){
        Network.perform( endpoint: Endpoints.suscribetoFreePlan,  completionHandler: completion)
    }
    
    func getfreeplan( completion: @escaping (Result<SubscriptionModel, AFError>) -> () ){
        Network.perform( endpoint: Endpoints.freeplan,  completionHandler: completion)
    }
    
    
}
