//
//  PlaylistVM.swift
//  Music-app
//
//  Created by Shirin on 21.09.2023.
//

import Foundation
import Resolver

class PlaylistVM: ObservableObject {
    @Injected var repo: HomeRepo
    @Injected var playlistRepo: PlaylistRepo
    
    @Published var inProgress = false
    @Published var noConnection = false
    @Published var data: PlaylistModel?
    @Published var localData : PlaylistModel?
    @Published var similar: [PlaylistModel]?
    
    @Published var isDownloadOn: Bool = false
    @Published var  isSaved: Bool = false
    
    @Published var alertPresented: Bool = false
    
    @Published var downloadedImageData: Data?
    @Published var succesfullyDownload = false
    @Published var playlistDeleted = false
    var newData : PlaylistModel?
    
    
    
    var id: Int64
    var type: PlaylistType
    
    init(type: PlaylistType, id: Int64){
        self.id = id
        self.type = type
        print(id)
        getData()
        getSimilar()
    }
    
    private func getSimilar() {
        if type == .album {
            repo.getSimilarAlbums(id: id) {  [weak self] result in
                switch result {
                case .success(let response):
                    self?.similar = response
                case .failure:
                    self?.noConnection = true
                }
            }
        } else {
            repo.getSimilarPlaylists(id: id) {  [weak self] result in
                switch result {
                case .success(let response):
                    self?.similar = response
                case .failure:
                    self?.noConnection = true
                }
            }
        }
    }
    
    func getData(){
        switch type {
        case .top:
            getTopData()
        case .simple:
            getSimpleData(id: id)
        case .album:
            getAlbumData(id: id)
        case .local:
            getLocalData()
            if localData?.type == "top"{
                getSimpleData(id: localData?.id ?? 0)
            }else{
                getMyPlaylistId(id: id)
            }
            
        }
    }
    
    func getSimpleData(id: Int64) {
        inProgress = true
        noConnection = false
        
        repo.getPlaylistData(id: id) { [weak self] resp in
            self?.inProgress = false
            
            switch resp {
            case .success(let success):
                self?.data = success
                self?.compareTopPl(id: id)
                self?.updateWithLocalData()
            case .failure:
                self?.noConnection = true
            }
        }
    }
    
    func getAlbumData(id: Int64?, completion: (() -> Void)? = nil) {
        inProgress = true
        noConnection = false
        
        repo.getAlbumData(id: id ?? 0) { [weak self] resp in
            self?.inProgress = false
            
            switch resp {
            case .success(let success):
                self?.data = success
                self?.updateWithLocalData()
                completion?()
            case .failure:
                self?.noConnection = true
                completion?()
            }
        }
    }
    
    
    
    func getTopData(){
        inProgress = true
        noConnection = false
        
        repo.getTopPlaylistData(id: id) { [weak self] resp in
            self?.inProgress = false
            
            switch resp {
            case .success(let success):
                self?.data = success
                self?.updateWithLocalData()
            case .failure:
                self?.noConnection = true
            }
        }
    }
    
    
    func compareTopPl(id: Int64){
//        if localData?.type == "top"{
//            getSimpleData(id: localData?.id ?? 0)
            guard var fetchedSongs = self.data?.songs, let existingPlaylist = self.localData?.songs else {
                return
            }
            if fetchedSongs.count != existingPlaylist.count {
                for song in existingPlaylist {
                    self.deleteSong(song: song, id: self.localData?.localId ?? 0)
                }
                AppDatabase.shared.saveSongs(&fetchedSongs, playlistId: self.localData?.localId ?? 0)
                self.localData?.songs = fetchedSongs
            }
            print("get top")
//        }
    }
    
    
    func getMyPlaylistId(id: Int64) {
      
    if localData?.type == "local"{
            repo.getMyPlaylistId(id: localData?.id ?? 0) { resp in
                switch resp {
                case .success(let success):
                    self.newData = success
                    if var songs = self.newData?.songs , let existingPl = self.localData?.songs{
                        if songs.count != existingPl.count {
                            for song in existingPl{
                                self.deleteSong(song: song, id: self.localData?.localId ?? 0)
                            }
                            AppDatabase.shared.saveSongs(&songs, playlistId: self.localData?.localId ?? 0)
                            self.localData?.songs = songs
                        }
                    }
                case .failure(let failure):
                    print(failure)
                }
            }
        }
        else if(localData?.type == "album"){
            getAlbumData(id: localData?.id ?? 0)
            guard var fetchedSongs = self.data?.songs, let existingPlaylist = self.localData?.songs else {
                return
            }
            if fetchedSongs.count != existingPlaylist.count {
                for song in existingPlaylist {
                    self.deleteSong(song: song, id: self.localData?.localId ?? 0)
                }
                AppDatabase.shared.saveSongs(&fetchedSongs, playlistId: self.localData?.localId ?? 0)
                self.localData?.songs = fetchedSongs
           
            }
        }
    }
    
    
    func getLocalData(){
        localData = AppDatabase.shared.getPlaylist(localId: id)
        if localData?.type == "local"{
            localData?.songs?.reverse()
        }
        isDownloadOn = localData?.isDownloadOn ?? false
       
    }
    
    func updateWithLocalData(){
        guard let localdata = AppDatabase.shared.getPlaylist(id: id, type: type) else { return }
        localData?.localId = localdata.localId
        localData?.isDownloadOn = localdata.isDownloadOn
        isDownloadOn = localdata.isDownloadOn ?? false
        
        isSaved = true
    }
    
    func savePlaylist(){
        guard var playlist = data else { return }
        playlist.type = type.rawValue
        playlist.albumArtist = data?.artists?.first?.name
        playlist.isDownloadOn = false
        playlist.cover = data?.image
        
        guard var songs = playlist.songs else { return }
        guard let playlistId = AppDatabase.shared.savePlaylist(&playlist) else {
            alertPresented = true
            return
        }
        AppDatabase.shared.saveSongs(&songs, playlistId: playlistId)
        alertPresented = true
        isSaved = true
        self.succesfullyDownload = false

    }
    
    func deletePlaylist(){
        localData = AppDatabase.shared.getPlaylist(id: id, type: type)
        let _ = playlistRepo.deletePlaylist(localId: self.localData?.localId)
        isSaved = false
    }
    
    
    func turnDownloadOff() {
        if playlistRepo.turnDownloadOff(localId: localData?.localId ?? 0) {
            isDownloadOn = false
            getLocalData()
        }
    }
    
    func turnDownloadOn() {
        if playlistRepo.turnDownloadOn(localId: localData?.localId ?? 0) {
            isDownloadOn = true
        }
    }
    
    
    func deleteSong(song: SongModel, id: Int64) {
        playlistRepo.deleteSongFromPlaylist(playlistId: id, song: song)
        localData?.songs?.removeAll(where: { $0.id == song.id })
    }
}
