//
//  Token.swift
//  Music-app
//
//  Created by SURAY on 27.03.2024.
//

import Foundation

struct Token: Codable {
    var user : ProfileModel
    var refresh: String
    var access: String
    var loggedFirstTime: Bool?
    var message : String?
    
    enum CodingKeys: String, CodingKey {
        case user = "user"
        case refresh = "refresh"
        case access = "access"
        case loggedFirstTime = "logged_in_first_time"
        case message = "message"
       
    }
}
