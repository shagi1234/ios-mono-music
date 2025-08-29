//
//  RegisterVM.swift
//  Music-app
//
//  Created by SURAY on 27.03.2024.
//

import Foundation

import Resolver

class RegisterVM: ObservableObject {
    @Injected var repo : AuthRepo
    @Published var inProgress = false
    @Published var gender : Gender = .male
    @Published var day = ""
    @Published var month = ""
    @Published var year = ""
    @Published var fullname = ""
    @Published var phoneNum = ""
    @Published var dismiss = false
    @Published var success = false
    @Published var editing = false
    @Published var editingFullName = false
    @Published var fail = false
    @Published var successfullyUpdated = false
    
    init(){
        
    }
    
    func updateProfile(){
        inProgress = true
        let year = self.year
        let month = self.month
        let day = self.day
        
        repo.updateProfile(profile: ProfileModel(fullName: fullname, gender: gender.rawValue, birthDay: "\(year)-\(month)-\(day)")){ [weak self] resp in
            self?.inProgress = false
            
            switch resp {
            case .success(_):
                Defaults.birthDay = "\(year)-\(month)-\(day)"
                Defaults.gender = self?.gender.rawValue ?? ""
                self?.successfullyUpdated = true
                
            case .failure(let error):
                self?.fail = true
                debugPrint(error)
            }
        }
    }
    
    func separateDate() {
        let dateComponents = Defaults.birthDay.components(separatedBy: "-")
        year = dateComponents[0]
        month = dateComponents[1]
        day = dateComponents[2]
        gender = Gender(rawValue: Defaults.gender) ?? .male
    }
    
}
