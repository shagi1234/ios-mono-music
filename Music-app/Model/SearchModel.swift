//
//  File.swift
//  Music-app
//
//  Created by Shirin on 09.10.2023.
//

import Foundation

struct SearchModel: Codable {
    var topPlaylists: [PlaylistModel]
    var songs: [SongModel]
    var artists: [ArtistModel]
    var albums: [PlaylistModel]
    var playlists: [PlaylistModel]
    
    enum CodingKeys: String, CodingKey {
        case topPlaylists = "tops"
        case songs = "songs"
        case artists = "artists"
        case albums = "albums"
        case playlists = "playlists"
    }
}
