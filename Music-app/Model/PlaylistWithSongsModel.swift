//
//  PlaylistWithSongsModel.swift
//  Music-app
//
//  Created by Shirin on 13.10.2023.
//

import Foundation
import GRDB

struct PlaylistSong: Codable {
    var playlistId: Int64
    var songId: Int64
    
    enum Columns: String, ColumnExpression {
        case playlistId, songId
    }
}

extension PlaylistSong: MutablePersistableRecord, FetchableRecord {
    static let playlist = belongsTo(PlaylistModel.self)
    static let song = belongsTo(SongModel.self)
}
