//
//  SeeAllVM.swift
//  Music-app
//
//  Created by SURAY on 15.03.2024.
//

import Foundation
import Resolver

class SeeAllVM: ObservableObject{
    @Injected var repo : HomeRepo
    
    @Published var inProgress : Bool = false
    @Published var noConnection = false
    @Published var isLoadingPage = false
    @Published var songs: [SongModel]?
    @Published var albums: [PlaylistModel]?
    @Published var singles: [SongModel]?
 
    var page : Int64 = 1
    private var totalSize = 1
    
     var canLoadMoreSongs: Bool {
         return songs?.count ?? 0 < totalSize
    }
    var canLoadMoreAlbums : Bool {
        return albums?.count ?? 0 < totalSize
    }
    
    var canLoadMoreSingles :  Bool{
        return singles?.count ?? 0 < totalSize
    }
    
    var type: SeeAllPageType
    var id: Int64
    var artistName : String

    init(type: SeeAllPageType, id: Int64, artistName: String){
        self.id = id
        self.type = type
        self.artistName = artistName
        getData( page: 1)
    }
    
    func getData( page: Int64){
        if type == .albums {
            if isLoadingPage || (canLoadMoreAlbums == false && page != 1)  { return }
            if page == 1 { albums = [] }
            inProgress = albums?.isEmpty ?? true || page == 1
            isLoadingPage = true
            repo.getAlbums(id: self.id, page: page) { [weak self] resp in
                self?.inProgress = false
                self?.isLoadingPage = false

                switch resp {
                case .success(let val):
                    self?.totalSize = val.total ?? 1
                    self?.albums?.append(contentsOf: val.results )
                    self?.page = page

                case .failure(let error):
                    debugPrint(error)
                    self?.noConnection = true
                }
            }
        }else if type == .songs{
            if isLoadingPage || (canLoadMoreSongs == false && page != 1)  { return }
            if page == 1 { songs = [] }
            inProgress = songs?.isEmpty ?? true || page == 1
            isLoadingPage = true
            
            repo.getSongs(id: self.id, page: page) { [weak self] resp in
                self?.inProgress = false
                self?.isLoadingPage = false

                switch resp {
                case .success(let val):
                    self?.totalSize = val.total ?? 1
                    self?.songs?.append(contentsOf: val.results )
                    self?.page = page

                case .failure(let error):
                    debugPrint(error)
                    self?.noConnection = true
                }
            }
        }else if type == .singles{
            if isLoadingPage || (canLoadMoreSingles == false && page != 1)  { return }
            if page == 1 { singles = [] }
            inProgress = singles?.isEmpty ?? true || page == 1
            isLoadingPage = true
            
            repo.getSingles(id: self.id, page: page) { [weak self] resp in
                self?.inProgress = false
                self?.isLoadingPage = false

                switch resp {
                case .success(let val):
                    self?.totalSize = val.total ?? 1
                    self?.singles?.append(contentsOf: val.results )
                    self?.page = page

                case .failure(let error):
                    debugPrint(error)
                    self?.noConnection = true
                }
            }
        }
        
    }
}
