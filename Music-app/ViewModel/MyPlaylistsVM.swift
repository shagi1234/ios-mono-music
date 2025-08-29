//
//  MyPlaylistsVM.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 15.08.2023.
//

import Foundation
import Resolver

class MyPlaylistsVM: ObservableObject {
    @Injected var repo: PlaylistRepo
    @Injected var homeRepo: HomeRepo
    @Published var inProgress = false
    @Published var playlists: [PlaylistModel] = []
    @Published var data: MyPLaylistModel?
    @Published var isLoadingPage = false
    var page : Int64 = 1
    private var totalSize = 1
    
    var canLoadMore: Bool {
        return data?.results.count ?? 0 < totalSize
    }
    
    func getData(){
        playlists = AppDatabase.shared.getPlaylistsWithCount()

    }
    
    func getLocalData(id: Int64) -> PlaylistModel{
        let playlist = AppDatabase.shared.getPlaylist(localId: id) ?? PlaylistModel.example
        return playlist
    }
    
    func deletePlaylist(localId: Int64, id: Int64) {
        let _ = repo.deletePlaylist(localId: localId)
        playlists.removeAll(where: {$0.localId == localId })
        data?.results.removeAll(where: {$0.id == id})
    }
    
    func turnDownloadOff(localId: Int64) {
        if repo.turnDownloadOff(localId: localId) {
            guard let ind = playlists.firstIndex(where: {$0.localId == localId }) else { return }
            playlists[ind].isDownloadOn = false
        }
    }
    
    func turnDownloadOn(localId: Int64) {
        if repo.turnDownloadOn(localId: localId) {
            guard let ind = playlists.firstIndex(where: {$0.localId == localId }) else { return }
            playlists[ind].isDownloadOn = true
        }
    }
    
    func getMyPlaylists(page: Int64) {
        if isLoadingPage || (canLoadMore == false && page != 1)  { return }
        inProgress = data?.results.isEmpty ?? true || page == 1
        if page == 1 {
            data?.results = []
        }
        isLoadingPage = true
        homeRepo.getMyPlaylists(page: page) { [weak self] resp in
            switch resp {
            case .success(let success):
                self?.totalSize = success.total
                if self?.data == nil {
                    self?.data = MyPLaylistModel(next: success.next, previous: success.previous, total: success.total, page: success.page, pageSize: success.pageSize, results: success.results)
                } else {
                    self?.data?.next = success.next
                    self?.data?.previous = success.previous
                    self?.data?.total = success.total
                    self?.data?.page = success.page
                    self?.data?.pageSize = success.pageSize
                    self?.data?.results.append(contentsOf: success.results)
                }
                self?.page = page
                self?.compareAndSavePlaylists()
            case .failure(let failure):
                print(failure)
            }
            self?.isLoadingPage = false
        }
    }
    

    
    func compareAndSavePlaylists() {
        guard let results = data?.results else { return }
        
        let resultIds = Set(results.map { $0.id })
        let localIds = Set(playlists.map { $0.id })

        let missingIds = resultIds.subtracting(localIds)
        for missingId in missingIds {
            if let playlistToAdd = results.first(where: { $0.id == missingId }) {
                var playlst = PlaylistModel(type: playlistToAdd.isAlbum ? "album" : !playlistToAdd.isAlbum  && playlistToAdd.isBuiltinPlaylist ? "top" : "local", isDownloadOn: false, cover: playlistToAdd.image, id: playlistToAdd.id, name: playlistToAdd.name, count: playlistToAdd.songsCount)
                if playlistToAdd.isAlbum{
                    let playlistVM = PlaylistVM(type: .album, id: playlistToAdd.id)
                    playlistVM.getAlbumData(id: playlistToAdd.id) {
                        if let fetchedData = playlistVM.data, var songs = fetchedData.songs {
                            playlst.albumArtist = fetchedData.artists?.first?.name ?? ""
                            playlst.year = fetchedData.year
                            let id = AppDatabase.shared.savePlaylist(&playlst)
                            AppDatabase.shared.saveSongs(&songs, playlistId: id ?? 0)
                        }
                    }
                }else{
                    guard var songs = playlistToAdd.songs else { return }
                    let id = AppDatabase.shared.savePlaylist(&playlst)
                    AppDatabase.shared.saveSongs(&songs, playlistId: id ?? 0)
                }
            }
        }
    }
}
