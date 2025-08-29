//
//  PlaylistCategory.swift
//  Music-app
//
//  Created by SURAY on 15.03.2024.
//

import Foundation


struct PlaylistsCategory: Codable {
    let id: Int64
    let name: String
    let order: Int64
    let playlists: [CategoryModel]
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case order = "order"
        case playlists = "playlists"
    }
}



struct CategoryModel: Codable {
    let id: Int64
    let name: String
    let image: String
    let songsCount: Int64
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case image = "image"
        case songsCount = "songs_count"
    }
    
    static let example = CategoryModel(id: 1, name: "Turkmen", image: "https://", songsCount: 0)
}
