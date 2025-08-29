//
//  RegisterPaymentModel.swift
//  Music-app
//
//  Created by SURAY on 18.07.2024.
//

import Foundation


struct RegisterPaymentModel: Codable{
    var orderId : String
    var formUrl: String
    
    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case formUrl = "form_url"
    }
}
