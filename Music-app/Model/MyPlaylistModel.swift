//
//  MyPlaylistModel.swift
//  Music-app
//
//  Created by SURAY on 12.08.2024.
//

import Foundation


// MARK  : - MyPLaylist
struct MyPLaylistModel: Codable {
    var next: Int?
    var previous: Int?
    var total, page, pageSize: Int
    var results: [MyPlaylistResult]

    enum CodingKeys: String, CodingKey {
        case next = "next"
        case previous = "previous"
        case total = "total"
        case page = "page"
        case pageSize = "page_size"
        case results = "results"
    }
}

// MARK: - Result
struct MyPlaylistResult: Codable {
    var id: Int64
    var name: String
    var isBuiltinPlaylist: Bool
    var songsCount: Int
    var isAlbum : Bool
    var image: String?
    var songs: [SongModel]?


    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case isBuiltinPlaylist = "is_builtin_playlist"
        case songsCount = "songs_count"
        case isAlbum = "is_album"
        case image = "image"
        case songs = "songs"
    }
}

