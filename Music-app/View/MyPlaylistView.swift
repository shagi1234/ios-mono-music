//
//  MyPlaylistView.swift
//  Music-app
//
//  Created by Shirin on 14.10.2023.
//

import SwiftUI
import Resolver
import Kingfisher
import PopupView

struct MyPlaylistView: View {
    @Environment(\.presentationMode) var presentation
    @StateObject var playervm = Resolver.resolve(PlayerVM.self)
    @StateObject var mainVm = Resolver.resolve(MainVM.self)
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @StateObject var vm: PlaylistVM
    @State var deleteAlertPresented = false
    @State var topSafeAreaPadding = 0.0
    @State var opacity = 0.0
    let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        ZStack {
            if let data = vm.localData, vm.localData != nil {
                if let songs = data.songs, !songs.isEmpty {
                    ScrollView {
                        GeometryReader { proxy in
                            var minY = proxy.frame(in: .named("MyPlaylist")).minY
                            let size = proxy.size
                            let height = size.height + minY
                            let headerHeight = topSafeAreaPadding + 60
                            
                            ZStack(alignment: .bottom){
                                if data.cover == nil{
                                    if songs.count > 3 {
                                        VStack(spacing: 0){
                                            HStack(spacing: 0){
                                                KFImage(songs.first?.image.url)
                                                    .placeholder{ Image("cover-img").resizable().scaledToFill()}
                                                    .fade(duration: 0.25)
                                                    .resizable()
                                                    .scaledToFill()
                                                KFImage(songs[1].image.url)
                                                    .placeholder{ Image("cover-img").resizable().scaledToFill()}
                                                    .fade(duration: 0.25)
                                                    .resizable()
                                                    .scaledToFill()
                                            }
                                            HStack(spacing: 0){
                                                KFImage(songs[2].image.url)
                                                    .placeholder{ Image("cover-img").resizable().scaledToFill()}
                                                    .fade(duration: 0.25)
                                                    .resizable()
                                                    .scaledToFill()
                                                KFImage(songs[3].image.url)
                                                    .placeholder{ Image("cover-img").resizable().scaledToFill()}
                                                    .fade(duration: 0.25)
                                                    .resizable()
                                                    .scaledToFill()
                                            }
                                        }
                                    }else{
                                        KFImage(songs.first?.image.url)
                                            .placeholder{ Image("cover-img").resizable().scaledToFill()}
                                            .fade(duration: 0.25)
                                            .resizable()
                                            .scaledToFill()
                                    }
                                }else{
                                    KFImage(data.cover?.url)
                                        .placeholder{ Image("cover-img").resizable().scaledToFill()}
                                        .fade(duration: 0.25)
                                        .resizable()
                                        .scaledToFill()
                                }
                                LinearGradient(colors: [.clear, Color.bgBlack], startPoint: .top, endPoint: .bottom)
                                
                            }.frame(width: size.width, height: max(height, 0), alignment: .top)
                                .cornerRadius(1)
                                .offset(y: -minY)
                                .onAppear {
                                    topSafeAreaPadding = max(minY, topSafeAreaPadding)
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
                                        
                                        if data.type == "album" {
                                            Text("\(data.albumArtist ?? "")  -  \(String(data.year ?? 0))")
                                                .foregroundColor(.textGray)
                                                .font(.reg_15)
                                                .frame(maxWidth: .infinity, alignment: .center)
                                                .lineLimit(1)
                                        }
                                    }
                                    .padding(.leading, height < (headerHeight + 16) ? 48 : 0)
                                    .padding(20)
                                }
                            }
                            .onChange(of: height) { newValue in
                                if newValue < headerHeight {
                                    withAnimation{
                                        opacity = 1
                                        minY = size.height
                                    }
                                } else {
                                    opacity = 0
                                }
                            }
                        }
                        .frame(height: UIScreen.main.bounds.width - 100)
                        .buttonStyle(.plain)
                        HStack {
                            Button {
                                if !networkMonitor.isConnected && (songs.first(where: {$0.localPath != nil}) != nil){
                                    playervm.create(index: 0, tracks: songs, tracklist: data)
                                }else if networkMonitor.isConnected{
                                    playervm.create(index: 0, tracks: songs, tracklist: data)
                                }else{
                                    
                                }
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
                            }.pressAnimation()
                            
                            Button {
                                if !networkMonitor.isConnected && (songs.first(where: {$0.localPath != nil}) != nil) && playervm.data.isEmpty{
                                    playervm.create(index:  playervm.data.isEmpty ? Int.random(in: 0..<(data.count ?? 0)) : playervm.playIndex, tracks: data.songs ?? [], tracklist: data)
                                    playervm.shufflePlaylist()
                                }else if  !playervm.data.isEmpty{
                                    if playervm.shuffled{
                                        playervm.unShufflePlaylist()
                                    }else{
                                        playervm.shufflePlaylist()
                                    }
                                }else if networkMonitor.isConnected && playervm.data.isEmpty{
                                    playervm.create(index: Int.random(in: 0..<(data.count ?? 0)), tracks: data.songs ?? [], tracklist: data)
                                    if playervm.shuffled{
                                        playervm.unShufflePlaylist()
                                    }else{
                                        playervm.shufflePlaylist()
                                    }
                                }
                                
                            } label: {
                                HStack {
                                    Image("shuffle-24")
                                        .renderingMode(.template)
                                        .foregroundColor(playervm.shuffled ? .accentColor : .white)
                                    
                                }.frame(maxWidth: 34, maxHeight: 34, alignment: .center)
                                    .background(Color.bgLightBlack)
                                    .cornerRadius(3)
                            }.pressAnimation()
                            
                            Spacer()
                            if let index = mainVm.downloadingPlaylist?.firstIndex(where: { $0.localId == data.localId && $0.isDownloadOn == true }), mainVm.downloadError {
                                if (mainVm.downloadingPlaylist?[index]) != nil {
                                    Button {
                                        DownloadManager.shared.restartDownload()
                                    } label: {
                                        Image("restart")
                                            .resizable()
                                            .renderingMode(.template)
                                            .foregroundColor(.white)
                                            .frame(width: 18, height: 18, alignment: .center)
                                    }.pressAnimation()
                                    .frame(maxWidth: 34, maxHeight: 34, alignment: .center)
                                    .background(Color.bgLightBlack)
                                    .cornerRadius(3)
                                }
                            }
                          
                            Button {
                                if vm.isDownloadOn {
                                    deleteAlertPresented = true
                                } else {
                                    vm.turnDownloadOn()
                                }
                            } label: {
                                Image(vm.isDownloadOn ? "remove-song" : "download-song")
                                    .resizable()
                                    .renderingMode(.template)
                                    .foregroundColor(.white)
                                    .frame(width: 18, height: 18, alignment: .center)
                                   
                            }.pressAnimation()
                            .frame(maxWidth: 34, maxHeight: 34, alignment: .center)
                            .background(Color.bgLightBlack)
                            .cornerRadius(3)
                          
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20)
                        
                       
                        LazyVStack{
                            ForEach(songs.enumeratedArray(), id: \.offset) { ind, i in
                                SongItem(data: i, current: playervm.currentTrack?.id == i.id, isPlaying: playervm.isPlaying(), isAlbum: data.type == "album" ? true : false, index: ind + 1, disabled: !networkMonitor.isConnected && AppDatabase.shared.getSong(id: i.id)?.localPath == nil, onMore: {
                                    playervm.bottomSheetSong = i
                                    mainVm.playlistIds["localId"] = data.localId
                                    mainVm.playlistIds["id"] = data.id
                                    if data.type == "local"{
                                        mainVm.canShowDelete = true
                                    }else{
                                        mainVm.canShowDelete = false
                                    }
                                },drag:{
                                    playervm.addUpToNext(track: i, tracklist: nil)
                                })
                                .padding(.leading, 20)
                                .pressWithAnimation {
                                    if networkMonitor.isConnected {
                                        playervm.create(index: ind, tracks: songs, tracklist: data)
                                    }else if !networkMonitor.isConnected && AppDatabase.shared.getSong(id: i.id)?.localPath != nil{
                                        playervm.create(index: ind, tracks: songs, tracklist: data)
                                    }
                                }
                            }
                        }
                        Spacer().frame(height: 70)
                    }
                }
                else {
                    Text(LocalizedStringKey("empty"))
                        .foregroundColor(.white)
                        .font(.bold_16)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                }
            } else if vm.noConnection {
                NoConnectionView {
                    vm.getData()
                }
            } else if vm.inProgress {
                AppLoadingView()
            }
        }
        .onChange(of: vm.alertPresented) { newValue in
            mainVm.popUpType = .successSavingPlaylist
        }
        .onChange(of: vm.isDownloadOn) { newValue in
            if newValue == false{
                mainVm.popUpType = .succesTurnDownOff   
            }else{
                mainVm.popUpType = .succesTurnDownOn
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
                    }.pressAnimation()
                    
                    Button{
                        vm.turnDownloadOff()
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
        .onChange(of: mainVm.deleted) { _ in
            vm.getData()
            mainVm.deleted = false
        }
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
                }).pressAnimation()
                
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
        .offset(y: -topSafeAreaPadding ))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgBlack)
        .navigationBarBackButtonHidden()
    }
}

struct MyPlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        MyPlaylistView(vm: .init(type: .local, id: 1))
    }
}
