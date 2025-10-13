//
//  Coordinator.swift
//  Music-app
//
//  Created by Shirin on 07.01.2024.
//

import SwiftUI
import NavigationStackBackport

class Coordinator: ObservableObject {
    
    enum Page: Hashable {
        case artist(id: Int64)
        case playlist(type: PlaylistType, id: Int64)
        case myPlaylist(id: Int64)
        case settings
        case seeAll(type: SeeAllPageType, id: Int64, artistName: String)
        case login
        case otp
        case signUp
        case register
        case contactUs
        case subsription
        case likedSongs
    }
    
    @Published var paths = [NavigationPath(), NavigationPath(), NavigationPath()]

    
    @ViewBuilder
    func view(for page: Page) -> some View {
        switch page {
        case .artist(let id):
            ArtistView(vm: ArtistVM(id: id))
        case .playlist(let type, let id):
            PlaylistView(vm: PlaylistVM(type: type, id: id))
        case .likedSongs:
            LikedSongsView()
        case .myPlaylist(let id):
            MyPlaylistView(vm: PlaylistVM(type: .local, id: id))
        case .settings:
            SettingsView()
        case .seeAll(let type, let id, let artistName):
            SeeAllView(vm: SeeAllVM(type: type, id: id, artistName: artistName))
        case .login:
            LoginView()
        case .otp:
            OtpView()
        case .signUp:
            SignUpView()
        case .register:
            RegisterView()
        case .contactUs:
            ContactUsView()
        case .subsription:
            SubscriptionView()
        }
    }
    
    @ViewBuilder
    func getBottomSheets() -> some View {
        VStack {
            switch Tools.shared.presentedBottomsheet {
                
            case .showUpdateSheet(let updateManager) :
                UpdateSheetView(appUpdateManager: updateManager)
                
            case .none:
                EmptyView()
            }
            
        }
    }
    
    func navigateTo(tab: Int, page: Page) {
        paths[tab].append(page)
    }
    
    func navigateBack(tab: Int) {
        paths[tab].removeLast()
    }
    
    func popToRoot(tab: Int) {
        paths[tab].removeLast(paths[tab].count)
    }
    
  
}

enum BottomSheet: Observable {
    case showUpdateSheet(_ updateManager: AppUpdateManager)
    
}
