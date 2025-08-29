//
//  PlaylistRepo.swift
//  Music-app
//
//  Created by Shirin on 28.12.2023.
//

import Foundation

class PlaylistRepo {
    func deletePlaylist(localId: Int64?) -> Bool? {
        guard let id = localId else { return nil}
        
        let _ = turnDownloadOff(localId: id)
        
        let deleted =  AppDatabase.shared.deletePlaylist(localId: id)
        return  deleted
    }
    
    func deleteSongFromPlaylist(playlistId: Int64, song: SongModel){
        guard let deletedSong = AppDatabase.shared.deleteSongFromPlaylist(playlistId: playlistId, data: song) else { return }
        
        print(deletedSong)
        if let path = deletedSong.localPath {
            try? FileManager.default.removeItem(atPath: path)
        }
        else {
            DownloadManager.shared.deleteSong(song: deletedSong)
            AppDatabase.shared.deleteFromQueue(data: deletedSong)
        }
        
    }
    
    func turnDownloadOn(localId: Int64) -> Bool {
        if AppDatabase.shared.updateDownload(localId: localId, isDownloadOn: true) == true {
            let songs = AppDatabase.shared.getPlaylist(localId: localId)?.songs ?? []
            
            var songsToAdd: [SongModel] = []
            songs.forEach { i in
                if AppDatabase.shared.addToQueue(data: DownloadQueue(id: i.id, song: i)) {
                    songsToAdd.append(i)
                }
            }
            DownloadManager.shared.downloadSongs(songs: songsToAdd)
            return true
        } else {
            return false
        }
    }
    
    func turnDownloadOff(localId: Int64) -> Bool {
        if AppDatabase.shared.updateDownload(localId: localId, isDownloadOn: false) == true {
            let songs = AppDatabase.shared.getPlaylist(localId: localId)?.songs ?? []
            deleteSongs(data: songs)
            return true
        } else {
            return false
        }
    }
    

    
    private func deleteSongs(data: [SongModel]) {
        let deletedSongs = AppDatabase.shared.deleteSongsOrUpdatePath(data: data)
        deletedSongs.forEach { i in
            if let path = i.localPath {
                try? FileManager.default.removeItem(atPath: path)
            } else {
                DownloadManager.shared.deleteSong(song: i)
                AppDatabase.shared.deleteFromQueue(data: i)
            }
        }
    }
}
