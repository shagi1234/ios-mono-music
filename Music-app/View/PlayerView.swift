//
//  PlayerView.swift with Debug Logging
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
    @StateObject var favVM  = FavVM()
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
    
    @State private var isUserInteracting = false
    @State private var lastPlayerVMIndex = -1
    @State private var imageRefreshID = UUID()
    
    @State private var isLiked = false
    
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
            .opacity(1)
            .offset(
                x: mainVm.expand && isDragging ? -min(mainVm.offset / 6, width) : 0,
                y: mainVm.expand ? -(UIScreen.main.bounds.height / 2 * 0.6) : 0
            )
            
            albumArtScrollView
        }
        .background {
            backgroundImageView
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
        // DEBUG: Enhanced onReceive for playervm.$playIndex
        .onReceive(playervm.$playIndex) { newPlayerIndex in
            //            print("🔄 onReceive playervm.$playIndex triggered:")
            //            print("   - New PlayerVM Index: \(newPlayerIndex)")
            //            print("   - Last PlayerVM Index: \(lastPlayerVMIndex)")
            //            print("   - Current UI Index: \(index)")
            //            print("   - Is User Interacting: \(isUserInteracting)")
            //            print("   - Thread: \(Thread.current)")
            //            print("   - Timestamp: \(Date())")
            
            if newPlayerIndex != lastPlayerVMIndex && !isUserInteracting {
                //                print("✅ Syncing UI from PlayerVM: \(newPlayerIndex)")
                lastPlayerVMIndex = newPlayerIndex
                
                DispatchQueue.main.async {
                    //                    print("   - UI sync executing on main thread")
                    //                    print("   - Setting index from \(index) to \(newPlayerIndex)")
                    index = newPlayerIndex
                    imageRefreshID = UUID()
                    //                    print("   - New imageRefreshID: \(imageRefreshID)")
                }
            } else {
                //                print("❌ Sync skipped - newIndex: \(newPlayerIndex), lastIndex: \(lastPlayerVMIndex), userInteracting: \(isUserInteracting)")
                lastPlayerVMIndex = newPlayerIndex
            }
            //            print("--- End onReceive playervm.$playIndex ---\n")
        }
        .onAppear {
            //            print("🏁 PlayerView onAppear:")
            //            print("   - PlayerVM Index: \(playervm.playIndex)")
            //            print("   - Setting UI index to: \(playervm.playIndex)")
            index = playervm.playIndex
            lastPlayerVMIndex = playervm.playIndex
            //            print("--- End onAppear ---\n")
        }
        .fullScreenCover(isPresented: $mainVm.showAddToPlaylist) {
            addToPlaylistFullScreen
        }
        .fullScreenCover(isPresented: $addToPlaylistPresented) {
            AddPlaylistView(isPresented: $addToPlaylistPresented)
        }
    }
}

private extension PlayerView {
    
    var backgroundImageView: some View {
        Group {
            if let currentTrack = playervm.currentTrack {
                KFImage(currentTrack.image.url)
                    .onSuccess { result in
                        //                        print("✅ Background image loaded: \(currentTrack.name)")
                    }
                    .onFailure { error in
                        print("❌ Background image failed: \(error.localizedDescription)")
                    }
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
                    .overlay(overlayMaterial)
                    .animation(.easeInOut(duration: 0.3), value: mainVm.expand)
                    .id(imageRefreshID) // Force refresh when needed
            } else {
                Image("cover-img")
                    .resizable()
                    .frame(height: mainVm.expand ? UIScreen.main.bounds.height : 65)
                    .frame(width: mainVm.expand ? width : width - 20, alignment: .center)
                    .cornerRadius(!mainVm.expand ? 10 : 0)
                    .aspectRatio(contentMode: mainVm.expand ? .fill : .fit)
                    .clipped()
                    .overlay(overlayMaterial)
                    .animation(.easeInOut(duration: 0.3), value: mainVm.expand)
            }
        }
    }
    
    var overlayMaterial: some View {
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
    }
    
    var miniPlayerView: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                    .frame(width: width - 20, height: 65)
            }
            .onAppear {
                //                print("📱 Mini player onAppear called")
                setupMiniPlayer()
            }
            .roundedCorner(10, corners: [.bottomLeft, .bottomRight])
            // DEBUG: Enhanced onReceive for playervm.publisher
            .onReceive(playervm.publisher) { (currentTime, duration) in
                //                print("📊 onReceive playervm.publisher (mini player):")
                //                print("   - Current Time: \(currentTime)")
                //                print("   - Duration: \(duration)")
                //                print("   - Previous elapsed: \(elapsedTime)")
                //                print("   - Previous total: \(totalTime)")
                updatePlayerTime(currentTime: currentTime, duration: duration)
                //                print("   - New elapsed: \(elapsedTime)")
                //                print("   - New total: \(totalTime)")
                //                print("--- End playervm.publisher (mini) ---\n")
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
        // DEBUG: Enhanced onReceive for app becoming active
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            //            print("📱 onReceive UIApplication.didBecomeActiveNotification:")
            //            print("   - Previous ID: \(id)")
            id = UUID()
            //            print("   - New ID: \(id)")
            //            print("--- End didBecomeActiveNotification ---\n")
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
            }.pressAnimation()
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
        .pressWithAnimation {
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
                .pressWithAnimation {
                    handleArtistTap()
                }
            }
            
            likeButton
                .id(playervm.currentTrack?.id)
            
            addToPlaylistButton
        }
        .onReceive(playervm.$isLiked) {
            isLiked = $0
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
        }.pressAnimation()
    }
    
    var likeButton: some View {
        Button {
            if let song = playervm.currentTrack {
                let isliked = playervm.isLiked
                
                favVM.addToFav(song.id,action: isliked ? .unlike : .like)
                playervm.currentTrack?.isLiked = !isliked
                playervm.isLiked = !isliked
            }
        } label: {
            if isLiked {
                Image("heartActive")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 30, height: 30)
            } else {
                Image("heart")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.white)
                    .scaledToFill()
                    .frame(width: 30, height: 30)
            }
        }.pressAnimation()
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
            //            print("📊 onReceive playervm.publisher (slider section):")
            //            print("   - Current Time: \(currentTime)")
            //            print("   - Duration: \(duration)")
            //            print("   - Is Dragging: \(isDragging)")
            //            print("   - Previous elapsed: \(elapsedTime)")
            //            print("   - Previous total: \(totalTime)")
            updatePlayerTime(currentTime: currentTime, duration: duration)
            //            print("   - New elapsed: \(elapsedTime)")
            //            print("   - New total: \(totalTime)")
            //            print("--- End playervm.publisher (slider) ---\n")
        }
        // DEBUG: Enhanced onReceive for playervm.loaderpublisher
        .onReceive(playervm.loaderpublisher) { newProgress in
            //            print("📈 onReceive playervm.loaderpublisher:")
            //            print("   - New Progress: \(newProgress)")
            //            print("   - Previous Progress: \(self.progress)")
            //            print("   - Thread: \(Thread.current)")
            self.progress = newProgress
            //            print("   - Updated Progress: \(self.progress)")
            //            print("--- End loaderpublisher ---\n")
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
        .pressWithAnimation {
            handleShuffleTap()
        }
    }
    
    var previousButton: some View {
        Button {
            //            print("⏮️ Previous button tapped")
            //            print("   - Current PlayerVM Index: \(playervm.playIndex)")
            //            print("   - Current UI Index: \(index)")
            playervm.prev()
            //            print("   - After prev() PlayerVM Index: \(playervm.playIndex)")
            if playervm.repeatMode == .repeatCurrentTrack {
                playervm.repeatMode = .repeatAll
            }
        } label: {
            Image("prev-28")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.white)
                .frame(width: 43, height: 43, alignment: .center)
        }.pressAnimation()
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
                    //                    print("▶️ Play/Pause button tapped - Playing: \(playervm.playing)")
                    withAnimation(.linear(duration: 0.15)) {
                        playervm.playOrStop()
                        impactMed.impactOccurred()
                    }
                } label: {
                    Image(playervm.playing ? "pause" : "play")
                        .resizable()
                        .frame(width: 74, height: 74, alignment: .center)
                }.pressAnimation()
            }
        }
    }
    
    var nextButton: some View {
        Button {
            //            print("⏭️ Next button tapped")
            //            print("   - Current PlayerVM Index: \(playervm.playIndex)")
            //            print("   - Current UI Index: \(index)")
            playervm.next()
            //            print("   - After next() PlayerVM Index: \(playervm.playIndex)")
            if playervm.repeatMode == .repeatCurrentTrack {
                playervm.repeatMode = .repeatAll
            }
        } label: {
            Image("next-28")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.white)
                .frame(width: 43, height: 43, alignment: .center)
        }.pressAnimation()
    }
    
    var repeatButton: some View {
        HStack {
            Button {
                //                print("🔁 Repeat button tapped - Current mode: \(playervm.repeatMode)")
                playervm.toggleRepeatMode()
                //                print("   - New mode: \(playervm.repeatMode)")
                impactMed.impactOccurred()
            } label: {
                Image(playervm.repeatMode == .repeatCurrentTrack ? "repeat-track" : "repeat-24")
                    .renderingMode(.template)
                    .resizable()
                    .foregroundColor(playervm.repeatMode != .noRepeat ? Color.accentColor : .white)
                    .frame(width: 24, height: 24, alignment: .center)
            }.pressAnimation()
        }
    }
    
    var bottomControlsSection: some View {
        HStack {
            Button(action: {
                print("📡 AirPlay button tapped")
                airPlayView.showAirPlayMenu()
            }) {
                airPlayView
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            Button {
                print("📤 Share button tapped")
                showShareSheet.toggle()
                sharingText = playervm.currentTrack?.audio ?? ""
                print("   - Sharing text: \(sharingText)")
            } label: {
                Image("share")
                    .renderingMode(.template)
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24, alignment: .center)
            }.pressAnimation()
            
            Button {
                print("📋 Queue button tapped")
                showList.toggle()
            } label: {
                Image("queue")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24, alignment: .center)
            }.pressAnimation()
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
                    .pressWithAnimation {
                        //                        print("🎵 Queue song tapped:")
                        //                        print("   - Song index: \(ind)")
                        //                        print("   - Song name: \(song.name)")
                        //                        print("   - Current PlayerVM Index: \(playervm.playIndex)")
                        //                        print("   - Current UI Index: \(index)")
                        isUserInteracting = true
                        playervm.playAtIndex(ind)
                        index = ind
                        //                        print("   - Set UI index to: \(index)")
                        //                        print("   - Set isUserInteracting to: \(isUserInteracting)")
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isUserInteracting = false
                            //                            print("   - Reset isUserInteracting to: \(isUserInteracting)")
                        }
                    }
                    .onAppear {
                        //                        print("👀 Queue item appeared: \(ind)")
                        visibleRows.append(ind)
                        //                        print("   - Visible rows: \(visibleRows)")
                    }
                    .onDisappear {
                        //                        print("👻 Queue item disappeared: \(ind)")
                        visibleRows.removeAll(where: { $0 == ind })
                        //                        print("   - Visible rows: \(visibleRows)")
                    }
                    .moveDisabled(ind <= playervm.playIndex)
                }
            }
            .onMove { source, destination in
                //                print("📋 Queue onMove triggered:")
                //                print("   - Source indices: \(source)")
                //                print("   - Destination: \(destination)")
                //                print("   - Current data count: \(playervm.data.count)")
                withAnimation(.default) {
                    playervm.data.move(fromOffsets: source, toOffset: destination)
                }
                //                print("   - New data count: \(playervm.data.count)")
                //                print("--- End onMove ---\n")
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
            .onChange(of: index) { newValue in
                //                    print("📱 onChange TabView index triggered:")
                //                    print("   - Old Value: \(index)")
                //                    print("   - New Value: \(newValue)")
                //                    print("   - MainVM Expand: \(mainVm.expand)")
                //                    print("   - PlayerVM Index: \(playervm.playIndex)")
                //                    print("   - Is User Interacting: \(isUserInteracting)")
                //                    print("   - Thread: \(Thread.current)")
                
                if !mainVm.expand {
                    //                        print("   - Mini player mode: calling playAtIndex(\(newValue))")
                    playervm.playAtIndex(newValue, playImmediately: false)
                    //                        print("   - After playAtIndex, PlayerVM Index: \(playervm.playIndex)")
                } else {
                    //                        print("   - Expanded mode: skipping playAtIndex call")
                }
                //                    print("--- End onChange TabView ---\n")
            }
            
            miniPlayerButton
        }
        .padding(.horizontal, 8)
    }
    
    var miniPlayerButton: some View {
        
        Group {
            if playervm.getPlayerItemStatus() == .failed || playervm.getPlayerItemStatus() == .unknown {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(width: 32, height: 32, alignment: .center)
            } else {
                Button {
                    print("▶️ Play/Pause button tapped - Playing: \(playervm.playing)")
                    withAnimation(.linear(duration: 0.15)) {
                        playervm.playOrStop()
                        impactMed.impactOccurred()
                    }
                } label: {
                    Image(playervm.playing ? "pause-mini" : "play-mini")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32, alignment: .center)
                }.pressAnimation()
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
        Group {
            // Use AdaptivePagingScrollView instead of TabView
            AdaptivePagingScrollView(
                currentPageIndex: $index,
                itemsAmount: playervm.data.count - 1,
                itemScrollableSide: width * 0.7,
                itemPadding: 20,
                visibleContentLength: width,
                expand: $mainVm.expand
            ) {
                ForEach(playervm.data.enumeratedArray(), id: \.element.id) { ind, song in
                    KFImage(song.image.url)
                        .onSuccess { result in
                            print("✅ SUCCESS: Expanded cover loaded for \(ind): \(song.name)")
                        }
                        .onFailure { error in
                            print("❌ FAILED: Expanded cover failed for \(ind): \(song.name) - \(error.localizedDescription)")
                        }
                        .placeholder {
                            Image("cover-img")
                                .resizable()
                                .scaledToFill()
                                .cornerRadius(10)
                        }
                        .fade(duration: 0.25)
                        .resizable()
                        .cacheOriginalImage()
                        .scaledToFill()
                        .frame(width: width * 0.7, height: width * 0.7)
                        .cornerRadius(10)
                        .clipped()
                        .scaleEffect(playervm.playIndex == ind ? (playervm.playing ? 1.05 : 1.0) : 0.85)
                        .opacity(playervm.playIndex == ind ? 1.0 : 0.7)
                        .shadow(color: .black.opacity(0.5), radius: playervm.playIndex == ind ? 15 : 5)
                    // REMOVED: .animation() modifiers that were causing jarring transitions
                        .id("expanded-\(ind)-\(song.id)-\(imageRefreshID)")
                }
            }
            .frame(height: mainVm.expand ? width * 0.7 : 0)
            .opacity(mainVm.expand ? 1 : 0)
            .disabled(isDragging)
            .offset(y: -(UIScreen.main.bounds.height / 2 * 0.35))
            
            if  !mainVm.expand {
                // Keep mini player cover logic exactly as it was
                HStack {
                    if let currentTrack = playervm.currentTrack {
                        KFImage(currentTrack.image.url)
                            .placeholder {
                                Image("cover-img")
                                    .resizable()
                                    .scaledToFill()
                                    .cornerRadius(5)
                            }
                            .fade(duration: 0.25)
                            .resizable()
                            .cacheOriginalImage()
                            .scaledToFill()
                            .frame(width: 47, height: 47)
                            .cornerRadius(5)
                            .clipped()
                            .id("mini-\(playervm.playIndex)-\(currentTrack.id)-\(imageRefreshID)")
                    } else {
                        Image("cover-img")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 47, height: 47)
                            .cornerRadius(5)
                            .clipped()
                    }
                    
                    Spacer()
                }
                .padding(.leading, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
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
            if let currentTrack = playervm.currentTrack {
                KFImage(currentTrack.image.url)
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
                    .id("\(currentTrack.id)-\(imageRefreshID)") // Force refresh
                
                Text(currentTrack.name)
                    .font(.bold_16)
                    .lineLimit(1)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
                
                Text(currentTrack.artistName)
                    .font(.med_15)
                    .lineLimit(1)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            } else {
                Image("cover-img")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 210, height: 210)
                    .cornerRadius(5)
                    .clipped()
                
                Text("No track selected")
                    .font(.bold_16)
                    .foregroundColor(.white)
                    .padding(.top, 10)
            }
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
            //            print("➕ New playlist button tapped")
            mainVm.showAddToPlaylist.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                addToPlaylistPresented = true
                //                print("   - addToPlaylistPresented set to true")
            }
        } label: {
            Text(LocalizedStringKey("new_playlist"))
                .foregroundColor(Color.bgBlack)
                .font(.med_15)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.accentColor)
                .cornerRadius(5)
        }.pressAnimation()
    }
    
    var closeButton: some View {
        Button {
            //            print("❌ Close button tapped")
            mainVm.showAddToPlaylist = false
            playervm.bottomSheetSong = nil
        } label: {
            Text(LocalizedStringKey("close"))
                .font(.bold_16)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, idealHeight: 50, maxHeight: 50, alignment: .center)
                .background(Color("DarkBlue"))
                .cornerRadius(4)
        }.pressAnimation()
    }
}

private extension PlayerView {
    
    func setupMiniPlayer() {
        //        print("🔧 setupMiniPlayer called:")
        //        print("   - isDragging before: \(isDragging)")
        //        print("   - audioSessionActivated: \(playervm.audioSessionActivated)")
        //        print("   - PlayerVM Index: \(playervm.playIndex)")
        //        print("   - UI Index before: \(index)")
        
        isDragging = false
        
        if !playervm.audioSessionActivated {
            index = playervm.playIndex
            lastPlayerVMIndex = playervm.playIndex
            //            print("   - Set UI index to PlayerVM index: \(index)")
        }
        
        preloadCurrentTrackImage()
        //        print("--- End setupMiniPlayer ---\n")
    }
    
    func updatePlayerTime(currentTime: TimeInterval, duration: TimeInterval) {
        //        print("⏱️ updatePlayerTime called:")
        //        print("   - Current Time: \(currentTime)")
        //        print("   - Duration: \(duration)")
        //        print("   - Previous elapsed: \(elapsedTime)")
        //        print("   - Previous total: \(totalTime)")
        
        self.elapsedTime = currentTime
        self.totalTime = duration
        
        //        print("   - New elapsed: \(elapsedTime)")
        //        print("   - New total: \(totalTime)")
        //        print("--- End updatePlayerTime ---\n")
    }
    
    func collapsePlayer() {
        //        print("📱 collapsePlayer called")
        //        print("   - Current expand state: \(mainVm.expand)")
        
        mainVm.changeOpacity = true
        withAnimation(Animation.spring(response: 0.45, dampingFraction: 0.85)) {
            mainVm.expand = false
            playervm.expand = false
            isDragging = true
        }
        
        //        print("   - Set expand to false, isDragging to true")
        //        print("--- End collapsePlayer ---\n")
    }
    
    func handlePlaylistTap(playlist: PlaylistModel) {
        //        print("🎵 handlePlaylistTap called:")
        //        print("   - Playlist: \(playlist.name)")
        
        collapsePlayer()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            //            print("   - Navigating to playlist after delay")
            navigateToPlaylist(playlist)
        }
    }
    
    func navigateToPlaylist(_ playlist: PlaylistModel) {
        //        print("🧭 navigateToPlaylist called:")
        //        print("   - Playlist type: \(playlist.type ?? "nil")")
        
        if playlist.type == nil {
            let firstAlbumId = playlist.songs?.first?.albumId
            let allSameAlbumId = playlist.songs?.allSatisfy { $0.albumId == firstAlbumId }
            
            //            print("   - First album ID: \(firstAlbumId ?? 0)")
            //            print("   - All same album: \(allSameAlbumId ?? false)")
            
            if allSameAlbumId ?? false {
                coordinator.navigateTo(tab: mainVm.selectedTab, page: .playlist(type: .album, id: playlist.id))
            } else {
                coordinator.navigateTo(tab: mainVm.selectedTab, page: .playlist(type: .top, id: playlist.id))
            }
        } else {
            coordinator.navigateTo(tab: mainVm.selectedTab, page: .myPlaylist(id: playlist.localId!))
        }
        //        print("--- End navigateToPlaylist ---\n")
    }
    
    func handleArtistTap() {
        //        print("👨‍🎤 handleArtistTap called")
        //        print("   - Current track artist: \(playervm.currentTrack?.artistName ?? "nil")")
        
        mainVm.changeOpacity = true
        withAnimation(Animation.spring(response: 0.5, dampingFraction: 0.85)) {
            mainVm.expand = false
            playervm.expand = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            mainVm.artistsCount = 1
            mainVm.artistId = playervm.currentTrack?.artists.first?.id
            //            print("   - Set artist ID: \(mainVm.artistId ?? 0)")
        }
        //        print("--- End handleArtistTap ---\n")
    }
    
    func handleShuffleTap() {
        //        print("🔀 handleShuffleTap called:")
        //        print("   - Current shuffle state: \(playervm.shuffled)")
        
        if playervm.shuffled {
            //            print("   - Calling unShufflePlaylist()")
            playervm.unShufflePlaylist()
        } else {
            //            print("   - Calling shufflePlaylist()")
            playervm.shufflePlaylist()
        }
        
        //        print("   - New shuffle state: \(playervm.shuffled)")
        impactMed.impactOccurred()
        //        print("--- End handleShuffleTap ---\n")
    }
    
    func handleDragChanged(_ value: DragGesture.Value) {
        guard !playervm.sliderDragging, mainVm.expand else {
            print("🚫 Drag blocked - sliderDragging: \(playervm.sliderDragging), expand: \(mainVm.expand)")
            return
        }
        
        if value.translation.height > abs(value.translation.width) {
            let translation = value.translation.height
            let threshold = UIScreen.main.bounds.height / 12
            let halfScreen = UIScreen.main.bounds.height / 2
            
            //            print("👆 handleDragChanged:")
            //            print("   - Translation height: \(translation)")
            //            print("   - Threshold: \(threshold)")
            //            print("   - Half screen: \(halfScreen)")
            
            withAnimation(.interactiveSpring()) {
                mainVm.offset = translation
                isDragging = true
                mainVm.changeOpacity = translation > threshold
                self.miniplayerOpacity = translation > halfScreen
                
                //                print("   - Set offset: \(mainVm.offset)")
                //                print("   - Set isDragging: \(isDragging)")
                //                print("   - Set changeOpacity: \(mainVm.changeOpacity)")
                //                print("   - Set miniplayerOpacity: \(miniplayerOpacity)")
            }
        }
    }
    
    func handleDragEnded(_ value: DragGesture.Value) {
        guard !playervm.sliderDragging, mainVm.expand else {
            print("🚫 Drag end blocked - sliderDragging: \(playervm.sliderDragging), expand: \(mainVm.expand)")
            return
        }
        
        let translation = value.translation.height
        let threshold = UIScreen.main.bounds.height / 12
        
        //        print("👆 handleDragEnded:")
        //        print("   - Translation height: \(translation)")
        //        print("   - Translation width: \(abs(value.translation.width))")
        //        print("   - Threshold: \(threshold)")
        //        print("   - Will collapse: \(translation > abs(value.translation.width) && translation > threshold)")
        
        if translation > abs(value.translation.width) && translation > threshold {
            // Collapse to mini player
            //            print("   - Collapsing to mini player")
            withAnimation(Animation.spring(response: 0.45, dampingFraction: 0.85)) {
                mainVm.expand = false
                playervm.expand = false
                resetDragStates()
            }
        } else {
            // Return to expanded state
            //            print("   - Returning to expanded state")
            withAnimation(.spring()) {
                resetDragStates()
            }
        }
        //        print("--- End handleDragEnded ---\n")
    }
    
    func resetDragStates() {
        //        print("🔄 resetDragStates called:")
        //        print("   - Before - offset: \(mainVm.offset), isDragging: \(isDragging)")
        //        print("   - Before - changeOpacity: \(mainVm.changeOpacity), miniplayerOpacity: \(miniplayerOpacity)")
        //        print("   - Before - sliderDragging: \(playervm.sliderDragging)")
        
        mainVm.offset = 0
        isDragging = false
        mainVm.changeOpacity = false
        miniplayerOpacity = false
        playervm.sliderDragging = false
        
        //        print("   - After - all states reset")
        //        print("--- End resetDragStates ---\n")
    }
    
    func preloadCurrentTrackImage() {
        guard let imageURL = playervm.currentTrack?.image.url else {
            print("🖼️ preloadCurrentTrackImage: No image URL available")
            return
        }
        
        //        print("🖼️ preloadCurrentTrackImage called:")
        //        print("   - Image URL: \(imageURL)")
        
        KingfisherManager.shared.retrieveImage(with: imageURL) { result in
            switch result {
            case .success(let value):
                print("✅ Preloaded current track image: \(value.image.size)")
            case .failure(let error):
                print("❌ Failed to preload current track image: \(error)")
            }
        }
    }
    
    func handleAddToPlaylist(playlist: PlaylistModel) {
        guard var song = playervm.currentTrack,
              let playlistId = playlist.localId else {
            print("❌ handleAddToPlaylist failed - missing song or playlist ID")
            return
        }
        
        //        print("➕ handleAddToPlaylist called:")
        //        print("   - Song: \(song.name)")
        //        print("   - Playlist: \(playlist.name)")
        //        print("   - Network connected: \(networkMonitor.isConnected)")
        
        if networkMonitor.isConnected {
            AppDatabase.shared.saveSong(&song, playlistId: playlistId)
            mainVm.popUpType = .successAdded
            libraryVm.postSongsToLibrary(songsId: [song.id], playlistId: playlist.id, action: .add)
            print("   - Song saved to playlist successfully")
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                mainVm.popUpType = .noConnection
                print("   - No connection popup shown")
            }
        }
        
        mainVm.showAddToPlaylist = false
        playervm.bottomSheetSong = nil
        //        print("--- End handleAddToPlaylist ---\n")
    }
}

extension PlayerView {
    
    func debugCurrentState() {
        //        print("🔍 CURRENT STATE DEBUG:")
        //        print("   - PlayerVM Index: \(playervm.playIndex)")
        //        print("   - UI Index: \(index)")
        //        print("   - Last PlayerVM Index: \(lastPlayerVMIndex)")
        //        print("   - Is User Interacting: \(isUserInteracting)")
        //        print("   - Is Dragging: \(isDragging)")
        //        print("   - MainVM Expand: \(mainVm.expand)")
        //        print("   - PlayerVM Expand: \(playervm.expand)")
        //        print("   - Current Track: \(playervm.currentTrack?.name ?? "nil")")
        //        print("   - Data count: \(playervm.data.count)")
        //        print("   - Elapsed Time: \(elapsedTime)")
        //        print("   - Total Time: \(totalTime)")
        //        print("   - Progress: \(progress)")
        //        print("   - Image Refresh ID: \(imageRefreshID)")
        //        print("--- END CURRENT STATE DEBUG ---\n")
    }
    
    // Add this to track potential memory issues
    func debugMemoryState() {
        //        print("💾 MEMORY STATE DEBUG:")
        //        print("   - Visible Rows: \(visibleRows)")
        //        print("   - Sharing Text: \(sharingText)")
        //        print("   - Show Share Sheet: \(showShareSheet)")
        //        print("   - Show List: \(showList)")
        //        print("   - Add To Playlist Presented: \(addToPlaylistPresented)")
        //        print("   - Has Posted: \(hasPosted)")
        //        print("--- END MEMORY STATE DEBUG ---\n")
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView()
            .preferredColorScheme(.dark)
    }
}
