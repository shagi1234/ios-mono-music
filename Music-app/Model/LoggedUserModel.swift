//
//  LoggedUserModel.swift
//  Music-app
//
//  Created by SURAY on 18.04.2024.
//

import Foundation


struct LoggedUserModel: Codable {
    let phone : String
    let fullName: String
    let loggedInFirstTime: Bool
    let subscription : SubscriptionModel?
    let birthDay, gender, subscriptionEndDate: String

    enum CodingKeys: String, CodingKey {
        case phone = "phone"
        case fullName = "full_name"
//        case region = "region"
        case loggedInFirstTime = "logged_in_first_time"
        case birthDay = "birth_day"
        case gender = "gender"
        case subscriptionEndDate = "subscription_end_date"
        case subscription = "subscription"
    }
}

struct Region: Codable {
    let id: Int
    let name: String
}
