//
//  AddPlaylistView.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 17.08.2023.
//

import SwiftUI
import Resolver

struct AddPlaylistView: View {
    @StateObject var playervm = Resolver.resolve(PlayerVM.self)
    @Binding var isPresented: Bool
    @State var playlist: PlaylistModel?
    @State var name: String = ""
    @StateObject var mainVm = Resolver.resolve(MainVM.self)
    @StateObject var libraryVm = Resolver.resolve(LibraryVM.self)
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State var offset : CGFloat = 0
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    isPresented.toggle()
                    playervm.bottomSheetSong = nil
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                
                }.pressAnimation()
                
                Spacer()
            }.frame(height: 50)
            
            Spacer()
                .frame(height: 20)
            
            Text(LocalizedStringKey("enter_playlist_name"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.med_15)
                .foregroundColor(.white)
                .lineLimit(0)
                .multilineTextAlignment(.leading)
            
            HStack {
                ZStack(alignment: .leading) {
                    if name.isEmpty {
                        Text(LocalizedStringKey("playlist_name"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.textGray)
                            .font(.med_15)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 20)
                    }
                    
                    TextField("", text: $name)
                        .font(.med_15)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                }
            }.background(Color.bgLightBlack)
                .cornerRadius(5)
            
            Spacer()
            
            Button {
                if networkMonitor.isConnected{
                    if var p = playlist {
                        p.name = name
                        let _  = AppDatabase.shared.savePlaylist(&p)
                        libraryVm.postCustomPlaylistToLibrary(playlist: p, action: Actions.update)
                        print(p)
                    } else {
                        libraryVm.postCustomPlaylistToLibrary(playlist: PlaylistModel(id: Int64(Date().timeIntervalSinceReferenceDate), name: name), action: Actions.add)
                    }
                    isPresented = false
                }else{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        mainVm.popUpType = .noConnection
                    }
                }
            } label: {
                Text(LocalizedStringKey(playlist == nil ? "add" : "edit"))
                    .foregroundColor(.bgBlack)
                    .font(.bold_16)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.accentColor)
                    .cornerRadius(5)
            }.pressAnimation()
            .padding(.bottom, 20)
            .onChange(of: libraryVm.customPLaylistAdded) { newValue in
                var p = PlaylistModel(type: PlaylistType.local.rawValue, isDownloadOn: false, id: libraryVm.playlistId ?? 0, name: name, count: 0)
                let g  = AppDatabase.shared.savePlaylist(&p)
                if var song = playervm.bottomSheetSong{
                   AppDatabase.shared.saveSong(&song, playlistId: g ?? 1)
                    libraryVm.postSongsToLibrary(songsId: [song.id], playlistId: p.id, action: .add)
                    mainVm.popUpType = .successAdded
                    playervm.bottomSheetSong = nil
                }
            }
        }
        .offset(x: 0, y: offset)
        .padding(.horizontal, 20)
            .background(Color.bgBlack.ignoresSafeArea())
            .onTapGesture(perform: hideKeyboard)
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { value in
                        if value.translation.height > abs(value.translation.width) {
                            withAnimation(.spring) {
                                offset = value.translation.height
                            }
                        }
                    }
                    .onEnded { value in
                        withAnimation(Animation.spring(response: 0.6, dampingFraction: 0.85)){
                            offset = 0
                            isPresented = false
                            playervm.bottomSheetSong = nil
                        }
                    }
            )
    }
}
