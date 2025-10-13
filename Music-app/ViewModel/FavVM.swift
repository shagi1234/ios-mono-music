//
//  FavVM.swift
//  Music-app
//
//  Created by Shahruh on 30.09.2025.
//

import SwiftUI
import Resolver

enum FavAction: String{
    case like = "like"
    case unlike = "unlike"
}

class FavVM: ObservableObject {
    @Published var mainVm = Resolver.resolve(MainVM.self)
    @Published var likedSongs: [SongModel]? = nil
    @Published var inProgress = false
    @Published var noConnection = false
    @Published var isLoadingPage = false
    @Published var canLoadMoreSongs = true
    @Published var page = 1
    @Published var totalSize = 0
    
    @Injected var homeRepo: HomeRepo
    
    func addToFav(_ id: Int64,action: FavAction) {
        homeRepo.addToFav(id: id,action: action.rawValue) { result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    if response.liked {
                        self.mainVm.popUpType = .successAdded
                    } else {
                        self.mainVm.popUpType = .successDeleted
                        // Remove song from local array
                        self.likedSongs?.removeAll(where: { $0.id == id })
                        self.totalSize = self.likedSongs?.count ?? 0
                    }
                }
            case .failure:
                DispatchQueue.main.async {
                    self.mainVm.popUpType = .failMessage
                }
            }
        }
    }
    
    func getLikedSongs() {
        if isLoadingPage || (canLoadMoreSongs == false && page != 1) { return }
        
        if page == 1 {
            likedSongs = []
        }
        
        inProgress = likedSongs?.isEmpty ?? true || page == 1
        noConnection = false
        isLoadingPage = true
        
        homeRepo.getLikedSongs(page: page) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.inProgress = false
                self.isLoadingPage = false
                
                switch result {
                case .success(let response):
                    self.totalSize = response.total ?? 0
                    
                    let songs = response.results.map { $0.song }
                    
                    if self.page == 1 {
                        self.likedSongs = songs
                    } else {
                        self.likedSongs?.append(contentsOf: songs)
                    }
                    
                    self.canLoadMoreSongs = response.next != nil
                    
                case .failure(let error):
                    debugPrint("Error fetching liked songs: \(error)")
                    self.noConnection = true
                }
            }
        }
    }
    
    func loadMoreIfNeeded(currentSong: SongModel) {
        guard let songs = likedSongs,
              let index = songs.firstIndex(where: { $0.id == currentSong.id }),
              index >= songs.count - 5,
              canLoadMoreSongs,
              !isLoadingPage else {
            return
        }
        
        page += 1
        getLikedSongs()
    }
}
