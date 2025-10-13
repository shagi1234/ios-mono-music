//
//  HomeView.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 15.08.2023.
//

import SwiftUI
import Resolver
import NavigationStackBackport

struct HomeView: View {
    @EnvironmentObject var coordinator: Coordinator
    @StateObject var mainVm = Resolver.resolve(MainVM.self)
    @StateObject var vm = HomeVM()
    @StateObject var playervm  = Resolver.resolve(PlayerVM.self)
    @EnvironmentObject var networkMonitor: NetworkMonitor
    var date : String = ""
    var body: some View {
        VStack(spacing: 0) {
            HomeHeader()
                .frame(height: 60)
            ZStack {
                if let data = vm.data {
                    ScrollView(showsIndicators: false) {
                        
                        if !data.hitSongs.isEmpty {
                            VStack(spacing: 10) {
                                HStack{
                                    Text(LocalizedStringKey("hit_songs"))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(1)
                                        .font(.bold_22)
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 20)
                                let rows = [
                                    GridItem(.fixed(60)),
                                    GridItem(.fixed(60)),
                                    GridItem(.fixed(60)),
                                    GridItem(.fixed(60))
                                ]
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHGrid(rows: rows, alignment: .top, spacing: 10) {
                                        ForEach(data.hitSongs.enumeratedArray(), id: \.offset) { ind, i in
                                            SongItem(data: i,
                                                     current: playervm.currentTrack?.id == i.id ,
                                                     isPlaying: playervm.isPlaying(),
                                                     disabled: !networkMonitor.isConnected && AppDatabase.shared.getSong(id: i.id)?.localPath == nil,
                                                     onMore: {
                                                playervm.bottomSheetSong = i
                                            }, onTap: {
                                                if networkMonitor.isConnected {
                                                    playervm.create(index: ind, tracks: data.hitSongs, tracklist: nil)
                                                }else if !networkMonitor.isConnected && AppDatabase.shared.getSong(id: i.id)?.localPath != nil{
                                                    playervm.create(index: ind, tracks: data.hitSongs, tracklist: nil)
                                                }
                                            }
                                            ).frame(width: UIScreen.main.bounds.width - 80)
                                        }
                                    }
                                    .frame(height: 300)
                                    .padding(.horizontal, 20)
                                }
                            }.padding(.bottom, 20)
                        }
                        
                        if !data.topPlaylists.isEmpty {
                            ScrollableHStack(title: "top_playlists", spacing: 0) {
                                
                            } content: {
                                ForEach(data.topPlaylists.enumeratedArray(), id: \.offset) { ind, i in
                                    Button {
                                        coordinator.navigateTo(tab: mainVm.selectedTab, page: .playlist(type: .top, id: i.id))
                                    } label: {
                                        PlaylistGridItem(data: i)
                                            .padding(.leading, ind != 0 ? 0 : 20)
                                            .padding(.trailing, ind+1 != data.topPlaylists.count ? 0 : 20)
                                    }.pressAnimation()
                                }
                                .padding(.bottom, 25)
                            }
                        }
                        
                        if !data.artists.isEmpty {
                            Group {
                                HStack{
                                    Text(LocalizedStringKey("artists_of_week"))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .lineLimit(1)
                                        .font(.bold_22)
                                        .foregroundColor(.white)
                                    
                                    
                                }
                                .padding(.horizontal, 20)
                                LazyVStack {
                                    ForEach(data.artists.enumeratedArray(), id: \.offset) { ind, i in
                                        Button {
                                            coordinator.navigateTo(tab: mainVm.selectedTab, page: .artist(id: i.id))
                                        } label: {
                                            ArtistGridItem(data: i)
                                        }.pressAnimation()
                                    }
                                }.padding(.horizontal, 20)
                                    .padding(.bottom, 20)
                            }
                        }
                        
                        if !data.albums.isEmpty {
                            ScrollableHStack(title: "new_albums", spacing: 0) {
                                
                            } content: {
                                ForEach(data.albums.enumeratedArray(), id: \.offset) { ind, i in
                                    Button {
                                        coordinator.navigateTo(tab: mainVm.selectedTab, page: .playlist(type: .album, id: i.id))
                                    } label: {
                                        AlbumGridItem(data: i)
                                            .padding(.leading, ind != 0 ? 0 : 20)
                                            .padding(.trailing, ind+1 != data.albums.count ? 0 : 20)
                                    }.pressAnimation()
                                }
                            } .padding(.bottom, 20)
                        }
                        
                        ForEach(data.playlistsCategories.enumeratedArray(), id: \.offset){ index, item in
                            ScrollableHStack(title: item.name, spacing: 0) {
                            } content: {
                                ForEach(item.playlists.enumeratedArray(), id: \.offset) { ind, i in
                                    Button {
                                        coordinator.navigateTo(tab: mainVm.selectedTab, page: .playlist(type: .top, id: Int64(i.id)))
                                    } label: {
                                        PlaylistGridItem(data: PlaylistModel(id: i.id, name: i.name, image: i.image, count: Int(item.playlists[ind].songsCount)))
                                            .padding(.leading, ind != 0 ? 0 : 20)
                                            .padding(.trailing, ind+1 != item.playlists.count ? 0 : 20)
                                    }.pressAnimation()
                                }
                            }
                        }
                        .padding(.bottom, 25)
                        Spacer()
                            .frame(height: 75)
                    }
                } else if vm.noConnection {
                    NoConnectionView {
                        vm.getData()
                    }
                } else if vm.inProgress {
                    AppLoadingView()
                }
            }
            .onAppear{
                playervm.activateAudioSession()
                vm.getData()
            }
            .frame( maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgBlack)
        .navigationBarBackButtonHidden(true)
    }
}

