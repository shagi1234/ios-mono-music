//
//  SingUpVM.swift
//  Music-app
//
//  Created by SURAY on 01.10.2024.
//

import Foundation
import Resolver

class SignUpVM: ObservableObject{
    @Injected var repo : AuthRepo
    @Published var inProgress = false
    @Published var success = false
    @Published var freePlan : String = ""
    @Published var payMeth = [PaymentMethod]()

    func subscribetoFreePlan(){
        inProgress = true

        repo.subscribetoFreePlan { resp in
            switch resp {
            case .success(_):
                Defaults.logged = true
                Defaults.subsHasEnded = false
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    
    func getFreeplan(){
        repo.getfreeplan { [weak self] resp in
            switch resp {
            case .success(let success):
                self?.freePlan = success.name
                debugPrint(success)
            case .failure(let failure):
                debugPrint(failure)
            }
        }
    }
    
    
}
