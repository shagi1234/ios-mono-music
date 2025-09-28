//
//  SearchView.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 15.08.2023.
//

import SwiftUI
import Resolver

struct SearchView: View {
    @EnvironmentObject var coordinator: Coordinator
    @StateObject var playervm  = Resolver.resolve(PlayerVM.self)
    @StateObject var mainVm = Resolver.resolve(MainVM.self)
    @StateObject var vm = SearchVM()
    @State var searchId = UUID()
    @State var activeTabType: SearchGenres = .all
    @EnvironmentObject var networkMonitor: NetworkMonitor
    private let gridItems : [GridItem] = [
        .init(.flexible(), spacing: 1),
        .init(.flexible(), spacing: 1)
    ]
    let impactMed = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        VStack {
            SearchBar(searchKey: vm.searchKey) { search in
                vm.updateSearchKey(key: search)
            } onSubmit: { key in
                vm.updateSearchHistory(search: key)
                UIApplication.shared.endEditing()
            }.id(searchId)
                .padding(20)
            
            if vm.inProgress {
                AppLoadingView()
            }
            else if vm.noConnection{
                NoConnectionView {
                    vm.updateSearchKey(key: " ")
                }
            }else if let data = vm.data {
                ScrollViewReader{ reader in
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack{
                            Spacer()
                                .frame(width: 20)
                            ForEach(SearchGenres.allCases, id: \.self){   item in
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
                    ScrollView{
                        if activeTabType == .all{
                            if vm.firstSearch && vm.searchKey.isEmpty && !vm.searchHistory.isEmpty{
                                HStack{
                                    Text(LocalizedStringKey("search_history"))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .font(.reg_15)
                                        .foregroundColor(.textGray)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                    
                                    Text(LocalizedStringKey("clear"))
                                        .pressWithAnimation {
                                            vm.deleteAllHistory()
                                        }
                                }
                                .padding(.horizontal, 20)
                                
                                ScrollView(.horizontal, showsIndicators: false){
                                    HStack{
                                        Spacer()
                                            .frame(width: 20)
                                        ForEach(vm.searchHistory, id: \.self){ i in
                                            SearchHistoryItem(data: i) {
                                                vm.updateSearchKey(key: i)
                                                searchId = UUID()
                                            }.padding(.horizontal, 4)
                                        }
                                        Spacer()
                                            .frame(width: 20)
                                    }
                                }
                                
                            }
                            songs(songs: data.songs)
                            artist(artists: data.artists)
                            albums(albums: data.albums)
                        } else if activeTabType == .artists{
                            artist(artists: data.artists)
                        }else if activeTabType == .albums{
                            albums(albums: data.albums)
                        }else if activeTabType == .songs{
                            songs(songs: data.songs)
                        }else{
                            playlists(playlists: data.playlists)
                                .padding(.horizontal, 20)
                        }
                        Spacer()
                            .frame( height: 75)
                    }
                    .background(Color.bgBlack)
                    .simultaneousGesture(
                        DragGesture().onChanged { _ in
                            hideKeyboard()
                        }
                    )
                 
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
            } else {
                if vm.firstSearch && vm.searchKey.isEmpty && !vm.searchHistory.isEmpty{
                    HStack{
                        Text(LocalizedStringKey("search_history"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.reg_15)
                            .foregroundColor(.textGray)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        Text(LocalizedStringKey("clear"))
                            .pressWithAnimation {
                                vm.deleteAllHistory()
                            }
                    }
                    .padding(.horizontal, 20)
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack{
                            Spacer()
                                .frame(width: 20)
                            ForEach(vm.searchHistory, id: \.self){ i in
                                SearchHistoryItem(data: i) {
                                    vm.updateSearchKey(key: i)
                                    searchId = UUID()
                                }.padding(.horizontal, 4)
                            }
                            Spacer()
                                .frame(width: 20)
                        }
                    }
                    Spacer()
                        .frame( height: 75)
                }
                
            }
            
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.bgBlack)
            .contentShape(Rectangle())
            .ignoresSafeArea(.keyboard)
            .onTapGesture { hideKeyboard() }
            .onDisappear { Defaults.searchHistory = vm.searchHistory }
            .onAppear{
                vm.updateSearchKey(key: " ")
            }
    }
}

extension SearchView{
    @ViewBuilder
    func playlists(playlists : [PlaylistModel]) -> some View{
        if !playlists.isEmpty{
            VStack{
                Text(LocalizedStringKey("playlists"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.reg_15)
                    .foregroundColor(.textGray)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                LazyVGrid(columns: gridItems, content: {
                    ForEach(playlists.enumeratedArray(), id: \.offset) { ind, i in
                        PlaylistGridItem(data: i, isalbums: false )
                            .padding(.bottom, ind + 1 != playlists.count ? 5 : 40)
                            .onTapGesture {
                                coordinator.navigateTo(tab: mainVm.selectedTab, page: .playlist(type: .top, id: i.id))
                            }
                    }
                })
                
            }
            .background(Color.bgBlack)
        }else{
            Rectangle()
                .fill(Color.bgBlack)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    
    @ViewBuilder
    func artist(artists: [ArtistModel]) -> some View{
        if !artists.isEmpty {
            VStack{
                Text(LocalizedStringKey("artists"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.reg_15)
                    .foregroundColor(.textGray)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                ForEach(artists.enumeratedArray(), id: \.offset) { ind, i in
                    ArtistGridItem(data: i)
                        .padding(.bottom, ind + 1 != artists.count ? 5 : 40)
                        .pressWithAnimation {
                            coordinator.navigateTo(tab: 1, page: .artist(id: i.id))
                        }
                }
                .padding(.horizontal, 20)
            }
            .background(Color.bgBlack)
        }else{
            Rectangle()
                .fill(Color.bgBlack)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    @ViewBuilder
    func albums(albums: [PlaylistModel]) -> some View{
        if !albums.isEmpty {
            VStack{
                ScrollableHStack(title: "albums", strongTitle: false, spacing: 0) {
                } content: {
                    ForEach(albums.enumeratedArray(), id: \.offset) { ind, i in
                        Button {
                            coordinator.navigateTo(tab: 1, page: .playlist(type: .album, id: i.id))
                        } label: {
                            AlbumGridItem(data: i)
                                .padding(.leading, ind != 0 ? 0 : 20)
                                .padding(.trailing, ind+1 != albums.count ? 0 : 40)
                        }.pressAnimation()
                    }
                }
            }
            .background(Color.bgBlack)
        }else{
            Rectangle()
                .fill(Color.bgBlack)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    
    
    
    @ViewBuilder
    func songs(songs: [SongModel]) -> some View{
        if !songs.isEmpty {
            VStack{
                Text(LocalizedStringKey("songs"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.reg_15)
                    .foregroundColor(.textGray)
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, 20)
                ForEach(songs.enumeratedArray(), id: \.offset) { ind, i in
                    SongItem(data: i, current: playervm.currentTrack?.id == i.id, isPlaying: playervm.isPlaying(), disabled: !networkMonitor.isConnected && AppDatabase.shared.getSong(id: i.id)?.localPath == nil, onMore: {
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
                    .padding(.bottom, ind + 1 != songs.count ? 5 : 40)
                }
            }
            .padding(.leading, 15)
            .background(Color.bgBlack)
        }else{
            Rectangle()
                .fill(Color.bgBlack)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .preferredColorScheme(.dark)
    }
}
