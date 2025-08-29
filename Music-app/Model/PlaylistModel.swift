//
//  PlaylistModel.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 15.08.2023.
//

import Foundation
import GRDB

struct PlaylistModel: Codable, Identifiable {
    var localId: Int64?
    var type: String?
    var isDownloadOn: Bool?
    var cover: String?
    var text: String?
    var albumArtist : String?
    
    var id: Int64
    var name: String
    var image: String?
    var count: Int?
    var year: Int?
    var artists: [ArtistModel]?
    var songs: [SongModel]?

    enum CodingKeys: String, CodingKey {
        case localId = "local_id"
        case type = "type"
        case isDownloadOn = "is_download_on"
        case cover = "cover"
        case albumArtist = "album_artist"
        
        case id = "id"
        case name = "name"
        case image = "image"
        case count = "songs_count"
        case year = "year"
        case artists = "artists"
        case songs = "songs"
        
    }
    
    static let example = PlaylistModel(id: 1, name: "Playlist new 1", image: "https://", count: 10)
}

extension PlaylistModel: FetchableRecord, MutablePersistableRecord {
    static let songs = hasMany(PlaylistSong.self)

    static func filter(songId: Int64) -> QueryInterfaceRequest<PlaylistModel> {
        return all().filter(songId: songId)
    }


    func encode(to container: inout PersistenceContainer) {
        container["local_id"] = localId
        container["id"] = id
        container["name"] = name
        container["type"] = type
        container["is_download_on"] = isDownloadOn
        container["cover"] = cover
        container["year"] = year
        container["album_artist"] = albumArtist
     
    }

    mutating func didInsert(_ inserted: InsertionSuccess) {
        self.localId = inserted.rowID
    }
}

extension QueryInterfaceRequest where RowDecoder == PlaylistModel {
    func filter(songId: Int64) -> QueryInterfaceRequest<PlaylistModel> {
        let songs = PlaylistModel.songs.filter(PlaylistSong.Columns.songId == songId)
        return joining(required: songs)
    }
}

