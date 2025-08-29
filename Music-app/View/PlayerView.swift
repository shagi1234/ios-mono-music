//
//  PlayerView.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 18.08.2023.
//

import SwiftUI
import Kingfisher
import Resolver
import PopupView

struct PlayerView: View {
    @StateObject var mainVm = Resolver.resolve(MainVM.self)
    @StateObject var playervm = Resolver.resolve(PlayerVM.self)
    @StateObject var libraryVm = Resolver.resolve(LibraryVM.self)
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @EnvironmentObject var coordinator: Coordinator
    
    @State private var airPlayView = AirPlayView()
    @State private var draggedItem: SongModel?
    @State private var visibleRows: [Int] = []
    @State private var sharingText = ""
    @State private var showShareSheet = false
    @State private var showList = false
    @State private var addToPlaylistPresented = false
    
    @State private var elapsedTime: TimeInterval = 0.0
    @State private var totalTime: TimeInterval = 0.1
    @State private var progress: Double = 0
    @State private var isDragging: Bool = false
    @State private var miniplayerOpacity: Bool = false
    @State private var index: Int = 0
    @State private var id = UUID()
    @State private var hasPosted = false
    
    private let width = UIScreen.main.bounds.width
    private let impactMed = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        VStack {
            if !mainVm.expand {
                miniPlayerView
            }
            
            if mainVm.expand {
                expandedPlayerView
            }
        }
        .overlay {
            VStack {
                Spacer()
                miniPlayerOverlay
                progressBarOverlay
                Spacer().frame(height: 4)
            }
            .frame(width: width - 20)
            .opacity(miniplayerOpacity || !mainVm.expand ? 1 : 0)
            .offset(
                x: mainVm.expand && isDragging ? -min(mainVm.offset / 6, width) : 0,
                y: mainVm.expand ? -(UIScreen.main.bounds.height / 2 * 0.6) : 0
            )
            
            albumArtScrollView
        }
        .background {
            KFImage(playervm.currentTrack?.image.url)
                .resizable()
                .fade(duration: 0.25)
                .cacheOriginalImage()
                .placeholder {
                    Image("cover-img")
                        .resizable()
                }
                .frame(height: mainVm.expand ? UIScreen.main.bounds.height : 65)
                .frame(width: mainVm.expand ? width : width - 20, alignment: .center)
                .cornerRadius(!mainVm.expand ? 10 : 0)
                .aspectRatio(contentMode: mainVm.expand ? .fill : .fit)
                .clipped()
                .overlay(
                    Rectangle()
                        .fill(Color.clear)
                        .background(.thinMaterial)
                        .ignoresSafeArea()
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: mainVm.expand ? .infinity : 65,
                            alignment: .center
                        )
                        .cornerRadius(!mainVm.expand ? 10 : 0)
                        .ignoresSafeArea()
                )
                .animation(.easeInOut(duration: 0.3), value: mainVm.expand)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 10, coordinateSpace: .local)
                .onChanged { value in
                    handleDragChanged(value)
                }
                .onEnded { value in
                    handleDragEnded(value)
                }
        )
        .onChange(of: index) { newValue in
            index = newValue
            if !mainVm.expand {
                playervm.playAtIndex(newValue, playImmediately: false)
            }
        }
        .fullScreenCover(isPresented: $mainVm.showAddToPlaylist) {
            addToPlaylistFullScreen
        }
        .fullScreenCover(isPresented: $addToPlaylistPresented) {
            AddPlaylistView(isPresented: $addToPlaylistPresented)
        }
    }
}

// MARK: - View Components
private extension PlayerView {
    
    var miniPlayerView: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                    .frame(width: width - 20, height: 65)
            }
            .onAppear {
                setupMiniPlayer()
            }
            .roundedCorner(10, corners: [.bottomLeft, .bottomRight])
            .onReceive(playervm.publisher) { (currentTime, duration) in
                updatePlayerTime(currentTime: currentTime, duration: duration)
            }
        }
    }
    
    var expandedPlayerView: some View {
        VStack(spacing: 0) {
            expandedPlayerHeader
            
            Spacer()
                .frame(minHeight: 5, maxHeight: 10)
            
            Spacer()
                .frame(width: width * 0.9, height: width * 0.9, alignment: .center)
            
            expandedPlayerContent
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .transition(.move(edge: .bottom))
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            id = UUID()
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [sharingText])
        }
        .sheet(isPresented: $showList) {
            queueSheet
        }
    }
    
    var expandedPlayerHeader: some View {
        HStack {
            Button {
                collapsePlayer()
            } label: {
                Image(systemName: "chevron.down")
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44, alignment: .center)
            }
            
            if let playlist = playervm.playlist {
                playlistInfoView(playlist: playlist)
            } else {
                Spacer()
            }
            
            Button {
                playervm.bottomSheetSong = playervm.currentTrack
                impactMed.impactOccurred()
            } label: {
                Image("h-more-16")
                    .renderingMode(.template)
                    .foregroundColor(.white)
            }
            .frame(width: 40, height: 40, alignment: .center)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 5)
        .opacity(mainVm.changeOpacity ? 0 : 1)
    }
    
    func playlistInfoView(playlist: PlaylistModel) -> some View {
        VStack {
            MarqueeText(
                text: playlist.name,
                font: .bold_14,
                leftFade: 1,
                rightFade: 1,
                startDelay: 2,
                alignment: .center
            )
            .foregroundColor(.white)
            
            if let year = playlist.year {
                Text(String(year))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.med_12)
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
        }
        .onTapGesture {
            handlePlaylistTap(playlist: playlist)
        }
    }
    
    var expandedPlayerContent: some View {
        VStack {
            trackInfoSection
            Spacer()
            sliderSection
            timeLabelsSection
            Spacer()
            controlsSection
            Spacer()
            bottomControlsSection
        }
        .opacity(mainVm.changeOpacity ? 0 : 1)
    }
    
    var trackInfoSection: some View {
        HStack {
            VStack(spacing: 4) {
                MarqueeText(
                    text: playervm.currentTrack?.name ?? "",
                    font: .bold_22,
                    leftFade: 1,
                    rightFade: 1,
                    startDelay: 2,
                    alignment: .leading
                )
                .foregroundColor(.white)
                
                MarqueeText(
                    text: playervm.currentTrack?.artistName ?? "",
                    font: .med_15,
                    leftFade: 1,
                    rightFade: 1,
                    startDelay: 2,
                    alignment: .leading
                )
                .foregroundColor(.white)
                .onTapGesture {
                    handleArtistTap()
                }
            }
            
            addToPlaylistButton
        }
        .padding(.horizontal, 20)
    }
    
    var addToPlaylistButton: some View {
        Button {
            mainVm.showAddToPlaylist = true
            playervm.bottomSheetSong = playervm.currentTrack
        } label: {
            if AppDatabase.shared.getSong(id: playervm.currentTrack?.id ?? 0) != nil {
                Image("add_box_fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 30, height: 30)
            } else {
                Image("add-to-playlist")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.white)
                    .scaledToFill()
                    .frame(width: 30, height: 30)
            }
        }
    }
    
    var sliderSection: some View {
        SliderView(
            value: $elapsedTime,
            progress: $progress,
            lastCoordinateValue: 0.0,
            sliderRange: totalTime > 0 ? 0...totalTime : 0...1
        )
        .frame(height: 20)
        .padding(.horizontal, 20)
        .disabled(isDragging)
        .onReceive(playervm.publisher) { (currentTime, duration) in
            updatePlayerTime(currentTime: currentTime, duration: duration)
        }
        .onReceive(playervm.loaderpublisher) { newProgress in
            self.progress = newProgress
        }
    }
    
    var timeLabelsSection: some View {
        HStack {
            Text(elapsedTime.minuteSecond)
                .font(.reg_15)
                .foregroundColor(.textLightGray)
                .lineLimit(1)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            Text(totalTime.minuteSecond)
                .font(.reg_15)
                .foregroundColor(.textLightGray)
                .lineLimit(1)
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, 20)
    }
    
    var controlsSection: some View {
        HStack {
            shuffleButton
            Spacer()
            previousButton
            Spacer()
            playPauseButton
            Spacer()
            nextButton
            Spacer()
            repeatButton
        }
        .padding(.horizontal, 20)
    }
    
    var shuffleButton: some View {
        HStack {
            Image("shuffle-24")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(playervm.shuffled ? Color.accentColor : .white)
                .frame(width: 25, height: 25, alignment: .center)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            handleShuffleTap()
        }
    }
    
    var previousButton: some View {
        Button {
            playervm.prev()
            if playervm.repeatMode == .repeatCurrentTrack {
                playervm.repeatMode = .repeatAll
            }
        } label: {
            Image("prev-28")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.white)
                .frame(width: 43, height: 43, alignment: .center)
        }
    }
    
    var playPauseButton: some View {
        Group {
            if playervm.getPlayerItemStatus() == .failed || playervm.getPlayerItemStatus() == .unknown {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                    .frame(width: 74, height: 74, alignment: .center)
                    .background(Color.white)
                    .cornerRadius(40)
            } else {
                Button {
                    withAnimation(.linear(duration: 0.15)) {
                        playervm.playOrStop()
                        impactMed.impactOccurred()
                    }
                } label: {
                    Image(playervm.playing ? "pause" : "play")
                        .resizable()
                        .frame(width: 74, height: 74, alignment: .center)
                }
            }
        }
    }
    
    var nextButton: some View {
        Button {
            playervm.next()
            if playervm.repeatMode == .repeatCurrentTrack {
                playervm.repeatMode = .repeatAll
            }
        } label: {
            Image("next-28")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.white)
                .frame(width: 43, height: 43, alignment: .center)
        }
    }
    
    var repeatButton: some View {
        HStack {
            Button {
                playervm.toggleRepeatMode()
                impactMed.impactOccurred()
            } label: {
                Image(playervm.repeatMode == .repeatCurrentTrack ? "repeat-track" : "repeat-24")
                    .renderingMode(.template)
                    .resizable()
                    .foregroundColor(playervm.repeatMode != .noRepeat ? Color.accentColor : .white)
                    .frame(width: 24, height: 24, alignment: .center)
            }
        }
    }
    
    var bottomControlsSection: some View {
        HStack {
            Button(action: {
                airPlayView.showAirPlayMenu()
            }) {
                airPlayView
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            Button {
                showShareSheet.toggle()
                sharingText = playervm.currentTrack?.audio ?? ""
            } label: {
                Image("share")
                    .renderingMode(.template)
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24, alignment: .center)
            }
            
            Button {
                showList.toggle()
            } label: {
                Image("queue")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24, alignment: .center)
            }
            .padding(.leading, 8)
        }
        .padding(.horizontal, 20)
    }
    
    var queueSheet: some View {
        VStack(spacing: 0) {
            Text(LocalizedStringKey("playlist"))
                .foregroundColor(.white)
                .font(.bold_16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .padding(20)
            
            Divider()
            
            ScrollViewReader { proxy in
                List {
                    currentTrackSection
                    upcomingTracksSection
                    
                    Spacer(minLength: 100)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.textBlack)
                }
                .listStyle(.plain)
                .onChange(of: playervm.playIndex) { _ in
                    if visibleRows.contains(playervm.playIndex) {
                        withAnimation {
                            proxy.scrollTo(playervm.playIndex, anchor: .top)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.textBlack)
    }
    
    @ViewBuilder
    var currentTrackSection: some View {
        if playervm.currentTrack != nil {
            Text(LocalizedStringKey("playing_now"))
                .foregroundColor(.white)
                .font(.bold_16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            
            SongItem(
                data: playervm.currentTrack ?? SongModel.example,
                current: true,
                isPlaying: playervm.isPlaying()
            )
            .listRowBackground(Color.clear)
            .listSectionSeparator(.hidden)
        }
    }
    
    @ViewBuilder
    var upcomingTracksSection: some View {
        if let lastSongID = playervm.data.last?.id,
           lastSongID != playervm.currentTrack?.id {
            
            Text(LocalizedStringKey("nextInQueue"))
                .foregroundColor(.white)
                .font(.bold_16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            
            ForEach(playervm.data.enumeratedArray(), id: \.element.id) { ind, song in
                if ind > playervm.playIndex {
                    SongItem(
                        data: song,
                        current: false,
                        isPlaying: playervm.isPlaying(),
                        moveOn: ind > playervm.playIndex
                    )
                    .listRowSeparator(.hidden)
                    .listRowBackground(playervm.playIndex != ind ? Color.textBlack : Color.bgLightBlack)
                    .onTapGesture {
                        playervm.playAtIndex(ind)
                    }
                    .onAppear {
                        visibleRows.append(ind)
                    }
                    .onDisappear {
                        visibleRows.removeAll(where: { $0 == ind })
                    }
                    .moveDisabled(ind <= playervm.playIndex)
                }
            }
            .onMove { source, destination in
                withAnimation(.default) {
                    playervm.data.move(fromOffsets: source, toOffset: destination)
                }
            }
        }
    }
    
    var miniPlayerOverlay: some View {
        HStack {
            TabView(selection: $index) {
                ForEach(playervm.data.enumeratedArray(), id: \.offset) { ind, song in
                    MiniPlayerText(name: song.name, artistName: song.artistName)
                        .tag(ind)
                }
            }
            .frame(height: 50)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            miniPlayerButton
        }
        .padding(.horizontal, 8)
    }
    
    var miniPlayerButton: some View {
        Group {
            if playervm.getPlayerItemStatus() == .failed || playervm.getPlayerItemStatus() == .unknown {
                Image("play-mini")
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 32, height: 32, alignment: .center)
                    .foregroundColor(.white)
                    .padding(.trailing, 10)
            } else {
                Button {
                    playervm.playOrStop()
                } label: {
                    Image(playervm.playing ? "pause-mini" : "play-mini")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32, alignment: .center)
                }
                .padding(.trailing, 10)
            }
        }
    }
    
    var progressBarOverlay: some View {
        HStack(spacing: 0) {
            if totalTime > 1 {
                Rectangle()
                    .fill(Color.accentColor)
                    .frame(width: max(0, CGFloat((elapsedTime / totalTime) * (width - 30))))
            }
            Rectangle()
                .fill(Color.textGray)
                .frame(maxWidth: .infinity)
        }
        .frame(height: 2)
        .roundedCorner(10, corners: [.bottomLeft, .bottomRight])
        .padding(.horizontal, 5)
    }
    
    var albumArtScrollView: some View {
        AdaptivePagingScrollView(
            currentPageIndex: $playervm.playIndex,
            itemsAmount: playervm.data.count - 1,
            itemScrollableSide: width * 0.8,
            itemPadding: 26,
            visibleContentLength: width,
            expand: $mainVm.expand
        ) {
            ForEach(playervm.data.enumeratedArray(), id: \.element.id) { ind, song in
                albumArtImage(for: song, at: ind)
            }
        }
        .disabled(!mainVm.expand || isDragging)
        .frame(maxHeight: mainVm.expand ? width * 0.8 : 47, alignment: .center)
        .offset(
            x: mainVm.expand ? 0 : -(width - 65),
            y: mainVm.expand ? -(UIScreen.main.bounds.height / 2 * 0.35) : 0
        )
        .onChange(of: playervm.playIndex) { newValue in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                index = newValue
            }
        }
    }
    
    func albumArtImage(for song: SongModel, at index: Int) -> some View {
        KFImage(song.image.url)
            .placeholder {
                Image("cover-img")
                    .resizable()
                    .scaledToFill()
                    .cornerRadius(mainVm.expand ? 10 : 5)
            }
            .fade(duration: 0.25)
            .resizable()
            .cacheOriginalImage()
            .scaledToFill()
            .frame(
                width: mainVm.expand ? max(width * 0.8 - abs(mainVm.offset) / 3, 47) : 47,
                height: mainVm.expand ? max(width * 0.8 - abs(mainVm.offset) / 3, 47) : 47
            )
            .cornerRadius(mainVm.expand ? 10 : 5)
            .clipped()
            .scaleEffect(playervm.playIndex == index && playervm.playing && mainVm.expand ? 1.1 : 1)
            .opacity(playervm.playIndex == index ? 1 : (mainVm.expand ? 0.3 : 0))
            .offset(x: isDragging ? -min(mainVm.offset / 6, width - 10) : 0)
            .shadow(color: .black.opacity(0.5), radius: mainVm.expand && playervm.playIndex == index ? 15 : 0)
            .animation(.easeInOut(duration: 0.3), value: mainVm.expand)
    }
    
    var addToPlaylistFullScreen: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                Spacer(minLength: 40)
                currentTrackDisplay
                playlistsList
            }
            
            newPlaylistButton
            Spacer()
            closeButton
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("MoreBG"))
    }
    
    var currentTrackDisplay: some View {
        VStack {
            KFImage(playervm.currentTrack?.image.url)
                .placeholder {
                    Image("cover-img")
                        .resizable()
                        .scaledToFill()
                        .cornerRadius(5)
                }
                .fade(duration: 0.25)
                .resizable()
                .scaledToFill()
                .frame(width: 210, height: 210)
                .cornerRadius(5)
                .clipped()
            
            Text(playervm.currentTrack?.name ?? "")
                .font(.bold_16)
                .lineLimit(1)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
            
            Text(playervm.currentTrack?.artistName ?? "")
                .font(.med_15)
                .lineLimit(1)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
    }
    
    var playlistsList: some View {
        VStack(spacing: 20) {
            let list = AppDatabase.shared.getLocalPlaylists()
            ForEach(list.enumeratedArray(), id: \.offset) { index, playlist in
                BottomSheetBtnView(bgColor: Color.moreBg, type: .playlist(playlist: playlist)) {
                    handleAddToPlaylist(playlist: playlist)
                }
            }
        }
    }
    
    var newPlaylistButton: some View {
        Button {
            mainVm.showAddToPlaylist.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                addToPlaylistPresented = true
            }
        } label: {
            Text(LocalizedStringKey("new_playlist"))
                .foregroundColor(Color.bgBlack)
                .font(.med_15)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.accentColor)
                .cornerRadius(5)
        }
    }
    
    var closeButton: some View {
        Button {
            mainVm.showAddToPlaylist = false
            playervm.bottomSheetSong = nil
        } label: {
            Text(LocalizedStringKey("close"))
                .font(.bold_16)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, idealHeight: 50, maxHeight: 50, alignment: .center)
                .background(Color("DarkBlue"))
                .cornerRadius(4)
        }
    }
}

// MARK: - Helper Methods
private extension PlayerView {
    
    func setupMiniPlayer() {
        isDragging = false
        if !playervm.audioSessionActivated {
            index = playervm.playIndex
        }
        preloadCurrentTrackImage()
    }
    
    func updatePlayerTime(currentTime: TimeInterval, duration: TimeInterval) {
        self.elapsedTime = currentTime
        self.totalTime = duration
    }
    
    func collapsePlayer() {
        mainVm.changeOpacity = true
        withAnimation(Animation.spring(response: 0.45, dampingFraction: 0.85)) {
            mainVm.expand = false
            playervm.expand = false
            isDragging = true
        }
    }
    
    func handlePlaylistTap(playlist: PlaylistModel) {
        collapsePlayer()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            navigateToPlaylist(playlist)
        }
    }
    
    func navigateToPlaylist(_ playlist: PlaylistModel) {
        if playlist.type == nil {
            let firstAlbumId = playlist.songs?.first?.albumId
            let allSameAlbumId = playlist.songs?.allSatisfy { $0.albumId == firstAlbumId }
            
            if allSameAlbumId ?? false {
                coordinator.navigateTo(tab: mainVm.selectedTab, page: .playlist(type: .album, id: playlist.id))
            } else {
                coordinator.navigateTo(tab: mainVm.selectedTab, page: .playlist(type: .top, id: playlist.id))
            }
        } else {
            coordinator.navigateTo(tab: mainVm.selectedTab, page: .myPlaylist(id: playlist.localId!))
        }
    }
    
    func handleArtistTap() {
        mainVm.changeOpacity = true
        withAnimation(Animation.spring(response: 0.5, dampingFraction: 0.85)) {
            mainVm.expand = false
            playervm.expand = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            mainVm.artistsCount = 1
            mainVm.artistId = playervm.currentTrack?.artists.first?.id
        }
    }
    
    func handleShuffleTap() {
        if playervm.shuffled {
            playervm.unShufflePlaylist()
        } else {
            playervm.shufflePlaylist()
        }
        impactMed.impactOccurred()
    }
    
    func handleDragChanged(_ value: DragGesture.Value) {
        guard !playervm.sliderDragging, mainVm.expand else { return }
        
        if value.translation.height > abs(value.translation.width) {
            let translation = value.translation.height
            let threshold = UIScreen.main.bounds.height / 12
            let halfScreen = UIScreen.main.bounds.height / 2
            
            withAnimation(.interactiveSpring()) {
                mainVm.offset = translation
                isDragging = true
                mainVm.changeOpacity = translation > threshold
                self.miniplayerOpacity = translation > halfScreen
            }
        }
    }
    
    func handleDragEnded(_ value: DragGesture.Value) {
        guard !playervm.sliderDragging, mainVm.expand else { return }
        
        let translation = value.translation.height
        let threshold = UIScreen.main.bounds.height / 12
        
        if translation > abs(value.translation.width) && translation > threshold {
            // Collapse to mini player
            withAnimation(Animation.spring(response: 0.45, dampingFraction: 0.85)) {
                mainVm.expand = false
                playervm.expand = false
                resetDragStates()
            }
        } else {
            // Return to expanded state
            withAnimation(.spring()) {
                resetDragStates()
            }
        }
    }
    
    func resetDragStates() {
        mainVm.offset = 0
        isDragging = false
        mainVm.changeOpacity = false
        miniplayerOpacity = false
        playervm.sliderDragging = false
    }
    
    func preloadCurrentTrackImage() {
        guard let imageURL = playervm.currentTrack?.image.url else { return }
        KingfisherManager.shared.retrieveImage(with: imageURL) { _ in }
    }
    
    func handleAddToPlaylist(playlist: PlaylistModel) {
        guard var song = playervm.currentTrack,
              let playlistId = playlist.localId else { return }
        
        if networkMonitor.isConnected {
            AppDatabase.shared.saveSong(&song, playlistId: playlistId)
            mainVm.popUpType = .successAdded
            libraryVm.postSongsToLibrary(songsId: [song.id], playlistId: playlist.id, action: .add)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                mainVm.popUpType = .noConnection
            }
        }
        
        mainVm.showAddToPlaylist = false
        playervm.bottomSheetSong = nil
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView()
            .preferredColorScheme(.dark)
    }
}
