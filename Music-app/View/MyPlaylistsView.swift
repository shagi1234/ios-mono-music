//
//  MyPlaylistsView.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 15.08.2023.
//

import SwiftUI
import Resolver
import PopupView


struct MyPlaylistsView: View {
    @EnvironmentObject var coordinator: Coordinator
    @StateObject var mainVm = Resolver.resolve(MainVM.self)
    @StateObject var libraryVm = Resolver.resolve(LibraryVM.self)
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @StateObject var vm = MyPlaylistsVM()
    @State var addPlaylistPresented = false
    @State var playlistBSPresented = false
    @State var deleteAlertPresented = false
    @State var likedSongsCount = 0
    @State var localPlaylist : PlaylistModel?
    @State var addPlaylistViewId = UUID().uuidString
    @State var activeTabType: MediaType = .all
    let impactMed = UIImpactFeedbackGenerator(style: .medium)
    @State var exampleSong: SongModel? = SongModel.example
    
    var body: some View {
        VStack(spacing: 0) {
            MyPlaylistsHeader {
                addPlaylistPresented = true
            }
            
            ScrollViewReader{ reader in
                ScrollView(.horizontal, showsIndicators: false){
                    HStack{
                        Spacer()
                            .frame(width: 20)
                        
                        ForEach(MediaType.allCases, id: \.self){  item in
                            Button {
                                activeTabType = item
                                impactMed.impactOccurred()
                            } label: {
                                Text(LocalizedStringKey(item.rawValue))
                                    .font(.med_15)
                                    .foregroundColor(item == activeTabType ?  .black : .white)
                                    .padding(.horizontal, 20)
                                    .frame(height: 34, alignment: .center)
                                    .background(item == activeTabType ? Color.accentColor : Color.bgLightBlack)
                                    .cornerRadius(3)
                            }.pressAnimation()
                                .padding(.trailing, 1)
                        }
                        Spacer()
                            .frame(width: 20)
                    }
                }
                .padding(.bottom)
                .onChange(of: activeTabType) { newValue in
                    withAnimation(.bouncy){
                        reader.scrollTo(newValue, anchor: .center)
                    }
                }
            }
            
            TabView(selection: $activeTabType){
                ForEach(MediaType.allCases, id: \.self) { item in
                    if !vm.playlists.isEmpty {
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                
                                if item == .all {
                                    Button {
                                        coordinator.navigateTo(tab: 2, page: .likedSongs)
                                    } label: {
                                        FavoritesItem(songCount: likedSongsCount)
                                    }.pressAnimation()
                                }
                                
                                ForEach(vm.playlists, id: \.localId) { playlist in
                                    switch item {
                                    case .albums:
                                        if playlist.type == "album" {
                                            Button {
                                                coordinator.navigateTo(tab: 2, page: .myPlaylist(id: playlist.localId!))
                                            } label: {
                                                PlaylistItem(data: playlist) {
                                                    if playlist.type == "local" {
                                                        mainVm.playlist   =  vm.getLocalData(id: playlist.localId ?? 1)
                                                    } else {
                                                        mainVm.playlist = playlist
                                                    }
                                                    
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                        playlistBSPresented.toggle()
                                                    }
                                                    
                                                    impactMed.impactOccurred()
                                                }
                                            }.pressAnimation()
                                        }
                                    case .playlists:
                                        if playlist.type == "top" || playlist.type == "playlist" || playlist.type == "local" {
                                            Button {
                                                coordinator.navigateTo(tab: 2, page: .myPlaylist(id: playlist.localId!))
                                            } label: {
                                                PlaylistItem(data: playlist) {
                                                    if playlist.type == "local" {
                                                        mainVm.playlist   =  vm.getLocalData(id: playlist.localId ?? 1)
                                                    }else{
                                                        mainVm.playlist = playlist
                                                    }
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                        playlistBSPresented.toggle()
                                                    }
                                                    impactMed.impactOccurred()
                                                }
                                            }.pressAnimation()
                                        }
                                        
                                    case .all:
                                        Button {
                                            coordinator.navigateTo(tab: 2, page: .myPlaylist(id: playlist.localId!))
                                        } label: {
                                            PlaylistItem(data: playlist) {
                                                
                                                if playlist.type == "local" {
                                                    mainVm.playlist   =  vm.getLocalData(id: playlist.localId ?? 1)
                                                } else {
                                                    mainVm.playlist = playlist
                                                }
                                                
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                    playlistBSPresented.toggle()
                                                }
                                                
                                                impactMed.impactOccurred()
                                            }
                                        }.pressAnimation()
                                            .onAppear{
                                                if vm.playlists.last?.id == playlist.id && vm.canLoadMore {
                                                    vm.getMyPlaylists(page: vm.page + 1)
                                                }
                                            }
                                    case .downloaded:
                                        if playlist.isDownloadOn ?? false{
                                            Button {
                                                coordinator.navigateTo(tab: 2, page: .myPlaylist(id: playlist.localId!))
                                            } label: {
                                                PlaylistItem(data: playlist) {
                                                    if playlist.type == "local" {
                                                        mainVm.playlist   =  vm.getLocalData(id: playlist.localId ?? 1)
                                                    }else{
                                                        mainVm.playlist = playlist
                                                    }
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                        playlistBSPresented.toggle()
                                                    }
                                                    impactMed.impactOccurred()
                                                }
                                            }.pressAnimation()
                                        }
                                    }
                                }
                            }.padding(.horizontal, 20)
                            
                            Spacer().frame(height: 100)
                        }
                    } else {
                        VStack {
                            Text(LocalizedStringKey("no_playlists_saved_yet"))
                                .foregroundColor(.white)
                                .font(.bold_16)
                                .padding(.bottom, 30)
                            
                            Button {
                                addPlaylistPresented = true
                            } label: {
                                Text(LocalizedStringKey("add_playlist"))
                                    .foregroundColor(Color.bgBlack)
                                    .font(.med_15)
                                    .padding(.horizontal, 20)
                            }.pressAnimation()
                                .frame(height: 50)
                                .background(Color.accentColor)
                                .cornerRadius(10)
                        }.frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgBlack)
        .popup(isPresented: $deleteAlertPresented) {
            VStack(alignment: .center){
                Text(LocalizedStringKey("are_you_sure_to_delete_playlist"))
                    .font(.bold_14)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                
                
                HStack{
                    Button{
                        deleteAlertPresented.toggle()
                    }label:{
                        Text(LocalizedStringKey("cancel"))
                            .font(.bold_14)
                            .foregroundColor(.white)
                            .frame(width: 107, height: 30, alignment: .center)
                            .padding(.trailing, 8)
                    }
                    
                    Button{
                        vm.deletePlaylist(localId: mainVm.playlist?.localId ?? 0, id: mainVm.playlist?.id ?? 0)
                        if  mainVm.playlist?.type == "local"{
                            libraryVm.postCustomPlaylistToLibrary(playlist: mainVm.playlist ?? PlaylistModel.example, action: .delete)
                        } else if  mainVm.playlist?.type == "album"{
                            libraryVm.postAlbumToLibrary(albumId: mainVm.playlist?.id ?? 0, action: .delete)
                        }else{
                            libraryVm.postPlaylistToLibrary(playlistId: mainVm.playlist?.id ?? 0, action: .delete)
                        }
                        mainVm.playlist = nil
                        deleteAlertPresented.toggle()
                    }label:{
                        Text(LocalizedStringKey("delete"))
                            .font(.bold_14)
                            .foregroundColor(.redCustom)
                            .frame(width: 107, height: 30, alignment: .center)
                    }.pressAnimation()
                }
            }
            .frame( height: 128, alignment: .center)
            .frame(width: 290, alignment: .center)
            .background(Color.bgBlack)
            .cornerRadius(4)
            .padding(.horizontal, 38)
        } customize: {
            $0
                .type(.default)
                .position(.center)
                .animation(.spring())
                .closeOnTapOutside(true)
                .backgroundColor(.black.opacity(0.5))
        }
        .fullScreenCover(isPresented: $playlistBSPresented) {
            MoreView(song: $exampleSong, playlist: mainVm.playlist, isPLaylist: true) {
                playlistBSPresented.toggle()
            } playNext: {
                
            } closeButtonCallBack: {
                playlistBSPresented.toggle()
            } addToPlaylist: {
                
            }deletePlaylist: {
                if networkMonitor.isConnected{
                    playlistBSPresented = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                        self.deleteAlertPresented = true
                    }
                }else{
                    playlistBSPresented = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        mainVm.popUpType = .noConnection
                    }
                }
            }
            editPLaylist: {
                addPlaylistViewId = UUID().uuidString
                playlistBSPresented = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                    self.addPlaylistPresented = true
                }
            }downloadOrDeleteSongs: {
                if  mainVm.playlist?.isDownloadOn == true {
                    vm.turnDownloadOff(localId:  mainVm.playlist?.localId ?? 0)
                } else {
                    vm.turnDownloadOn(localId:  mainVm.playlist?.localId ?? 0)
                }
                playlistBSPresented = false
                mainVm.playlist = nil
            }
        }
        .fullScreenCover(isPresented: $addPlaylistPresented, onDismiss: {
            mainVm.playlist = nil
            vm.getData()
        }, content: {
            AddPlaylistView(isPresented: $addPlaylistPresented, playlist: mainVm.playlist, name: mainVm.playlist?.name ?? "")
        }).id(addPlaylistViewId)
            .onAppear{
                libraryVm.getFavSongsCount()
                vm.getData()
                vm.getMyPlaylists(page:  vm.page)
            }
            .onReceive(libraryVm.$likedSongsCount) {
                likedSongsCount = $0
            }
    }
}

struct MyPlaylistsView_Previews: PreviewProvider {
    static var previews: some View {
        MyPlaylistsView()
            .preferredColorScheme(.dark)
    }
}
