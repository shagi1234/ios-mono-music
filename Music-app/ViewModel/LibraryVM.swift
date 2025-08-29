//
//  LibraryVM.swift
//  Music-app
//
//  Created by SURAY on 06.08.2024.
//

import Foundation
import Resolver

class LibraryVM: ObservableObject{
    @Injected var repo: HomeRepo
    @Published var playlistId: Int64?
    @Published var customPLaylistAdded : Bool = false
    
    func postPlaylistToLibrary(playlistId: Int64, action: Actions){
        repo.postPlaylistToLibrary(playlistId: playlistId, action: action) {  resp in
            switch resp {
            case .success(let success):
                print(success)
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    func postCustomPlaylistToLibrary(playlist: PlaylistModel, action: Actions){
        customPLaylistAdded = false
        repo.postCustomPlaylistToLibrary(id: playlist.id, name: playlist.name, action: action) { [weak self] resp in
            switch resp {
            case .success(let success):
                self?.playlistId = success.id
                self?.customPLaylistAdded = true
                print(success)
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    func postSongsToLibrary(songsId: [Int64], playlistId: Int64, action: Actions){
        repo.postSongsToLibrary(songsId: songsId, playlistId: playlistId, action: action) { resp in
            switch resp {
            case .success(let success):
                print(success)
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    func postAlbumToLibrary(albumId: Int64, action: Actions){
        repo.postAlbumToLibrary(albumId: albumId, action: action) { resp in
            switch resp {
            case .success(let success):
                print(success)
            case .failure(let failure):
                print(failure)
            }
        }
    }
}
