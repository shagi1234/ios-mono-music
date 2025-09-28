//
//  ArtistView.swift
//  Music-app
//
//  Created by Shirin on 29.09.2023.
//

import SwiftUI
import Kingfisher
import Resolver

struct ArtistView: View {
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @EnvironmentObject var coordinator: Coordinator
    @StateObject var playervm = Resolver.resolve(PlayerVM.self)
    @StateObject var mainVm = Resolver.resolve(MainVM.self)
    @StateObject var vm: ArtistVM
    @State var topSafeAreaPadding = 0.0
    @State var opacity = 0.0
    @State var hasLateRelease = false
    
    
    var body: some View {
        VStack {
            ZStack {
                if let data = vm.data {
                    ScrollView {
                        GeometryReader{ proxy in
                            var minY = proxy.frame(in: .named("SCROLL")).minY
                            let size = proxy.size
                            let height = size.height + minY
                            let headerHeight = topSafeAreaPadding + 60
                            ZStack(alignment: .bottom){
                                KFImage(data.image.url)
                                    .placeholder{ Image("cover-img").resizable().scaledToFill().cornerRadius(1)}
                                    .fade(duration: 0.25)
                                    .resizable()
                                    .scaledToFill()
                                
                                LinearGradient(colors: [.clear, Color.bgBlack], startPoint: .top, endPoint: .bottom)
                                
                            }.frame(width: size.width, height: max(height, 0), alignment: .top)
                                .cornerRadius(1)
                                .offset(y: -minY)
                                .onAppear{
                                    topSafeAreaPadding = max(minY, topSafeAreaPadding)
                                }
                            
                            VStack {
                                Spacer()
                                
                                HStack {
                                    
                                    Text(data.name)
                                        .foregroundColor(.white)
                                        .font(.bold_35)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(2)
                                        .padding(.vertical, 20)
                                        .padding(.leading, height < (headerHeight + 16) ? 48 : 20)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        if let songs = data.songs, !songs.isEmpty {
                                            if networkMonitor.isConnected {
                                                playervm.create(index: 0, tracks: songs, tracklist: nil)
                                            } else {
                                                let availableSongs = songs.filter { song in
                                                    AppDatabase.shared.getSong(id: song.id)?.localPath != nil
                                                }
                                                if !availableSongs.isEmpty {
                                                    playervm.create(index: 0, tracks: availableSongs, tracklist: nil)
                                                }
                                            }
                                        }
                                    }) {
                                        Image(systemName: "play.fill")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(.black)
                                            .frame(width: 60, height: 60)
                                            .background(Color.orange)
                                            .clipShape(Circle())
                                    }
                                    .pressAnimation()
                                    .disabled(data.songs?.isEmpty ?? true)
                                    .padding(.trailing, 20)
                                    .padding(.bottom, 10)
                                }
                                
                            }.onChange(of: height) { newValue in
                                if height < headerHeight {
                                    withAnimation{
                                        opacity = 1
                                        minY = size.height
                                    }
                                } else {
                                    opacity = 0
                                }
                            }
                        }.frame(height: UIScreen.main.bounds.width - 100)
                        
                        
                        if let latestRelease = data.latestRelease, latestRelease.song != nil || latestRelease.album != nil{
                            LatestRelease(latestRelese: latestRelease, isAlbum: latestRelease.album != nil){
                                if latestRelease.album != nil{
                                    mainVm.albumId = latestRelease.album?.id
                                }else if latestRelease.song != nil{
                                    playervm.create(index: 0, tracks: [latestRelease.song!], tracklist: nil)
                                    
                                }else{
                                    mainVm.albumId = latestRelease.album?.id
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 30)
                        }
                        
                        if let songs = data.songs, !songs.isEmpty {
                            HStack{
                                Text(LocalizedStringKey("top_songs"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                                    .font(.bold_22)
                                    .foregroundColor(.white)
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color.accentColor)
                                    .padding(.trailing, 20)
                            }
                            .frame(height: 24)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 12)
                            .contentShape(Rectangle())
                            .pressWithAnimation {
                                coordinator.navigateTo(tab: mainVm.selectedTab, page: .seeAll(type: .songs, id: data.id, artistName: data.name ))
                            }
                            ForEach(songs.prefix(6).enumeratedArray(), id: \.offset) { ind, i in
                                
                                SongItem(data: i, current: playervm.currentTrack?.id == i.id, isPlaying: playervm.isPlaying(), onMore: {
                                    playervm.bottomSheetSong = i
                                }, drag: {
                                    playervm.addUpToNext(track: i, tracklist: nil)
                                })
                                .pressWithAnimation {
                                    if networkMonitor.isConnected {
                                        playervm.create(index: ind, tracks: songs, tracklist: nil)
                                    }else if !networkMonitor.isConnected && AppDatabase.shared.getSong(id: i.id)?.localPath != nil{
                                        playervm.create(index: ind, tracks: songs, tracklist: nil)
                                    }
                                    
                                }
                            }
                            .padding(.leading, 20)
                            
                        }
                        
                        if let albums = data.albums, !albums.isEmpty {
                            ScrollableHStack(title: "albums_and_EP", isAllButton: true, spacing: 0) {
                                coordinator.navigateTo(tab: mainVm.selectedTab, page: .seeAll(type: .albums, id: data.id, artistName: data.name ))
                            } content: {
                                ForEach(albums.prefix(6).enumeratedArray(), id: \.offset) { ind, i in
                                    Button {
                                        coordinator.navigateTo(tab: mainVm.selectedTab, page: .playlist(type: .album, id: i.id))
                                    } label: {
                                        AlbumGridItem(data: i)
                                            .padding(.leading, ind != 0 ? 0 : 20)
                                            .padding(.trailing, ind + 1 != albums.count ? 0 : 20)
                                    }.pressAnimation()
                                }
                            }
                            .padding(.top, 30)
                        }
                        
                        if let songs = data.singles, !songs.isEmpty {
                            HStack{
                                Text(LocalizedStringKey("singles"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(1)
                                    .font(.bold_22)
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color.accentColor)
                                    .padding(.trailing, 20)
                            }
                            .frame(height: 24)
                            .padding(.horizontal, 20)
                            .padding(.top, 30)
                            .padding(.bottom, 12)
                            .contentShape(Rectangle())
                            .pressWithAnimation {
                                coordinator.navigateTo(tab: mainVm.selectedTab, page: .seeAll(type: .singles, id: data.id, artistName: data.name ))
                            }
                            ForEach(songs.enumeratedArray(), id:  \.offset) { ind, i in
                                SongItem(data: i, current: playervm.currentTrack?.id == i.id, isPlaying: playervm.isPlaying(),  index: ind + 1, disabled : !networkMonitor.isConnected && AppDatabase.shared.getSong(id: i.id)?.localPath == nil, onMore: {
                                    playervm.bottomSheetSong = i
                                }, drag: {
                                    playervm.addUpToNext(track: i, tracklist: nil)
                                })
                                .id(i.id)
                                .pressWithAnimation {
                                    if networkMonitor.isConnected {
                                        playervm.create(index: ind, tracks: songs, tracklist: nil)
                                    }else if !networkMonitor.isConnected && AppDatabase.shared.getSong(id: i.id)?.localPath != nil{
                                        playervm.create(index: ind, tracks: songs, tracklist: nil)
                                    }
                                }
                                .padding(.leading, 20)
                            }
                            
                            if let similarArtists = vm.similarArtists, !similarArtists.isEmpty {
                                VStack(alignment: .leading, spacing: 20) {
                                    Text(LocalizedStringKey("similar_artists"))
                                        .font(.bold_22)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 15) {
                                            ForEach(similarArtists.prefix(10), id: \.id) { artist in
                                                Button {
                                                    coordinator.navigateTo(tab: mainVm.selectedTab, page: .artist(id: artist.id))
                                                } label: {
                                                    CircularArtistItem(data: artist)
                                                }.pressAnimation()
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                    }
                                }
                                .padding(.vertical, 20)
                            }
                            
                        }
                        Spacer().frame(height: 75)
                    }
                } else if vm.noConnection {
                    NoConnectionView {
                        vm.getData()
                    }
                } else if vm.inProgress {
                    AppLoadingView()
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
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
                        
                        Text(vm.data?.name ?? "")
                            .foregroundColor(.white)
                            .font(.bold_22)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(1)
                            .opacity(opacity)
                        
                        Spacer()
                    }).padding(.horizontal, 20)
                        .background(Color.bgBlack.opacity(opacity))
                    
                    
                    Spacer()
                }).offset(y: -topSafeAreaPadding))
        }
        .background(Color.bgBlack)
        .navigationBarBackButtonHidden()
    }
}

struct ArtistView_Previews: PreviewProvider {
    static var previews: some View {
        ArtistView(vm: ArtistVM(id: 31))
            .preferredColorScheme(.dark)
    }
}
