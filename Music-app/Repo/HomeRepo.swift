//
//  HomeRepo.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 16.08.2023.
//

import Foundation
import Alamofire

class HomeRepo {
    func getHome(completion: @escaping (Result<HomeModel, AFError>) -> () ){
        Network.perform(endpoint: Endpoints.main, completionHandler: completion)
    }

    func getSearchResult(key: String, completion: @escaping (Result<SearchModel, AFError>) -> () ){
        Network.perform(endpoint: Endpoints.search(key: key), completionHandler: completion)
    }

    func getGenres( completion: @escaping (Result<Genres, AFError>) -> () ){
        Network.perform(endpoint: Endpoints.genres, completionHandler: completion)
    }
    
    func getArtistData(id: Int64, completion: @escaping (Result<ArtistModel, AFError>) -> () ){
        Network.perform(endpoint: Endpoints.artist(id: id), completionHandler: completion)
    }
    
    func getPlaylistData(id: Int64, completion: @escaping (Result<PlaylistModel, AFError>) -> () ){
        Network.perform(endpoint: Endpoints.playlist(id: id), completionHandler: completion)
    }
    
    func getTopPlaylistData(id: Int64, completion: @escaping (Result<PlaylistModel, AFError>) -> () ){
        Network.perform(endpoint: Endpoints.topPlaylist(id: id), completionHandler: completion)
    }
    
    func getAlbumData(id: Int64, completion: @escaping (Result<PlaylistModel, AFError>) -> () ){
        Network.perform(endpoint: Endpoints.album(id: id), completionHandler: completion)
    }
    
    func getSongs(id: Int64, page : Int64, completion: @escaping (Result<Pagination<SongModel>, AFError>) -> () ){
        Network.perform(endpoint: Endpoints.artistSongs(id: id, page: page), completionHandler: completion)
    }
    
    func getAlbums(id: Int64, page : Int64, completion: @escaping (Result<Pagination<PlaylistModel>, AFError>) -> () ){
        Network.perform(endpoint: Endpoints.artistAlbums(id: id, page: page), completionHandler: completion)
    }
    
    func getSingles(id: Int64, page : Int64, completion: @escaping (Result<Pagination<SongModel>, AFError>) -> () ){
        Network.perform(endpoint: Endpoints.artistSingles(id: id, page: page), completionHandler: completion)
    }
    
    func getProfile( completion: @escaping (Result<LoggedUserModel, AFError>) -> () ){
        Network.perform(endpoint: Endpoints.getProfile, completionHandler: completion)
    }
    
    func checkPromoCode(code: String, completion: @escaping (Result<CheckPromoCodeModel, AFError>) -> () ){
        Network.perform(endpoint: Endpoints.checkPromoCode(code: code), completionHandler: completion)
    }
    
    func getSubscriptions( completion: @escaping (Result<[SubscriptionModel], AFError>) -> () ){
        Network.perform(endpoint: Endpoints.getSubscriptions, completionHandler: completion)
    }
    
    func postListenedSong(id: Int64, completion: @escaping (Result<String, AFError>) -> () ){
        Network.perform(endpoint: Endpoints.listenedSong(id: id), completionHandler: completion)
    }
    
    func registerPayment(subscriptionId: Int64, paymentType: String, completion: @escaping (Result<RegisterPaymentModel, AFError>) -> () ){
        Network.perform(endpoint: Endpoints.paymentRegister(subscriptionId: subscriptionId, paymentType: paymentType), completionHandler: completion)
    }
    
    func getPaymentStatus(orderId: Int64, completion: @escaping (Result<String, AFError>) -> () ){
        Network.perform(endpoint: Endpoints.paymentStatus(orderId: orderId), completionHandler: completion)
    }
    
    func postPlaylistToLibrary(playlistId: Int64, action: Actions, completion: @escaping (Result<String, AFError>) -> () ){
        Network.perform(endpoint: Endpoints.playlisttoLibrary(playlistId: playlistId, action: action), completionHandler: completion)
    }

    func postCustomPlaylistToLibrary(id: Int64, name: String, action: Actions, completion: @escaping (Result<CustomPlaylistModel, AFError>) -> () ){
        Network.perform(endpoint: Endpoints.customPlaylisttoLibrary(id: id, name: name, action: action), completionHandler: completion)
    }
    
    func postSongsToLibrary(songsId: [Int64], playlistId: Int64, action: Actions, completion: @escaping (Result<String, AFError>) -> () ){
        Network.perform(endpoint: Endpoints.songToPlaylist(songsId: songsId, playlistId: playlistId, action: action), completionHandler: completion)
    }
    
    func getMyPlaylists(page: Int64, completion: @escaping (Result<MyPLaylistModel, AFError>) -> () ){
        Network.perform(endpoint: Endpoints.myPlaylists(page: page), completionHandler: completion)
    }
    
    func getMyPlaylistId(id: Int64 , completion: @escaping (Result<PlaylistModel, AFError>) -> () ){
        Network.perform(endpoint: Endpoints.myPlaylist(id: id), completionHandler: completion)
    }
    
    func postAlbumToLibrary(albumId: Int64 , action: Actions, completion: @escaping (Result<String, AFError>) -> () ){
        Network.perform(endpoint: Endpoints.albumToLibrary(albumId: albumId, action: action), completionHandler: completion)
    }
    
    func contactUs(message: String , completion: @escaping (Result<MessageModel, AFError>) -> () ){
        Network.perform(endpoint: Endpoints.contactUs(message: message), completionHandler: completion)
    }
    
    func getpaymentMethods( completion: @escaping (Result<[PaymentMethod], AFError>) -> () ){
        Network.perform( endpoint: Endpoints.paymentMethods,  completionHandler: completion)
    }
    
    func getSimilarArtists(id: Int64, completion: @escaping (Result<[ArtistModel], AFError>) -> () ){
        Network.perform(endpoint: Endpoints.similarArtists(id: id), completionHandler: completion)
    }
    func getSimilarPlaylists(id: Int64, completion: @escaping (Result<[PlaylistModel], AFError>) -> () ){
        Network.perform(endpoint: Endpoints.similarPlaylists(id: id), completionHandler: completion)
    }
    func getSimilarAlbums(id: Int64, completion: @escaping (Result<[PlaylistModel], AFError>) -> () ){
        Network.perform(endpoint: Endpoints.similarAlbums(id: id), completionHandler: completion)
    }
    
}
