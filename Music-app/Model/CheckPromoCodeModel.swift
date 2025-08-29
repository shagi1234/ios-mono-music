//
//  CheckPromoCode.swift
//  Music-app
//
//  Created by SURAY on 22.11.2024.
//

import Foundation

struct CheckPromoCodeModel: Codable {
    let earned : String
    let timeLimit: Int64

    enum CodingKeys: String, CodingKey {
        case earned = "earned"
        case timeLimit = "time_limit"
    }
}

