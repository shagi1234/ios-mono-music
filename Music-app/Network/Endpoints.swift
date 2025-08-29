//
//  Endpoints.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 16.08.2023.
//

import Foundation
import Alamofire

let BASE_URL = "https://mono.com.tm/api"
let BASE_MEDIA_URL = "https:/mono.com.tm"

enum Endpoints {
    case refreshToken
    case profile(id: Int64)
    case sendOtp(phone: String)
    case checkOtp(otp: String)
    case profileUpdate(profile: ProfileModel)
    case getProfile
    case checkPromoCode(code: String)
    case getSubscriptions
    
    case main
    case search(key: String)
    case genres
    case artist(id: Int64)
    case playlist(id: Int64)
    case topPlaylist(id: Int64)
    case album(id: Int64)
    case artistSongs(id: Int64, page: Int64)
    case artistAlbums(id: Int64, page: Int64)
    case artistSingles(id: Int64, page: Int64)
    case listenedSong(id: Int64)
    case paymentRegister(subscriptionId: Int64, paymentType: String )
    case paymentStatus(orderId: Int64)
    case myPlaylists(page: Int64)
    case myPlaylist(id: Int64)
    case playlisttoLibrary(playlistId: Int64, action: Actions)
    case customPlaylisttoLibrary(id: Int64, name: String, action : Actions)
    case songToPlaylist(songsId: [Int64],  playlistId: Int64, action: Actions)
    case albumToLibrary(albumId: Int64, action: Actions)
    case contactUs(message: String)
    case suscribetoFreePlan
    case freeplan
    case paymentMethods
    case similarArtists(id: Int64)
    case similarAlbums(id: Int64)
    case similarPlaylists(id: Int64)
    
}

extension Endpoints: EndpointProtocol {

    
    var body: Alamofire.Parameters? {
        switch self {
            
        case .refreshToken:
            return ["refresh" : Defaults.refreshToken]
            
        case .search(let key):
            return ["s" : key]
            
        case .artistSongs(let id, let page):
            return ["artist" : "\(id)",
                    "page"   : "\(page)",
                    "is_top" : "1"]
            
        case .artistAlbums(let id, let page):
            return ["artist" : "\(id)",
                    "page"   : "\(page)"]
            
        case .artistSingles(let id, let page):
            return ["artist"    : "\(id)",
                    "is_single" : "1",
                    "page"      : "\(page)"]
            
        case .sendOtp(let phone):
            return ["phone": phone]
            
            
        case .checkOtp(let otp):
            return ["phone": Defaults.phone,
                    "otp"  : otp]
            
        case .profileUpdate(let profile ):
            return ["full_name" : profile.fullName,
                    "gender"    : profile.gender,
                    "birth_day" : profile.birthDay]
            
        case .checkPromoCode(let code):
            return ["promo" : code]
            
        case .listenedSong(let id):
            return ["song_id" : "\(id)"]
            
        case .paymentRegister(let subscriptionId, let paymentType):
            return ["subscription_id" : "\(subscriptionId)",
                    "payment_type"    : paymentType]
            
        case .paymentStatus(let orderId):
            return ["order_id" : "\(orderId)"]
            
        case .playlisttoLibrary(let playlistId, let action):
            return ["playlist_id" : "\(playlistId)",
                    "action"      : action.rawValue]
            
        case .customPlaylisttoLibrary(let id, let name, let action):
            return ["id"     : "\(id)",
                    "name"   : name,
                    "action" : action.rawValue]
            
        case .songToPlaylist(let songsId, let playlistId, let action):
            return ["songs_id"    :  songsId,
                    "playlist_id" : "\(playlistId)",
                    "action"      : action.rawValue]
            
        case .albumToLibrary(let albumId, let action):
            return ["album_id"    :  albumId,
                    "action"      :  action.rawValue]
            
        case .contactUs(let message):
            return ["message" : message]
            
        case .myPlaylists(let page):
            return ["page" : page]
            
        default:
            return nil
        }
    }
    
    var encoding: ParameterEncoding {
          return method == .get ? URLEncoding.default : JSONEncoding.default
    }
    
    var path: String {
        switch self {
        case .refreshToken: return BASE_URL+"/token/refresh"
        case .profile(let id): return BASE_URL+"/users/\(id)/"
            
        case .main: return BASE_URL+"/main/"
        case .search: return BASE_URL+"/search/"
        case .artist(let id): return BASE_URL+"/artists/\(id)/"
        case .playlist(let id): return BASE_URL+"/playlists/\(id)/"
        case .topPlaylist(let id): return BASE_URL+"/tops/\(id)/"
        case .album(let id): return BASE_URL+"/albums/\(id)/"
        case .genres: return BASE_URL + "/genres"
        case .artistSongs: return  BASE_URL+"/songs/"
        case .artistAlbums: return  BASE_URL+"/albums/"
        case .artistSingles: return  BASE_URL+"/songs"
        case .sendOtp: return BASE_URL+"/login/"
        case .checkOtp: return BASE_URL+"/otp-verify/"
        case .profileUpdate: return BASE_URL+"/profile-update"
        case .getProfile: return BASE_URL + "/profile"
        case .checkPromoCode: return BASE_URL + "/check-promo-codes"
        case .getSubscriptions: return BASE_URL + "/subscriptions"
        case .listenedSong:  return BASE_URL + "/listened-song"
        case .paymentRegister: return  BASE_URL + "/payment-register"
        case .paymentStatus : return BASE_URL + "/payment-status"
        case .myPlaylists : return BASE_URL + "/my-playlists"
        case .myPlaylist(let id) : return BASE_URL + "/my-playlists/\(id)"
        case .playlisttoLibrary: return BASE_URL + "/playlist-to-library"
        case .customPlaylisttoLibrary: return BASE_URL + "/custom-playlist-to-library"
        case .songToPlaylist : return BASE_URL + "/song-to-playlist"
        case .contactUs: return BASE_URL + "/contact-us"
        case .albumToLibrary: return BASE_URL + "/album-to-library"
        case .suscribetoFreePlan: return BASE_URL + "/subscribe-to-free-plan"
        case .freeplan: return BASE_URL + "/free-plan"
        case .paymentMethods: return BASE_URL + "/payment-methods"
        case .similarAlbums(let id): return BASE_URL + "/similar-albums/\(id)"
        case .similarArtists(let id): return BASE_URL + "/similar-artists/\(id)"
        case .similarPlaylists(let id): return BASE_URL + "/similar-playlists/\(id)"
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .refreshToken, .sendOtp, .checkOtp, .profileUpdate, .checkPromoCode, .playlisttoLibrary, .customPlaylisttoLibrary, .albumToLibrary, .songToPlaylist:
            return .post
        default:
            return .get
        }
    }
    
  
    
    var header: Alamofire.HTTPHeaders {
        let headers: Alamofire.HTTPHeaders = ["Content-Type"    : "application/json",
                                              "Accept-Language" : Defaults.lang == "tk" ? "tm" : Defaults.lang,
                                              "Authorization"   : Defaults.logged ? Defaults.token : ""]
   
            return headers
        }
    
}
