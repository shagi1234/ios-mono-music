//
//  LikedSongsView.swift
//  Music-app
//
//  Created by Shahruh on 01.10.2025.
//

import SwiftUI
import Kingfisher
import Resolver
import PopupView

struct LikedSongsView: View {
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @EnvironmentObject var coordinator: Coordinator
    @StateObject var playervm = Resolver.resolve(PlayerVM.self)
    @StateObject var mainVm = Resolver.resolve(MainVM.self)
    @StateObject var libraryVm = Resolver.resolve(LibraryVM.self)
    @StateObject var favVM = FavVM()
    
    @State var topSafeAreaPadding = 0.0
    @State var opacity = 0.0
    let screenWidth = UIScreen.main.bounds.width
    
    let impactMed = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        ZStack {
            if let songs = favVM.likedSongs, !songs.isEmpty {
                ScrollView {
                    GeometryReader { proxy in
                        let minY = proxy.frame(in: .named("SCROLL")).minY
                        let size = proxy.size
                        let height = size.height + minY
                        let headerHeight = topSafeAreaPadding + 60
                        
                        ZStack(alignment: .bottom){
                            Image("FavoritesCover")
                                .resizable()
                                .scaledToFill()
                            LinearGradient(colors: [.clear, Color.bgBlack], startPoint: .top, endPoint: .bottom)
                        }
                        .frame(width: size.width, height: height, alignment: .top)
                        .clipped()
                        .offset(y: -minY)
                        .onAppear {
                            topSafeAreaPadding = Double(UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
                            opacity = 0
                        }
                        
                        VStack {
                            Spacer()
                            HStack {
                                VStack {
                                    Text(LocalizedStringKey("Favorites"))
                                        .foregroundColor(.white)
                                        .font(.bold_35)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
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
                    }
                    .frame(height: UIScreen.main.bounds.width - 100)
                    .buttonStyle(.plain)
                    
                    HStack {
                        Button {
                            playervm.create(index: 0, tracks: songs, tracklist: nil)
                        } label: {
                            HStack {
                                Image(systemName: "play.fill")
                                    .foregroundColor(.accentColor)
                                
                                Text(LocalizedStringKey("play_all"))
                                    .font(.bold_16)
                                    .foregroundColor(.accentColor)
                            }
                            .frame(idealHeight: 34, maxHeight: 34, alignment: .center)
                            .padding(.horizontal, 10)
                            .background(Color.bgLightBlack)
                            .cornerRadius(3)
                            .padding(.vertical, 10)
                        }
                        .pressAnimation()
                        
                        Button {
                            if playervm.data.isEmpty {
                                playervm.create(index: Int.random(in: 0..<songs.count), tracks: songs, tracklist: nil)
                                playervm.shufflePlaylist()
                            } else {
                                if playervm.shuffled {
                                    playervm.unShufflePlaylist()
                                } else {
                                    playervm.shufflePlaylist()
                                }
                            }
                        } label: {
                            HStack {
                                Image("shuffle-24")
                                    .renderingMode(.template)
                                    .foregroundColor(playervm.shuffled ? .accentColor : .white)
                            }
                            .frame(maxWidth: 34, maxHeight: 34, alignment: .center)
                            .background(Color.bgLightBlack)
                            .cornerRadius(3)
                        }
                        .pressAnimation()
                        
                        Spacer()
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)
                    
                    LazyVStack {
                        ForEach(songs.enumeratedArray(), id: \.offset) { ind, song in
                            SongItem(
                                data: song,
                                current: playervm.currentTrack?.id == song.id,
                                isPlaying: playervm.isPlaying(),
                                isAlbum: false,
                                index: ind + 1,
                                disabled: !networkMonitor.isConnected && AppDatabase.shared.getSong(id: song.id)?.localPath == nil,
                                onMore: {
                                    playervm.bottomSheetSong = song
                                },onTap: {
                                    if networkMonitor.isConnected {
                                        playervm.create(index: ind, tracks: songs, tracklist: nil)
                                    } else if !networkMonitor.isConnected && AppDatabase.shared.getSong(id: song.id)?.localPath != nil {
                                        playervm.create(index: ind, tracks: songs, tracklist: nil)
                                    }
                                },
                                drag: {
                                    playervm.addUpToNext(track: song, tracklist: nil)
                                }
                            )
                            .onAppear {
                                favVM.loadMoreIfNeeded(currentSong: song)
                            }
                        }
                        .padding(.leading, 20)
                    }
                    
                    if favVM.isLoadingPage {
                        ProgressView()
                            .padding()
                    }
                    
                    Spacer()
                        .frame(height: 75)
                }
                .coordinateSpace(name: "SCROLL")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.top)
            } else if favVM.noConnection {
                NoConnectionView {
                    favVM.getLikedSongs()
                }
            } else if favVM.inProgress {
                AppLoadingView()
            } else {
                // Empty state
                VStack(spacing: 16) {
                    Image("FavoritesCover")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .cornerRadius(8)
                    
                    Text(LocalizedStringKey("no_liked_songs"))
                        .foregroundColor(.white.opacity(0.6))
                        .font(.bold_16)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgBlack)
        .overlay(
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.bgBlack.opacity(opacity))
                    .frame(height: topSafeAreaPadding)
                
                HStack {
                    Button(action: {
                        presentation.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40, alignment: .center)
                    })
                    .pressAnimation()
                    
                    Text(LocalizedStringKey("favorited"))
                        .foregroundColor(.white)
                        .font(.bold_22)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                        .opacity(opacity)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: screenWidth)
                .background(Color.bgBlack.opacity(opacity))
                
                Spacer()
            }
            .offset(y: -topSafeAreaPadding)
        )
        .navigationBarBackButtonHidden()
        .onAppear {
            favVM.getLikedSongs()
        }
    }
}
