//
//  Enums.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 15.08.2023.
//

import Foundation

struct BottomSheetBtnData {
    var leadingIcon: String
    var title: String
    var trailingIcon: String?
}

enum BottomSheetBtn {
    case addToFav
    case removeFromFav
    case addToPlaylist
    case removeFromPlaylist
    case playNext
    case goToArtist
    case goToAlbom
    case share
    case editPlaylist
    case deletePlaylist
    case turnDownloadOn
    case turnDownloadOff
    case artists(artists: ArtistModel)
    case playlist(playlist: PlaylistModel)
    case myBalance
    case contactUs
    case version
    case language
    case premium
    case delete
    
    var data: BottomSheetBtnData {
        switch self {
        case .artists(let artist):
            return BottomSheetBtnData(leadingIcon: "artist-profile", title: artist.name, trailingIcon: "chevron.right")
        case .addToFav:
            return BottomSheetBtnData(leadingIcon: "heart", title: "add_to_fav")
        case .removeFromFav:
            return BottomSheetBtnData(leadingIcon: "heartActive", title: "remove_from_fav")
        case .addToPlaylist:
            return BottomSheetBtnData(leadingIcon: "save-playlist", title: "add_to_playlist", trailingIcon: "chevron.right")
        case .removeFromPlaylist:
            return BottomSheetBtnData(leadingIcon: "add-to-playlist", title: "remove_from_playlist", trailingIcon: "chevron.right")
        case .playNext:
            return BottomSheetBtnData(leadingIcon: "inserted", title: "play_next", trailingIcon: nil)
        case .goToArtist:
            return BottomSheetBtnData(leadingIcon: "artist-profile", title: "go_to_profile", trailingIcon: "chevron.right")
        case .goToAlbom:
            return BottomSheetBtnData(leadingIcon: "album", title: "go_to_album", trailingIcon: "chevron.right")
        case .share:
            return BottomSheetBtnData(leadingIcon: "share", title: "share", trailingIcon: nil)
        case .editPlaylist:
            return BottomSheetBtnData(leadingIcon: "edit-20", title: "edit_playlist", trailingIcon: nil)
        case .deletePlaylist:
            return BottomSheetBtnData(leadingIcon: "successDeleted", title: "delete_playlist", trailingIcon: nil)
        case .turnDownloadOn:
            return BottomSheetBtnData(leadingIcon: "download-song", title: "download_all_songs_in_playlist", trailingIcon: nil)
        case .turnDownloadOff:
            return BottomSheetBtnData(leadingIcon: "delete_all_songs", title: "delete_all_songs_in_playlist", trailingIcon: nil)
        case .playlist(playlist: let playlist):
            return BottomSheetBtnData(leadingIcon: "playlist-placeholder", title: playlist.name)
        case .myBalance:
            return BottomSheetBtnData(leadingIcon: "artist-profile", title: "my_balance", trailingIcon: "chevron.right")
        case .contactUs:
            return BottomSheetBtnData(leadingIcon: "feedback", title: "contact_us", trailingIcon: "chevron.right")
        case .version:
            return BottomSheetBtnData(leadingIcon: "light", title: "version", trailingIcon: nil)
        case .language:
            return BottomSheetBtnData(leadingIcon: "lang", title: "language", trailingIcon: nil)
        case .premium:
            return BottomSheetBtnData(leadingIcon: "premium-dots", title: "premium", trailingIcon: "chevron.right")
        case .delete:
            return BottomSheetBtnData(leadingIcon: "successDeleted", title: "delete", trailingIcon: nil)
        }
    }
}

enum PlaylistType: String {
    case top
    case simple
    case album
    case local
}

enum DownloadStatus: String {
    case inProgress
    case inQueue
    case done
}


enum MediaType: String, CaseIterable {
    case all 
    case playlists
    case albums
    case downloaded
}


enum SeeAllPageType : String {
    case songs
    case singles
    case albums
}


enum SearchGenres : String, CaseIterable {
    case all
    case artists
    case albums
    case playlists
    case songs
}

enum PaymentType : String,  CaseIterable{
    case rysgal
    case senagat
    case others
}

enum Actions: String{
    case delete
    case add
    case update
}


enum Gender: String, CaseIterable{
    case male
    case female
}

enum PopupType : String{
    case successAdded
    case successSavingPlaylist
    case successDeleted
    case playlistDeleted
    case downloadError
    case noConnection
    case inserted
    case errorSavingPlaylistOrItExsists
    case succesTurnDownOff
    case succesTurnDownOn
    case successSent
    case failMessage
    case promoMessage
}
