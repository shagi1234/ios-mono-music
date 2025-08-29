//
//  ArtistVM.swift
//  Music-app
//
//  Created by Shirin on 29.09.2023.
//

import Foundation
import Resolver

class ArtistVM: ObservableObject {
    @Injected var repo: HomeRepo
    
    @Published var isLoading = false
    @Published var inProgress = false
    @Published var noConnection = false
    @Published var data: ArtistModel?
    @Published var songs: [SongModel]?
    @Published var similarArtists: [ArtistModel]?
    
    var totalPages = 0
    var page : Int = 1
    
    var id: Int64
    
    init(id: Int64){
        self.id = id
        getData()
    }
    
    func getSimilarArtists() {
        repo.getSimilarArtists(id: id){ [weak self] result in
            switch result {
            case .success(let response):
                self?.similarArtists = response
            case .failure:
                self?.noConnection = true
            }
        }
    }
    
    func loadMoreContent(currentItem data: SongModel){
        isLoading.toggle()
        if page + 1 <= totalPages{
            isLoading.toggle()
            
        }
     }

    func getData(){
        inProgress = true
        noConnection = false
        repo.getArtistData(id: id) { [weak self] resp in
            self?.inProgress = true
            
            switch resp {
            case .success(let success):
                self?.data = success
                self?.getSimilarArtists()
            case .failure:
                self?.noConnection = true
            }
        }
    }
}
