//
//  MainView.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 15.08.2023.
//

import SwiftUI
import Resolver
import NavigationStackBackport
import Kingfisher
import PopupView

struct MainView: View {
    @StateObject var vm = Resolver.resolve(MainVM.self)
    @StateObject var playervm  = Resolver.resolve(PlayerVM.self)
    @StateObject var libraryVm = Resolver.resolve(LibraryVM.self)
    @StateObject var playlistvm: PlaylistVM = PlaylistVM(type: .local, id: 1)
    @StateObject var coordinator = Coordinator()
    @StateObject private var tabMonitor = TabMonitor()
    @StateObject private var vpnMonitor = VPNMonitor()
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State var keyboardIsShown = false
    @State var playerPresented = false
    @State var songBSPresented = false
    @State var addToPlaylistPresented = false
    @State var showArtists = false
    @State var showLibraryPlaylist = false
    @State var vpnConnected = false
    let impactMed = UIImpactFeedbackGenerator(style: .medium)
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = .black
        
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white
        ]
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.stackedLayoutAppearance.normal.iconColor = .white
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $vm.selectedTab) {
                NavigationStack(path: $coordinator.paths[0]) {
                    HomeView()
                        .backport.navigationDestination(for: Coordinator.Page.self) { page in
                            coordinator.view(for: page)
                        }
                }.environmentObject(coordinator)
                    .tabItem { TabItem(data: .home, selectedInd: $vm.selectedTab) }
                    .tag(0)
                
                NavigationStack(path: $coordinator.paths[1]) {
                    SearchView()
                        .backport.navigationDestination(for: Coordinator.Page.self) { page in
                            coordinator.view(for: page)
                        }
                }.environmentObject(coordinator)
                    .tabItem { TabItem(data: .search, selectedInd: $vm.selectedTab) }
                    .tag(1)
                
                NavigationStack(path: $coordinator.paths[2]) {
                    MyPlaylistsView()
                        .backport.navigationDestination(for: Coordinator.Page.self) { page in
                            coordinator.view(for: page)
                        }
                }.environmentObject(coordinator)
                    .tabItem { TabItem(data: .playlists, selectedInd: $vm.selectedTab) }
                    .tag(2)
            }
            .onReceive(vm.$selectedTab) { newValue in
                if newValue != vm.oldTab {
                    vm.oldTab = newValue
                } else {
                    coordinator.popToRoot(tab: newValue)
                }
            }
            .onReceive(vm.$albumId) { recieved in
                guard let id = recieved.publisher.output else { return }
                if playerPresented{
                    playerPresented = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        coordinator.navigateTo(tab: vm.selectedTab, page: .playlist(type: .album, id: id))
                    }
                }else{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        coordinator.navigateTo(tab: vm.selectedTab, page: .playlist(type: .album, id: id))
                    }
                }
            }
            .onReceive(vm.$artistsCount) { recieved in
                guard let count = recieved.publisher.output else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    songBSPresented.toggle()
                    if count > 1 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showArtists.toggle()
                        }
                    }else{
                        songBSPresented = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            coordinator.navigateTo(tab: vm.selectedTab, page: .artist(id: vm.artistId ?? 1))
                        }
                    }
                    
                }
            }
            .onChange(of: playervm.bottomSheetSong?.id) { newValue in
                guard let _ = playervm.bottomSheetSong else { return }
                if !vm.showAddToPlaylist{
                    songBSPresented = !playerPresented
                }
            }
            .onChange(of: vm.playlist?.localId) { newValue in
                guard let _ = vm.playlist else { return }
                showLibraryPlaylist = true
            }
            .onChange(of: vm.popUpType) { newValue in
                if newValue != nil{
                    vm.showPopUp = true
                }
            }
            .onChange(of: playervm.inserted) { newValue in
                if newValue == true{
                    vm.popUpType = .inserted
                }
            }
            if  !(playervm.currentTrack == nil) {
                PlayerView()
                    .environmentObject(coordinator)
                    .onTapGesture {
                        playervm.expand = true
                        withAnimation(Animation.spring(response: 0.35, dampingFraction: 0.85)){
                            vm.expand = true
                        }
                    }
                    .opacity(keyboardIsShown ? 0 : 1)
                    .frame(maxWidth: vm.expand ? .infinity : UIScreen.main.bounds.width - 20, maxHeight: .infinity )
                    .offset(x: 0, y: vm.expand ? vm.offset : UIScreen.main.bounds.height / 2 - 130)
                    .onChange(of: vm.expand) { newValue in
                        if vm.expand {
                            vm.changeOpacity = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                withAnimation(.smooth){
                                    vm.changeOpacity = false
                                }
                            }
                        }
                    }
            }
            if playerPresented || songBSPresented || vm.playlistPresented || addToPlaylistPresented {
                let opacity = 0.3
                Color.bgBlack.opacity(opacity)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 2).delay(12), value: opacity)
            }
        }
        .onChange(of: vpnMonitor.isConnected) { newValue in
            self.vpnConnected = newValue
        }
        .onAppear {
            vpnMonitor.startMonitoring()
        }
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea(.keyboard)
        .popup(isPresented: $vm.showPopUp) {
            HStack{
                Image(vm.popUpType == .successSavingPlaylist ||  vm.popUpType == .errorSavingPlaylistOrItExsists ? "save-playlist" : vm.popUpType == .playlistDeleted  || vm.popUpType == .succesTurnDownOff ? "successDeleted" :  vm.popUpType == .succesTurnDownOn ? "remove-song" : vm.popUpType?.rawValue ?? "")
                    .renderingMode(.template)
                    .foregroundColor(.accentColor)
                    .padding(.leading, 20)
                    .frame(width: 24, height: 24, alignment: .center)
                Text(LocalizedStringKey(vm.popUpType?.rawValue ?? ""))
                    .padding(.leading, 5)
                
                Spacer()
            }
            .zIndex(3)
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(Color.bgLightBlack)
            .cornerRadius(2)
            .padding(.horizontal, 20)
            .padding(.bottom, playervm.currentTrack != nil && !vm.expand ? 120 : 50)
            .onAppear{
                impactMed.impactOccurred()
            }
            .onDisappear{
                vm.showPopUp = false
                if vm.popUpType == .inserted{
                    playervm.inserted = false
                }
                vm.popUpType = nil
            }
        } customize: {
            $0
                .type(.floater())
                .position(.bottom)
                .animation(.spring())
                .closeOnTapOutside(false)
                .isOpaque(false)
                .autohideIn(3)
        }
        .popup(isPresented: $vpnConnected, view: {
            VStack{
                Button{
                    vpnConnected.toggle()
                }label: {
                    ZStack{
                        Circle()
                            .foregroundColor(.black)
                            .frame(width: 30, height: 30)
                        Image("xmark")
                    }
                }
                .frame(maxWidth: .infinity,  alignment: .trailing)
                .padding(.top, 20)
                
                Text(LocalizedStringKey("error"))
                    .font(.bold_22)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 16)
                Text(LocalizedStringKey("vpn_usage_message"))
                    .font(.med_15)
                    .foregroundColor(.textGray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 16)
                Button(action: {
                    vpnConnected.toggle()
                }) {
                    Text(LocalizedStringKey("retry_connection"))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: 48)
                        .background(Color.accentColor)
                        .cornerRadius(4)
                        .font(.bold_16)
                        .foregroundColor(Color.bgBlack)
                }
                .padding(.top, 32)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 20)
            .frame( height: 320)
            .background(Color.bgLightBlack)
            .cornerRadius(32)
        }, customize: {
            $0
                .type (.toast)
                .position(.bottom)
                .dragToDismiss(true)
        })
        .fullScreenCover(isPresented: $showArtists){
            MoreView(song: playervm.bottomSheetSong ?? SongModel.example, isArtists: true) {
                showArtists.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(Animation.spring(response: 0.5, dampingFraction: 0.85)){
                        vm.expand = false
                    }
                }
            }closeButtonCallBack: {
                showArtists.toggle()
                playervm.bottomSheetSong = nil
                
            }
        }
        .fullScreenCover(isPresented: $songBSPresented) {
            MoreView(song: playervm.bottomSheetSong ?? SongModel.example) {
                songBSPresented.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(Animation.spring(response: 0.45, dampingFraction: 0.85)){
                        vm.expand = false
                    }
                }
            }playNext: {
                playervm.addUpToNext(track: playervm.bottomSheetSong ?? SongModel.example, tracklist: nil)
                songBSPresented.toggle()
            } closeButtonCallBack: {
                songBSPresented = false
                playervm.bottomSheetSong = nil
                vm.canShowDelete = false
            }delete: {
                if networkMonitor.isConnected{
                    playlistvm.deleteSong(song: playervm.bottomSheetSong ?? SongModel.example, id: vm.playlistIds["localId"] ?? 1)
                    songBSPresented = false
                    vm.deleted = true
                    libraryVm.postSongsToLibrary(songsId: [playervm.bottomSheetSong?.id ?? 0], playlistId: vm.playlistIds["id"] ?? 1, action: .delete)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        vm.popUpType = .successDeleted
                    }
                    playervm.bottomSheetSong = nil
                }else{
                    songBSPresented = false
                    playervm.bottomSheetSong = nil
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        vm.popUpType = .noConnection
                    }
                }
            }addToPlaylist: {
                songBSPresented = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    vm.playlistPresented.toggle()
                }
            }
        }
        .fullScreenCover(isPresented: $vm.playlistPresented) {
            VStack{
                ScrollView(showsIndicators: false){
                    Spacer(minLength: 40)
                    VStack{
                        KFImage(playervm.bottomSheetSong?.image.url)
                            .placeholder{ Image("cover-img").resizable().scaledToFill().cornerRadius(5)}
                            .fade(duration: 0.25)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 210, height: 210)
                            .cornerRadius(5)
                            .clipped()
                        Text(playervm.bottomSheetSong?.name ?? "")
                            .font(.bold_16)
                            .lineLimit(1)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.top, 10)
                        Text(playervm.bottomSheetSong?.artistName ?? "")
                            .font(.med_15)
                            .lineLimit(1)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    
                    VStack(spacing : 20){
                        let list = AppDatabase.shared.getLocalPlaylists()
                        ForEach(list.enumeratedArray() , id: \.offset){ index, playlist in
                            BottomSheetBtnView(bgColor: Color.moreBg, type: .playlist(playlist: playlist)) {
                                if var song = playervm.bottomSheetSong, let playlistId = playlist.localId {
                                    if networkMonitor.isConnected{
                                        AppDatabase.shared.saveSong(&song, playlistId: playlistId)
                                        vm.popUpType = .successAdded
                                        libraryVm.postSongsToLibrary(songsId: [song.id], playlistId: playlist.id, action: .add)
                                    }else{
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            vm.popUpType = .noConnection
                                        }
                                    }
                                }
                                playervm.bottomSheetSong = nil
                                songBSPresented = false
                                vm.playlistPresented = false
                            }
                        }
                    }
                }
                Button {
                    vm.playlistPresented.toggle()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        addToPlaylistPresented = true
                    }
                } label: {
                    Text(LocalizedStringKey("new_playlist"))
                        .foregroundColor(Color.bgBlack)
                        .font(.bold_16)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.accentColor)
                        .cornerRadius(5)
                }
                Spacer()
                
                Button {
                    playervm.bottomSheetSong = nil
                    vm.playlistPresented = false
                } label: {
                    Text(LocalizedStringKey("close"))
                        .font(.bold_16)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, idealHeight: 50, maxHeight: 50, alignment: .center)
                        .background(Color("DarkBlue"))
                        .cornerRadius(4)
                }
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("MoreBG"))
        }
        .fullScreenCover(isPresented: $addToPlaylistPresented) {
            AddPlaylistView(isPresented: $addToPlaylistPresented)
        }
       
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .preferredColorScheme(.dark)
    }
}



