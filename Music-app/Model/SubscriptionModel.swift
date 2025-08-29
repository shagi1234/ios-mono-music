//
//  Subscription.swift
//  Music-app
//
//  Created by SURAY on 20.06.2024.
//

import Foundation

struct SubscriptionModel: Codable {
    var id: Int64
    var name: String
    var image: String?
    var days: Int?
    var price : Int?
    let discount: Bool?
    let discountAmount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case image = "image"
        case days = "days"
        case price = "price"
        case discount = "discount"
        case discountAmount = "discountAmount"
   
       
    }
    
    static let example = SubscriptionModel(id: 1, name: "Mugt", image: "https:\\", days: 0, price: 0, discount: false, discountAmount: 0 )
}
