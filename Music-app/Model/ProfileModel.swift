//
//  ProfileModel.swift
//  Music-app
//
//  Created by SURAY on 18.04.2024.
//

import Foundation

struct ProfileModel: Codable {
    var fullName: String
    var gender: String
    var birthDay: String
    var subscription: SubscriptionModel?
    var subscriptionEndDate: String?
    
    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case gender = "gender"
        case birthDay = "birth_day"
        case subscription = "subscription"
        case subscriptionEndDate = "subscription_end_date"
    }
}


struct RegionModel: Codable {
    var id : Int
    var name : String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
    } 
    
    static var example = RegionModel(id: 1, name: "Ag")
}
