//
//  MorePage.swift
//  Music-app
//
//  Created by SURAY on 25.02.2024.
//

import SwiftUI
import Kingfisher
import Resolver


struct MoreView: View {
    var song : SongModel
    var playlist: PlaylistModel? = PlaylistModel.example
    var isArtists : Bool = false
    var isPLaylist: Bool = false
    var close: ()->()
    var showArtistsInside: (() -> ())? = nil
    var playNext : (() -> ())?
    var closeButtonCallBack : ()->()
    var delete : (()->())? = nil
    var addToPlaylist : (()->())?
    var deletePlaylist : (()->())? = nil
    var editPLaylist : (()->())? = nil
    var downloadOrDeleteSongs : (()->())? = nil
    @State var offset : CGFloat = 0
    @State var isDrag : Bool = false
    
    @StateObject var playervm  = Resolver.resolve(PlayerVM.self)
    @StateObject var vm = Resolver.resolve(MainVM.self)
    @State var addToPlaylistPresented = false
    @StateObject var coordinator = Coordinator()
    @State private var sharingText = ""
    @State private var showShareSheet = false
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    var body: some View {
        VStack{
            GeometryReader{ geo in
                ScrollView(showsIndicators: false){
                    VStack{
                        Spacer()
                            .frame(height: 45)
                        if let data = playlist, isPLaylist{
                            if playlist?.type == "local"{
                                if playlist?.songs?.count ?? 1 > 3{
                                    VStack(spacing: 0){
                                        HStack(spacing: 0){
                                            KFImage(data.songs?.first?.image.url)
                                                .placeholder{ Image("cover-img").resizable().scaledToFill().cornerRadius(5)}
                                                .fade(duration: 0.25)
                                                .resizable()
                                                .scaledToFill()
                                                .clipped()
                                            KFImage(data.songs?[1].image.url)
                                                .placeholder{ Image("cover-img").resizable().scaledToFill().cornerRadius(5)}
                                                .fade(duration: 0.25)
                                                .resizable()
                                                .scaledToFill()
                                                .clipped()
                                            
                                        }
                                        HStack(spacing: 0){
                                            KFImage(data.songs?[2].image.url)
                                                .placeholder{ Image("cover-img").resizable().scaledToFill().cornerRadius(5)}
                                                .fade(duration: 0.25)
                                                .resizable()
                                                .scaledToFill()
                                                .clipped()
                                            KFImage(data.songs?[3].image.url)
                                                .placeholder{ Image("cover-img").resizable().scaledToFill().cornerRadius(5)}
                                                .fade(duration: 0.25)
                                                .resizable()
                                                .scaledToFill()
                                                .clipped()
                                        }
                                    }
                                    .frame(width: 210, height: 210)
                                    .cornerRadius(5)
                                    .clipped()
                                }else{
                                    KFImage(data.songs?.last?.image.url)
                                        .placeholder{ Image("cover-img").resizable().scaledToFill().cornerRadius(5)}
                                        .fade(duration: 0.25)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 210, height: 210)
                                        .cornerRadius(5)
                                        .clipped()
                                }
                                
                                
                            }else{
                                KFImage(data.cover?.url)
                                    .placeholder{ Image("cover-img").resizable().scaledToFill().cornerRadius(5)}
                                    .fade(duration: 0.25)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 210, height: 210)
                                    .cornerRadius(5)
                                    .clipped()
                            }
                            
                        }else{
                            KFImage(song.image.url)
                                .placeholder{ Image("cover-img").resizable().scaledToFill().cornerRadius(5)}
                                .fade(duration: 0.25)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 210, height: 210)
                                .cornerRadius(5)
                                .clipped()
                        }
                        
                        Text(isPLaylist ? playlist?.name ?? "" : song.name)
                            .font(.bold_16)
                            .lineLimit(0)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.top, 10)
                        if isPLaylist{
                            Text(playlist?.type == "local" ? "Playlist" : playlist?.type == "album" ? "Album" : "")
                                .font(.med_15)
                                .lineLimit(1)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }else{
                            Text(song.artistName)
                                .font(.med_15)
                                .lineLimit(1)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        Spacer()
                        if isPLaylist{
                            VStack( spacing : 20){
                                if playlist?.type == "local"{
                                    BottomSheetBtnView(bgColor: Color.moreBg, type: .editPlaylist) {
                                        editPLaylist?()
                                    }
                                }
                               
                                BottomSheetBtnView(bgColor: Color.moreBg, type: .deletePlaylist) {
                                    deletePlaylist?()
                                }
                                BottomSheetBtnView(bgColor: Color.moreBg, type:  playlist?.isDownloadOn == true ? .turnDownloadOff : .turnDownloadOn) {
                                    downloadOrDeleteSongs?()
                                }
                            }
                            .padding(.bottom, 20)
                        } else if isArtists{
                            VStack( spacing : 20){
                                Text(LocalizedStringKey("artists"))
                                    .font(.bold_16)
                                    .lineLimit(1)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                ForEach(song.artists.enumeratedArray() , id: \.offset){ index, artist in
                                    BottomSheetBtnView(bgColor: Color.moreBg, type: .artists(artists: artist)) {
                                        vm.artistId = artist.id
                                        vm.artistsCount = 1
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            playervm.bottomSheetSong = nil
                                        }
                                        close()
                                    }
                                }
                            }
                            .padding(.bottom, 20)
                            
                            
                        }else{
                            VStack(spacing: 20){
                                BottomSheetBtnView(bgColor: Color.moreBg, type: .addToPlaylist) {
                                    addToPlaylist?()
                                }
                                
                                BottomSheetBtnView(bgColor: Color.moreBg, type: .playNext) {
                                    playNext?()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        playervm.bottomSheetSong = nil
                                    }
                                }
                                
                                BottomSheetBtnView(bgColor: Color.moreBg, type: .goToArtist) {
                                    if song.artists.count > 1{
                                        vm.artistsCount = song.artists.count
                                        vm.artists = song.artists
                                    }else{
                                        vm.artistId = song.artists.first?.id
                                        vm.artistsCount = song.artists.count
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            playervm.bottomSheetSong = nil
                                        }
                                        close()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                            withAnimation(Animation.spring(response: 0.45, dampingFraction: 0.85)){
                                                vm.changeOpacity = true
                                              
                                            }
                                        }
                                    }
                                }
                                
                                if song.albumId != nil {
                                    BottomSheetBtnView(bgColor: Color.moreBg, type: .goToAlbom) {
                                        playervm.bottomSheetSong = nil
                                        vm.albumId = song.albumId
                                        close()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                            withAnimation(Animation.spring(response: 0.45, dampingFraction: 0.85)){
                                                vm.changeOpacity = true
                                              
                                            }
                                        }
                                    }
                                }
                                
                                BottomSheetBtnView(bgColor: Color.moreBg, type: .share) {
                                    showShareSheet.toggle()
                                    sharingText = playervm.bottomSheetSong?.audio ?? ""
                                }
                                
                                if  vm.canShowDelete ?? false {
                                    BottomSheetBtnView(bgColor: Color.moreBg, type: .delete) {
                                        delete?()
                                    }
                                }
                            }
                            .padding(.bottom, 20)
                        }
                    }
                    .frame(minHeight: geo.size.height)
                }
                .disabled(isDrag)
                .frame(width: geo.size.width, height: geo.size.height)
            
            }
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { value in
                        if value.translation.height > abs(value.translation.width) {
                            withAnimation(.spring) {
                                offset = value.translation.height
                                isDrag = true
                            }
                        }
                    }
                    .onEnded { value in
                        withAnimation(Animation.spring(response: 0.6, dampingFraction: 0.85)){
                            closeButtonCallBack()
                            offset = 0
                            isDrag = false
                            playervm.bottomSheetSong = nil
                        }
                    }
            )
            Spacer()
            
            Button {
                closeButtonCallBack()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    playervm.bottomSheetSong = nil
                }
            } label: {
                
                Text(LocalizedStringKey("close"))
                    .font(.bold_16)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, idealHeight: 50, maxHeight: 50, alignment: .center)
                    .background(Color("DarkBlue"))
                    .cornerRadius(4)
            }
           
        }
        .offset(x: 0, y: offset)
        .padding(.horizontal, 20)
        .background(
            Color.bgBlack
        )
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [sharingText])
        }
    }
}


struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    }
}


#Preview {
    MoreView(song: SongModel.example, close: {}, playNext: {}, closeButtonCallBack: {}, addToPlaylist: {})
}
