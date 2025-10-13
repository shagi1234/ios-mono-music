//
//  SongModel.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 15.08.2023.
//

import Foundation
import GRDB

struct SongModel: Codable,  Identifiable{

    var localId: Int64?
    var localPath: String?
    
    
    var id: Int64
    var name: String
    var isLiked: Bool?
    var image: String
    var artists: [ArtistModel]
    var albumId: Int64?
    var audio: String
    var year : Int64
    
    var artistName: String {
        return artists.map{ $0.name}.joined(separator: ", ")
    }

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case image = "image"
        case name = "name"
        case artists = "artists"
        case albumId = "album_id"
        case audio = "audio"
        case localId = "local_id"
        case localPath = "local_path"
        case year = "year"
        case isLiked = "is_liked"
    }

    static let example = SongModel(id: 199, name: "Public Service Announcement", image: "/media/images/songs/song_scover_cLm90vs.jpeg", artists: [.example], albumId: 1, audio:  "/media/audio/songs/01_-_Public_Service_Announcement.mp3", year: 2015)
    
}

extension SongModel: FetchableRecord, MutablePersistableRecord {
    static let playlistId = hasMany(PlaylistSong.self)
    
    static func filter(playlistId: Int64) -> QueryInterfaceRequest<SongModel> {
        return all().filter(playlistId: playlistId)
    }

    mutating func didInsert(_ inserted: InsertionSuccess) {
        localId = inserted.rowID
    }
}

extension QueryInterfaceRequest where RowDecoder == SongModel {
    func filter(playlistId: Int64) -> QueryInterfaceRequest<SongModel> {
        let songs = SongModel.playlistId.filter(PlaylistSong.Columns.playlistId == playlistId)
        return joining(required: songs)
    }
}
