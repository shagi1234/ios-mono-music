//
//  PaginationModel.swift
//  Music-app
//
//  Created by SURAY on 13.03.2024.
//


import Foundation

struct Pagination<T: Codable> : Codable{
    var next:       Int? = 0
    var previous:       Int? = 0
    var total:     Int? = 0
    var page: Int? = 0
    var page_size:  Int? = 0
    var results: [T]
}
