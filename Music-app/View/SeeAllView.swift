//
//  SeeAllView.swift
//  Music-app
//
//  Created by SURAY on 02.03.2024.
//

import SwiftUI
import Resolver

struct SeeAllView: View {
    private let gridItems : [GridItem] = [
        .init(.flexible(), spacing: 1),
        .init(.flexible(), spacing: 1)
    ]
    
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var coordinator: Coordinator
    @StateObject var vm: SeeAllVM
    @StateObject var mainVm = Resolver.resolve(MainVM.self)
    @StateObject var playervm = Resolver.resolve(PlayerVM.self)
    
    
    var body: some View {
        VStack{
            HStack {
                Button(action: {
                    presentation.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40, alignment: .center)
                }).pressAnimation()
                
                Text(vm.artistName)
                    .foregroundColor(.white)
                    .font(.bold_16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                
                Spacer()
            }.padding(.horizontal, 10)
            Spacer()
            if vm.type == .songs && !(vm.songs?.isEmpty ?? true) || vm.type == .singles && !(vm.singles?.isEmpty ?? true){
                if let data = vm.type == .songs ? vm.songs : vm.singles{
                    ScrollView{
                        ForEach(data.enumeratedArray(), id: \.offset) { ind, i in
                            SongItem(data: i, current: playervm.currentTrack?.id == i.id, isPlaying: playervm.isPlaying(),  onMore: {
                                playervm.bottomSheetSong = i
                            },onTap: {
                                playervm.create(index: ind, tracks: data, tracklist: nil)
                            }, drag: {
                                playervm.addUpToNext(track: i, tracklist: nil)
                            })
                            .onAppear{
                                if data.last?.id == i.id && vm.type == .singles ? vm.canLoadMoreSingles : vm.canLoadMoreSongs {
                                    vm.getData(page: vm.page + 1)
                                }
                            }
                        }
                        .padding(.leading, 20)
                        .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        Spacer()
                            .frame(height: 60)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                    .listRowSpacing(.none)
                }
            }else if vm.type == .albums && !(vm.albums?.isEmpty ?? true){
                if let data = vm.albums{
                    ScrollView{
                        VStack{
                            Text(LocalizedStringKey("albums"))
                                .font(.bold_16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                            
                            LazyVGrid(columns: gridItems, content: {
                                ForEach(data.enumeratedArray(), id: \.offset) { ind, i in
                                    Button {
                                        coordinator.navigateTo(tab: mainVm.selectedTab, page: .playlist(type: .album, id: i.id))
                                    } label: {
                                        PlaylistGridItem(data: i, isalbums: true )
                                            .onAppear{
                                                if data.last?.id == i.id && vm.canLoadMoreAlbums {
                                                    vm.getData( page: vm.page + 1)
                                                }
                                            }
                                    }.pressAnimation()
                                }
                            }
                            )
                            if vm.isLoadingPage{
                                AppLoadingView()
                            }
                        }
                        Spacer()
                            .frame(height: 75)
                    }
                }
            }else if vm.noConnection{
                NoConnectionView {
                    vm.getData(page: vm.page)
                }
            }else if vm.isLoadingPage{
                AppLoadingView()
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgBlack)
        .navigationBarBackButtonHidden(true)
    }
}


struct SeeAllView_Previews: PreviewProvider {
    @StateObject var vm: SeeAllVM
    static var previews: some View {
        SeeAllView(vm: .init(type: .songs, id: 0, artistName: "hello"))
    }
}
