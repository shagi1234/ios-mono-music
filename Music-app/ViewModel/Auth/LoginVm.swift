//
//  LoginVM.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 15.08.2023.
//

import Foundation
import Resolver

class LoginVM: ObservableObject {
    @Injected var repo : AuthRepo
    @Published var inProgress = false

    @Published var phone = ""
    @Published var dismiss = false
    @Published var success = false

    @Published var editing = false
    @Published var fail = false

    init(){
        
    }
    func sendOtp(){
        inProgress = true

        repo.sendOtp(phone: phone) { [weak self] resp in
            self?.inProgress = false

            switch resp {
            case .success(let val):
                Defaults.phone = self?.phone ?? ""
                print(val.message)
                print(Defaults.phone)
                self?.success = true

            case .failure(let error):
                self?.fail = true
                print(error)
                break
            }
        }
    }
    
}
