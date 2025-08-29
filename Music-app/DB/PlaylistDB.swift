//
//  PlaylistDB.swift
//  Music-app
//
//  Created by Shirin on 05.11.2023.
//

import Foundation
import GRDB

extension AppDatabase {
    func getPlaylists() -> [PlaylistModel] {
        do {
            return try dbWriter.read { db in
                return try PlaylistModel.fetchAll(db)
            }
        } catch {
            debugPrint(error)
            return []
        }
    }
    
    func getPlaylistsWithCount() -> [PlaylistModel] {
        let playlists = getPlaylists()
//        print(playlists)
        var result: [PlaylistModel] = []
        
        playlists.forEach { i in
            let count = getPlaylistSongCount(id: i.localId!)
            if count == 0 && i.type != PlaylistType.local.rawValue {
                let _ = deletePlaylist(localId: i.localId)
            } else {
                var playlist = i
                playlist.count = count
                result.append(playlist)
            }
        }
        
        return result
    }
    
    func getLocalPlaylists() -> [PlaylistModel] {
        do {
            return try dbWriter.read { db in
                return try PlaylistModel.filter(Column("type") == PlaylistType.local.rawValue).fetchAll(db)
            }
        } catch {
            debugPrint(error)
            return []
        }
    }
    
    func getPlaylist(localId: Int64) -> PlaylistModel? {
        do {
            return try dbWriter.read { db in
                let songs = try SongModel.filter(playlistId: localId).fetchAll(db)
                var playlist = try PlaylistModel.filter(Column("local_id") == localId).fetchOne(db)
                playlist?.count = songs.count
                playlist?.songs = songs
           
                return playlist
            }
        } catch {
            debugPrint(error)
            return nil
        }
    }
    
    func getPlaylist(id: Int64, type: PlaylistType) -> PlaylistModel? {
        do {
            return try dbWriter.read { db in
                return try PlaylistModel.filter(Column("id") == id && Column("type") == type.rawValue).fetchOne(db)
            }
        } catch {
            debugPrint(error)
            return nil
        }
    }
    
    func getPlaylistsRelatedToSong(data: SongModel?) -> [PlaylistModel]? {
        guard let song = data else { return nil }
        var result: [PlaylistModel]?
        
        do {
            try dbWriter.write { db in
                let playlists = try PlaylistModel.filter(songId: song.localId ?? 0).fetchAll(db)

                let filteredPlaylists = try playlists.filter { playlist in
                    let songs = try SongModel.filter(playlistId: playlist.localId ?? 0).fetchAll(db)
                    return (songs.firstIndex(where: { $0.localPath == nil }) != nil)
                }
                if !filteredPlaylists.isEmpty {
                    result = filteredPlaylists
                }
            }
        } catch {
            debugPrint(error)
        }
        
        return result
    }
    
    func savePlaylist(_ data: inout PlaylistModel) -> Int64? {
        do {
            
            return try dbWriter.write { [data] db in
                if let pl = try PlaylistModel.filter(Column("id") == data.id && Column("type") == (data.type ?? "")).fetchOne(db) {
                    try data.update(db)
                    return data.localId
                } else {
                    let saved = try data.saved(db)
                    return saved.localId
                }
            }
        } catch {
            debugPrint(error)
            return nil
        }
    }
    
    func updateDownload(localId: Int64?, isDownloadOn: Bool) -> Bool? {
        guard let id = localId else { return nil }
        do {
            return try dbWriter.write { db in
                guard var playlist = try PlaylistModel.filter(Column("local_id") == id).fetchOne(db) else { return false }
                playlist.isDownloadOn = isDownloadOn
                try playlist.update(db)
                return true
            }
        } catch {
            debugPrint(error)
            return nil
        }
    }
    
    func deletePlaylist(localId: Int64?) -> Bool? {
        guard let id = localId else { return false}
   
        do {
            try dbWriter.write { db in
                let songs = AppDatabase.shared.getPlaylist(localId: localId ?? 0)?.songs ?? []
                try songs.forEach{ i in
                    let playlists = try PlaylistModel.filter(songId: i.localId ?? 0).fetchAll(db)
                    if playlists.count == 1{
                        let hasReferences = try PlaylistModel.filter(songId: i.localId ?? 0).fetchCount(db) == 1
                        if hasReferences{
                            let _ = try SongModel.filter(id: i.localId ?? 0).deleteAll(db)
                        } else{
                            try PlaylistSong.filter(Column("playlistId") == id && Column("songId") == i.localId ).deleteAll(db)
                        }
                    }
                }
                try PlaylistModel.deleteOne(db, id: id)
            }
            return true
        } catch {
            debugPrint(error)
            return false
        }
    }
    
    func getPlaylistSongCount(id: Int64) -> Int {
        do {
            return try dbWriter.read{ db in
                return try SongModel.filter(playlistId: id).fetchCount(db)
            }
        } catch {
            debugPrint(error)
            return 0
        }
    }
    
    func deleteAllPlaylists(){
        do{
            try dbWriter.write{ db in
                try PlaylistModel.deleteAll(db)
                try SongModel.deleteAll(db)
            }
        }catch{
            debugPrint(error)
        }
    }
}
