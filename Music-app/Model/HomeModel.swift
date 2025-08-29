//
//  HomeModel.swift
//  Music-app
//
//  Created by Shirin on 19.09.2023.
//

import Foundation

struct HomeModel: Codable {
    var topPlaylists: [PlaylistModel]
    var hitSongs: [SongModel]
    var artists: [ArtistModel]
    var albums: [PlaylistModel]
    var playlistsCategories: [PlaylistsCategory]
    
    enum CodingKeys: String, CodingKey {
        case topPlaylists = "tops"
        case hitSongs = "hit_songs"
        case artists = "artists_of_the_week"
        case albums = "albums"
        case playlistsCategories = "playlists_categories"
    }
}



