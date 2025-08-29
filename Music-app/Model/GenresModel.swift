//
//  GenresModel.swift
//  Music-app
//
//  Created by SURAY on 02.03.2024.
//

import Foundation


// MARK: - Genres
struct Genres: Codable {
    let next: Int?
    let previous: Int?
    let total, page, pageSize: Int
    let results: [Genre]

    enum CodingKeys: String, CodingKey {
        case next, previous, total, page
        case pageSize
        case results
    }
}

// MARK: - Result
struct Genre: Codable {
    let id: Int
    let name: String
    let image: String
}

