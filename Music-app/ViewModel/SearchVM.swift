//
//  SearchVM.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 15.08.2023.
//

import Foundation
import Resolver

class SearchVM: ObservableObject {
    @Injected var repo: HomeRepo
    
    @Published var inProgress = false
    
    @Published var searchKey = ""
    @Published var searchHistory = Defaults.searchHistory
    @Published var data: SearchModel?
    @Published var firstSearch : Bool = true
    @Published var noConnection = false

    init(){
        
    }
    
    func deleteAllHistory(){
        self.searchHistory.removeAll()
    }
    
    func updateSearchHistory(search: String){
        if !search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            searchHistory.insert(search, at: 0)
            searchHistory = searchHistory.suffix(11)
            if searchHistory.count > 10 {
                searchHistory.removeLast()
            }
            Defaults.searchHistory = searchHistory
            
        }
    }
    

    func updateSearchKey(key: String){
        searchKey = key
        inProgress = true
        noConnection = false
        if searchKey == " " || searchKey.isEmpty{
            self.firstSearch = true
        }else{
            self.firstSearch = false
        }
       print(key)
        repo.getSearchResult(key: key) { [weak self] resp in
            self?.inProgress = false
      
            switch resp {
            case .success(let success):
                self?.data = success
                self?.searchKey = ""
            case .failure:
                self?.noConnection = true
                break
            }
        }
    }
}
