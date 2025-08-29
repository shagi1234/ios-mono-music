//
//  ArtistModel.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 17.08.2023.
//

import Foundation

struct ArtistModel: Codable {
    var id: Int64
    var image: String
    var name: String
    var count: Int?
    var songs: [SongModel]?
    var albums: [PlaylistModel]?
    var singles: [SongModel]?
    var latestRelease : LatestReleaseModel?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case image = "image"
        case name = "name"
        case count = "songs_count"
        case songs = "songs"
        case albums = "albums"
        case singles = "singles"
        case latestRelease = "latest_release"
    }
    
    static let example = ArtistModel(id: 1, image: "https://", name: "Green Apelsin", count: 50)
}

struct LatestReleaseModel: Codable {
    let song: SongModel?
    let album: PlaylistModel?
}
