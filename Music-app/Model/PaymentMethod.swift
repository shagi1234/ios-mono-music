//
//  PaymentMethod.swift
//  Music-app
//
//  Created by SURAY on 05.10.2024.
//

import Foundation

struct PaymentMethod: Codable {
    var type: String
    var title: String
    var description: String
    
    enum CodingKeys: String, CodingKey {
        case type = "type"
        case title = "title"
        case description = "description"
       
    }
}
