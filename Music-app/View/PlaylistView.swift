//
//  PlaylistView.swift
//  Music-app
//
//  Created by Shirin on 21.09.2023.
//

import SwiftUI
import Kingfisher
import Resolver
import PopupView

struct PlaylistView: View {
    @Environment(\.presentationMode) var presentation
    @StateObject var playervm = Resolver.resolve(PlayerVM.self)
    @StateObject var mainVm = Resolver.resolve(MainVM.self)
    @StateObject var libraryVm = Resolver.resolve(LibraryVM.self)
    @StateObject var vm: PlaylistVM
    @State var deleteAlertPresented = false
    @State var topSafeAreaPadding = 0.0
    @State var opacity = 0.0
    let screenWidth = UIScreen.main.bounds.width
    @State private var visibleRows: [Int] = []
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @EnvironmentObject var coordinator: Coordinator
    let impactMed = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        ZStack {
            if let data = vm.data {
                ScrollView {
                    GeometryReader { proxy in
                        let minY = proxy.frame(in: .named("SCROLL")).minY
                        let size = proxy.size
                        let height = max(size.height + minY, 0)
                        let headerHeight = topSafeAreaPadding + 60
                        
                        ZStack(alignment: .bottom){
                            KFImage(data.image?.url)
                                .placeholder{ Image("cover-img").resizable().scaledToFill()}
                                .fade(duration: 0.25)
                                .resizable()
                                .scaledToFill()
                            LinearGradient(colors: [.clear, Color.bgBlack], startPoint: .top, endPoint: .bottom)
                        }.frame(width: size.width, height: max(height, 0), alignment: .top)
                            .cornerRadius(0)
                            .offset(y: -minY)
                            .onAppear {
                                topSafeAreaPadding = Double(UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
                                opacity = 0
                                print("topSafeAreaPadding : \(topSafeAreaPadding)")
                            }
                        
                        
                        VStack {
                            Spacer()
                            HStack {
                                VStack {
                                    Text(data.name)
                                        .foregroundColor(.white)
                                        .font(.bold_35)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                    
                                    if vm.type == .album {
                                        Spacer()
                                            .frame(height: 2)
                                        let name = data.artists?.map({$0.name}).joined(separator: ", ") ?? ""
                                        Button{
                                            coordinator.navigateTo(tab: mainVm.selectedTab, page: .artist(id: data.artists?.first?.id ?? 0))
                                        }label:{
                                            Text(name + " - " + String(data.year ?? 0))
                                                .foregroundColor(.textGray)
                                                .font(.reg_15)
                                                .frame(maxWidth: .infinity, alignment: .center)
                                                .lineLimit(1)
                                        }
                                    }
                                }
                                .padding(.leading, height < (headerHeight + 16) ? 48 : 0)
                                .padding(20)
                            }
                        }
                        .onChange(of: height) { newValue in
                            let newOpacity: Double = newValue < headerHeight ? 1 : 0
                            if opacity != newOpacity {
                                withAnimation {
                                    opacity = newOpacity
                                }
                            }
                        }
                    }.frame(height: UIScreen.main.bounds.width - 100)
                        .buttonStyle(.plain)
                    
                    HStack {
                        Button {
                            playervm.create(index: 0, tracks: data.songs ?? [], tracklist: data)
                        } label: {
                            HStack {
                                Image(systemName: "play.fill")
                                    .foregroundColor(.accentColor)
                                
                                Text(LocalizedStringKey("play_all"))
                                    .font(.bold_16)
                                    .foregroundColor(.accentColor)
                            }
                            .frame( idealHeight: 34, maxHeight: 34, alignment: .center)
                            .padding(.horizontal, 10)
                            .background(Color.bgLightBlack)
                            .cornerRadius(3)
                            .padding(.vertical, 10)
                        }
                        
                        Button {
                            if playervm.data.isEmpty {
                                playervm.create(index: Int.random(in: 0..<(data.count ?? 0)), tracks: data.songs ?? [], tracklist: data)
                                playervm.shufflePlaylist()
                                print("created")
                            }else{
                                if playervm.shuffled {
                                    playervm.unShufflePlaylist()
                                }else{
                                    playervm.shufflePlaylist()
                                }
                                print("else")
                            }
                        } label: {
                            HStack {
                                Image("shuffle-24")
                                    .renderingMode(.template)
                                    .foregroundColor(playervm.shuffled ? .accentColor : .white)
                                
                            }.frame(maxWidth: 34, maxHeight: 34, alignment: .center)
                                .background(Color.bgLightBlack)
                                .cornerRadius(3)
                        }
                        Spacer()
                        Button {
                            if vm.isSaved {
                                deleteAlertPresented.toggle()
                            } else {
                                vm.savePlaylist()
                                
                                if vm.isSaved{
                                    if vm.type == .album{
                                        libraryVm.postAlbumToLibrary(albumId: data.id, action: .add)
                                    }else{
                                        libraryVm.postPlaylistToLibrary(playlistId: data.id, action: .add)
                                    }
                                }
                            }
                            impactMed.impactOccurred()
                        } label: {
                            if vm.succesfullyDownload{
                                ProgressView()
                            }else{
                                Image(vm.isSaved ? "delete-playlist" : "save-playlist")
                                    .renderingMode(.template)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: 34, maxHeight: 34, alignment: .center)
                        .background(Color.bgLightBlack)
                        .cornerRadius(3)
                        
                        .disabled(vm.succesfullyDownload)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)
                    
                    if let songs = data.songs, !songs.isEmpty {
                        LazyVStack{
                            ForEach(songs.enumeratedArray(), id:  \.offset) { ind, i in
                                SongItem(data: i, current: playervm.currentTrack?.id == i.id, isPlaying: playervm.isPlaying(), isAlbum: vm.type == .album ? true : false, index: ind + 1, disabled : !networkMonitor.isConnected && AppDatabase.shared.getSong(id: i.id)?.localPath == nil, onMore: {
                                    playervm.bottomSheetSong = i
                                }, drag: {
                                    playervm.addUpToNext(track: i, tracklist: nil)
                                })
                                
                                .onTapGesture {
                                    if networkMonitor.isConnected {
                                        playervm.create(index: ind, tracks: songs, tracklist: data)
                                    }else if !networkMonitor.isConnected && AppDatabase.shared.getSong(id: i.id)?.localPath != nil{
                                        playervm.create(index: ind, tracks: songs, tracklist: data)
                                    }
                                    
                                }
                            }
                            .padding(.leading, 20)
                        }
                    }
                    
                    similarSection
                    
                    Spacer()
                        .frame(height: 75)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if vm.noConnection {
                NoConnectionView {
                    vm.getData()
                }
            } else if vm.inProgress {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgBlack)
        .overlay(VStack(spacing: 0, content: {
            Rectangle()
                .fill(Color.bgBlack.opacity(opacity))
                .frame(height: topSafeAreaPadding)
            
            HStack(content: {
                Button(action: {
                    presentation.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40, alignment: .center)
                })
                
                Text(LocalizedStringKey(vm.data?.name ?? ""))
                    .foregroundColor(.white)
                    .font(.bold_22)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .opacity(opacity)
                
                Spacer()
            }).padding(.horizontal, 20)
                .frame(maxWidth: screenWidth)
                .background(Color.bgBlack.opacity(opacity))
            
            Spacer()
        })
            .offset(y: -topSafeAreaPadding))
        .navigationBarBackButtonHidden()
        .onChange(of: vm.alertPresented) { newValue in
            mainVm.popUpType = .successSavingPlaylist
        }
        .onChange(of: vm.playlistDeleted) { newValue in
            if newValue{
                mainVm.popUpType = .playlistDeleted
            }else{
                mainVm.popUpType = .errorSavingPlaylistOrItExsists
            }
        }
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
                        vm.deletePlaylist()
                        deleteAlertPresented.toggle()
                        if vm.type == .album{
                            libraryVm.postAlbumToLibrary(albumId: vm.data?.id ?? 0, action: .delete)
                        }else{
                            libraryVm.postPlaylistToLibrary(playlistId: vm.data?.id ?? 0, action: .delete)
                        }
                    }label:{
                        Text(LocalizedStringKey("delete"))
                            .font(.bold_14)
                            .foregroundColor(.redCustom)
                            .frame(width: 107, height: 30, alignment: .center)
                    }
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
    }
    
    private var similarSection: some View {
        Group {
            if let similar = vm.similar, !similar.isEmpty {
                VStack(alignment: .leading, spacing: 20) {
                    Text(LocalizedStringKey(vm.type == .album ? "similar_albums" : "similar_playlists"))
                        .font(.bold_22)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            ForEach(similar.enumeratedArray(), id: \.offset){ ind,playlist in
                                Button {
                                    coordinator.navigateTo(tab: mainVm.selectedTab, page: .playlist(type: .simple, id: Int64(playlist.id)))
                                } label: {
                                    PlaylistGridItem(data: playlist)
                                        .padding(.leading, ind != 0 ? 0 : 20)
                                        .padding(.trailing, ind+1 != similar.count ? 0 : 20)
                                }
                            }
                        }
                    }
                }.padding(.vertical, 20)
            } else {
                EmptyView()
            }
        }
    }
}



struct PlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistView(vm: PlaylistVM(type: .simple, id: 1))
            .preferredColorScheme(.dark)
    }
}




