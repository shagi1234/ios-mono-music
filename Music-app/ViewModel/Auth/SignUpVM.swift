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
    @Injected var homeRepo : HomeRepo
    @Published var inProgress = false
    @Published var success = false
    @Published var freePlan : String = ""
    @Published var payMeth = [PaymentMethod]()

    func subscribetoFreePlan(){
        inProgress = true

        repo.subscribetoFreePlan { [weak self] resp in
            switch resp {
            case .success(_):
                self?.repo.getfreeplan { freePlanResp in
                    switch freePlanResp {
                    case .success(let freePlan):
                        DispatchQueue.main.async {
                            Defaults.subsType = freePlan.name
                            Defaults.subsHasEnded = false
                            Defaults.logged = true
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self?.getProfile()
                        }

                    case .failure(_):
                        DispatchQueue.main.async {
                            Defaults.subsType = "free"
                            Defaults.subsHasEnded = false
                            Defaults.logged = true
                        }
                    }
                }

            case .failure(_):
                self?.inProgress = false
            }
        }
    }

    func getProfile(){
        homeRepo.getProfile { resp in
            switch resp {
            case .success(let profile):
                Defaults.fullName = profile.fullName
                Defaults.birthDay = profile.birthDay
                Defaults.subsEndDate = profile.subscriptionEndDate
                if ((profile.subscription?.name.isEmpty) == nil) {
                    Defaults.subsType = profile.subscription?.name ?? ""
                }
            case .failure(_):
                break
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
