//
//  SongDB.swift
//  Music-app
//
//  Created by Shirin on 05.11.2023.
//

import Foundation
import Resolver
import GRDB

extension AppDatabase {
    
    func getSongs() -> [SongModel] {
        do {
            return try dbWriter.read { db in
                return try SongModel.fetchAll(db)
            }
        } catch {
            debugPrint(error)
            return []
        }
    }
    
    func getSong(id: Int64) -> SongModel? {
        do {
            return try dbWriter.read { db in
                return try SongModel.filter(Column("id") == id).fetchOne(db)
            }
        } catch {
            debugPrint(error)
            return nil
        }
    }
    
    func saveSongs(_ data: inout [SongModel], playlistId: Int64) {
        do {
            try dbWriter.write { db in
                try data.forEach { i in
                    var saved = i
                    if let existingSong = try SongModel.filter(Column("id") == i.id).fetchOne(db) {
                        saved = existingSong
                    } else {
                        saved = try i.saved(db)
                    }
                    
                    let item = PlaylistSong(playlistId: playlistId, songId: saved.localId ?? 1)
                    let _ = try item.saved(db)
                    let playlist = try PlaylistModel.filter(id: playlistId).fetchOne(db)

                    if playlist?.isDownloadOn == true && saved.localPath == nil {
                        var queueItem = DownloadQueue(id: saved.id, song: saved)
                        try queueItem.save(db)
                        DownloadManager.shared.addSong(song: queueItem)
                    }
                }
            }
        } catch {
            debugPrint(error)
        }
    }
    
    func saveSong(_ data: inout SongModel, playlistId: Int64) {
        do {
            try dbWriter.write { [data] db in
                
                var saved = data
                if let existingSong = try SongModel.filter(Column("id") == data.id).fetchOne(db) {
                    saved = existingSong
                } else {
                    saved = try data.saved(db)
                }
                
                let item = PlaylistSong(playlistId: playlistId, songId: saved.localId ?? 1)
                let _ = try item.saved(db)
                
                let playlist = try PlaylistModel.filter(id: playlistId).fetchOne(db)
                if playlist?.isDownloadOn == true && saved.localPath == nil {
                    var queueItem = DownloadQueue(id: saved.id, song: saved)
                    try queueItem.save(db)
                    DownloadManager.shared.addSong(song: queueItem)
                }
            }
        } catch {
            debugPrint(error)
        }
    }
    
    func updateSongLocalPath(id: Int64, localPath: String){
        do {
            try dbWriter.write { db in
                var data = try SongModel.filter(Column("id") == id).fetchOne(db)
                data?.localPath = localPath
                try data?.update(db)
                _ = try DownloadQueue.filter(key: id).deleteAll(db)
            }
        } catch {
            debugPrint(error)
        }
    }
    
    func deleteSongsOrUpdatePath(data: [SongModel]) -> [SongModel] {
        var result: [SongModel] = []
        
        do {
            try dbWriter.write { db in
                try data.forEach { i in
                    var data = i
                    let playlists = try PlaylistModel.filter(songId: i.localId ?? 0).fetchAll(db)
                    if playlists.isEmpty {
                        result.append(data)
                        try data.delete(db)
                    } else if playlists.filter({ $0.isDownloadOn == true }).isEmpty { //download on playlistda yok
                        result.append(i)
                        if  data.localPath != nil {
                            data.localPath = nil
                            try data.update(db)
                        }
                    }
                }
            }
        } catch {
            debugPrint(error)
        }
        return result
    }

    
    func deleteSongFromPlaylist(playlistId: Int64?, data: SongModel?) -> SongModel? {
        guard let playlistId = playlistId else { return nil }
        guard let songId = data?.localId else { return nil }
        guard let song = data else { return nil }
        var result: SongModel?
        
        do {
            try dbWriter.write { db in
                result = data
                let hasReferences = try PlaylistModel.filter(songId: songId).fetchCount(db) == 1
                if hasReferences{
                    let _ = try SongModel.filter(id: song.localId ?? 0).deleteAll(db)
                } else{
                    try PlaylistSong.filter(Column("playlistId") == playlistId && Column("songId") == songId ).deleteAll(db)
                }
            }
        } catch {
            debugPrint(error)
        }
        
        return result
    }
    
    func getQueue() -> [DownloadQueue] {
        do {
            return try dbWriter.read { db in
                return try DownloadQueue.fetchAll(db)
            }
        } catch {
            debugPrint(error)
            return []
        }
    }
    
    func addToQueue(data: DownloadQueue) -> Bool {
        do {
            return try dbWriter.write { db in
                if data.song.localPath != nil { return false }
                if try DownloadQueue.filter(key: data.id).fetchOne(db) != nil { return false }
                var queueItem = data
                try queueItem.save(db)
                return true
            }
        } catch {
            debugPrint(error)
            return false
        }
    }
    
    func deleteFromQueue(data: SongModel) {
        do {
            try dbWriter.write { db in
                let _ = try DownloadQueue.filter(key: data.id).deleteAll(db)
            }
        } catch {
            debugPrint(error)
        }
    }
}
