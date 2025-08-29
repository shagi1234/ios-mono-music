//
//  SongService.swift
//  Music-app
//
//  Created by SURAY on 18.07.2024.
//

import Foundation
import Resolver

protocol SongServiceProtocol {
    var success: Bool { get }
    func postSongFinished(id: Int64)
}


class SongService: SongServiceProtocol{
    @Injected var repo : HomeRepo
    @Published var success : Bool = false
    func postSongFinished(id: Int64) {
        repo.postListenedSong(id: id) {  resp in
            switch resp {
            case .success(let success):
                self.success = true
                print(success)
            case .failure(let failure):
                self.success = false
                print(failure)
            }
        }
    }
}
