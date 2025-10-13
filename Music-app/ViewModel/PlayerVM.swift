//
//  NewPLayerVM.swift
//  Music-app
//
//  Created by SURAY on 17.03.2024.
//

import Foundation
import AVFoundation
import MediaPlayer
import Kingfisher
import Combine
import SwiftUI
import Resolver

class PlayerVM: NSObject, ObservableObject {
    let songService: SongServiceProtocol
    @Published var audioPlayer: AVPlayer?
    @Published var playing: Bool = false
    @Published var cachedImage: UIImage? = nil
    var timeObserver:Any?
    var data = [SongModel]()
    var normalPlayList = [SongModel]()
    var playlist: PlaylistModel?
    var currentTrack : SongModel?
    @Published var isLiked: Bool = false
    @Published var bottomSheetSong : SongModel?
    @Published var playIndex : Int = -1
    var currentTrackId: Int64?
    @Published var repeatMode: RepeatModes = .noRepeat
    var shuffled: Bool = false
    var audioSessionActivated = false
    var lastPlayedIndex: Int?
    @Published var playNextQueue = [SongModel]()
    @Published var inserted: Bool = false
    private var cancellables = Set<AnyCancellable>()
    @Published var success: Bool = false
    @Published var sliderDragging: Bool = false
    @Published var firsttime: Bool  = true
    var hasPosted = false
    @Published var expand : Bool = false
    var playerActivated : Bool = false;
    var publisher = PassthroughSubject<(TimeInterval, TimeInterval), Never>()
    var loaderpublisher = PassthroughSubject<(TimeInterval), Never>()
    private var cancellable: AnyCancellable?
    var c = true;
    
    private var delayedPlayTask: DispatchWorkItem?
    private var isPlayingTransition = false
    
    init(songService: SongServiceProtocol) {
        self.songService = songService
        super.init()
        self.setupRemoteTransportControls()
        self.setupAudioSessionInterruptionObserver()
    }
    
    func create(index: Int, tracks: [SongModel], tracklist: PlaylistModel?) {
        delayedPlayTask?.cancel()
        isPlayingTransition = false
        
        self.data = tracks
        self.playlist = tracklist
        self.shuffled = false
        
        playAtIndex(index)
    }
    
    func playAtIndex(_ index: Int, playImmediately: Bool = true) {
        guard !isPlayingTransition else {
            print("Blocking rapid playAtIndex call - transition in progress")
            return
        }
        
        guard index < data.count && index >= 0 else {
            print("Invalid index: \(index), data.count: \(data.count)")
            return
        }
        
        let items = getAudioItems(data: data)
        guard index <= items.count - 1 else {
            print("Index exceeds audio items count")
            return
        }
        
        delayedPlayTask?.cancel()
        delayedPlayTask = nil
        
        let localPath = data[index].localPath
        var url: URL
        
        if let localPath = localPath, let localURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(localPath), FileManager.default.fileExists(atPath: localURL.path) {
            url = localURL
        } else {
            guard let remoteURL = URL(string: data[index].audio) else {
                print("Invalid audio URL for track: \(data[index].name)")
                return
            }
            url = remoteURL
        }
        
        self.currentTrackId = self.data[index].id
        
        self.playIndex = index
        self.currentTrack = self.data[index]
        self.isLiked = currentTrack?.isLiked ?? false
        
        self.clearPlayer()
        self.publisher.send((0, 0))
        self.loaderpublisher.send(0)
        let playerItem = AVPlayerItem(url: url)
        addObservers(for: playerItem)
        
        if !playImmediately {
            isPlayingTransition = true
            
            let workItem = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                
                guard self.delayedPlayTask != nil && !self.delayedPlayTask!.isCancelled else {
                    print("Delayed playAtIndex task was cancelled")
                    self.isPlayingTransition = false
                    return
                }
                
                self.createPlayer(with: playerItem)
                self.play()
                self.isPlayingTransition = false
                
                NotificationCenter.default.post(name: NSNotification.Name("PlayerNewTrackWillPlay"), object: nil)
                self.setupNowPlayingInfo()
            }
            
            self.delayedPlayTask = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: workItem)
            
        } else {
            isPlayingTransition = true
            
            self.createPlayer(with: playerItem)
            self.play()
            self.isPlayingTransition = false
            
            NotificationCenter.default.post(name: NSNotification.Name("PlayerNewTrackWillPlay"), object: nil)
            setupNowPlayingInfo()
        }
    }
    
    private func setupAudioSessionInterruptionObserver() {
        NotificationCenter.default.publisher(for: AVAudioSession.interruptionNotification)
            .sink { [weak self] notification in
                guard let self = self,
                      let userInfo = notification.userInfo,
                      let interruptionTypeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                      let interruptionType = AVAudioSession.InterruptionType(rawValue: interruptionTypeValue) else {
                    return
                }
                
                switch interruptionType {
                case .began:
                    self.pause()
                case .ended:
                    guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
                    let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                    if options.contains(.shouldResume) {
                        self.play()
                    }
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    private func createPlayer(with item: AVPlayerItem) {
        audioPlayer = AVPlayer(playerItem: item)
        if #available(iOS 10.0, *) {
            audioPlayer?.automaticallyWaitsToMinimizeStalling = false
        }
        addObserversForPlayer()
    }
    
    func addUpToNext(track: SongModel, tracklist: PlaylistModel?) {
        if audioPlayer == nil || data.count <= playIndex {
            create(index: 0, tracks: [track], tracklist: tracklist)
        } else {
            if shuffled{
                normalPlayList.insert(track, at: playIndex + 1)
                data.insert(track, at: playIndex + 1)
                self.inserted = true
            }else{
                data.insert(track, at: playIndex + 1)
                self.inserted = true
            }
        }
    }
    
    func addObservers(for item: AVPlayerItem) {
        item.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        item.addObserver(self, forKeyPath: "status", options: .new, context: nil)
    }
    
    func addObserversForPlayer() {
        audioPlayer?.addObserver(self, forKeyPath: "rate", options: .new, context: nil)
        
        timeObserver = audioPlayer?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: nil) { [weak self] time in
            guard let self = self, let currentItem = self.audioPlayer?.currentItem else { return }
            
            let currentTime = CMTimeGetSeconds(currentItem.currentTime())
            let duration = CMTimeGetSeconds(currentItem.duration)
            if currentTime >= duration - 1 {
                self.trackFinishedPlaying()
                return
            }
            guard duration.isFinite else { return }
          
            self.publisher.send((currentTime, duration))
        }
        self.setupNowPlayingInfo()
    }
    
    func clearPlayer() {
        audioPlayer?.pause()
        removeObservers(from: audioPlayer?.currentItem)
        removeObserversFromPlayer()
        audioPlayer = nil
    }
    
    private func getAudioItems(data: [SongModel]) -> [AVPlayerItem] {
        var items: [AVPlayerItem] = []
        
        for song in data {
            if let localPath = song.localPath,
               let localURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(localPath) {
                let item = AVPlayerItem(url: localURL)
                items.append(item)
            } else {
                if let url = URL(string: song.audio) {
                    let item = AVPlayerItem(url: url)
                    items.append(item)
                }
            }
        }
        return items
    }
    
    private func getLocalFilePath(for song: SongModel) -> String? {
        guard let fileName = song.localPath else {
            return nil
        }
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName).path
    }
    
    func removeObservers(from item: AVPlayerItem?) {
        item?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        item?.removeObserver(self, forKeyPath: "status")
    }
    
    func removeObserversFromPlayer() {
        if let to = timeObserver {
            audioPlayer?.removeTimeObserver(to)
        }
        
        audioPlayer?.removeObserver(self, forKeyPath: "rate")
    }
    
    func isPlaying() -> Bool {
        return audioPlayer?.rate != 0
    }
    
    func play() {
        audioPlayer?.play()
        self.playing = true
    }
    
    func pause() {
        self.playing = false
        audioPlayer?.pause()
    }
    
    func playOrStop() {
        if self.isPlaying() {
            self.playing = false
            audioPlayer?.pause()
        } else {
            self.playing = true
            audioPlayer?.play()
        }
    }
    
    func next() {
        // FIX: Always use immediate playback for navigation
        if playIndex < data.count - 1 {
            playAtIndex(playIndex + 1, playImmediately: true)
        } else {
            playAtIndex(0, playImmediately: true)
        }
        self.publisher.send((0, 0))
        self.loaderpublisher.send(0)
    }
    
    func toggleRepeatMode() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            switch self.repeatMode {
            case .noRepeat:
                self.repeatMode = .repeatAll
            case .repeatAll:
                self.repeatMode = .repeatCurrentTrack
            case .repeatCurrentTrack:
                self.repeatMode = .noRepeat
            }
        }
    }
    
    func trackFinishedPlaying() {
        if !playNextQueue.isEmpty {
            playNextQueue.removeLast()
        }
        
        // FIX: Always use immediate playback for auto-advance
        if repeatMode == .noRepeat {
            if playIndex == data.count - 1 {
                playAtIndex(0, playImmediately: false)
            } else {
                playAtIndex(playIndex + 1, playImmediately: true)
            }
        }
        
        if repeatMode == .repeatAll {
            if playIndex == data.count - 1 {
                playAtIndex(0, playImmediately: true)
            } else {
                playAtIndex(playIndex + 1, playImmediately: true)
            }
        }
        
        if repeatMode == .repeatCurrentTrack {
            self.seekToSecond(0)
        }
    }
    
    func moveSong(from source: IndexSet, to destination: Int) {
        data.move(fromOffsets: source, toOffset: destination)
    }
    
    func prev() {
        guard let unwrapped = self.audioPlayer?.currentTime() else { return }
        let currentTime = Float(CMTimeGetSeconds(unwrapped))
        
        if currentTime > 3 {
            self.seekToSecond(0, playAfterSeek: self.isPlaying())
            return
        }
        
        // FIX: Always use immediate playback for navigation
        if self.playIndex > 0 {
            playAtIndex(playIndex - 1, playImmediately: true)
        }else{
            playAtIndex(data.count - 1, playImmediately: true)
        }
    }
    
    func repeatAll() {
        repeatMode = .repeatAll
    }
    
    func repeatCurrentTrack() {
        repeatMode = .repeatCurrentTrack
    }
    
    func resetRepeat() {
        repeatMode = .noRepeat
    }
    
    func getPlayerItemStatus() -> AVPlayerItem.Status {
        guard let status = self.audioPlayer?.currentItem?.status else {
            return AVPlayerItem.Status.failed
        }
        return status
    }
    
    func getTrack() -> SongModel? {
        guard playIndex >= 0 && playIndex < data.count else { return nil }
        return self.data[playIndex]
    }
    
    func seekToSecond(_ second: Float, playAfterSeek:Bool = true) {
        audioPlayer?.currentItem?.seek(to: CMTimeMakeWithSeconds(Float64(second), preferredTimescale: Int32(NSEC_PER_SEC)), completionHandler: { (finished) in
            if (finished) {
                if playAfterSeek {
                    self.play()
                }
            } else {
                print("Couldn't successfully finish seek to second")
            }
        })
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if object is AVPlayerItem {
            if (keyPath == "loadedTimeRanges") {
                self.notifyAboutLoadedTimeRanges()
            }
            if (keyPath == "status") {
                guard let status = audioPlayer?.currentItem?.status else { return }
                
                if ( status == .readyToPlay ) {
                    print("item is ready to play")
                }
                if ( status == .failed ) {
                    print("item failed")
                }
            }
        }
        
        if object is AVPlayer {
            if (keyPath == "rate") {
                self.notifyAboutPlayStateChange()
            }
        }
    }
    
    func notifyAboutLoadedTimeRanges() {
        guard let loadedTimeRanges = audioPlayer?.currentItem?.loadedTimeRanges else {
            return
        }
        
        if (loadedTimeRanges.count > 0) {
            let timeRange = loadedTimeRanges[0].timeRangeValue
            let startSeconds: Double = CMTimeGetSeconds(timeRange.start)
            let durationSeconds: Double = CMTimeGetSeconds(timeRange.duration)
            
            let availableDuration = Float(startSeconds + durationSeconds)
            var trackDuration:Float = 0
            if let dur = audioPlayer?.currentItem?.duration {
                trackDuration = Float(Float(CMTimeGetSeconds(dur)))
            }
            if trackDuration != 0 {
                let progress: Float = availableDuration / trackDuration
                self.loaderpublisher.send(Double(availableDuration))
                var progressInfo = [String:Float]()
                progressInfo["progress"] = progress
                if self.audioPlayer?.timeControlStatus == .waitingToPlayAtSpecifiedRate {
                    self.play()
                }
                NotificationCenter.default.post(name: NSNotification.Name("PlayerPreloadAvailable"), object: nil, userInfo: progressInfo)
            }
        }
    }
    
    func notifyAboutPlayStateChange() {
        NotificationCenter.default.post(name: NSNotification.Name("PlayerPlayStateChange"), object: nil)
    }
    
    func activateAudioSession() {
        if audioSessionActivated { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.allowAirPlay])
            try AVAudioSession.sharedInstance().setMode(.default)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            audioSessionActivated = true
            print("audiosession activated")
            print("Playback OK")
        } catch {
            print("Couldn't activate audiosession")
        }
    }
    
    func shufflePlaylist() {
        guard let currentTrack = self.getTrack() else { return }
        self.normalPlayList = self.data
        self.data.remove(at: self.playIndex)
        self.data.shuffle()
        self.data.insert(currentTrack, at: playIndex)
        self.playIndex = playIndex
        self.shuffled = true
    }
    
    func shuffle( tracks: [SongModel], tracklist: PlaylistModel?){
        self.data = tracks
        self.playlist = tracklist
        self.activateAudioSession()
        let randomIndex = Int.random(in: 0..<self.data.count)
        self.playIndex = randomIndex
        self.playAtIndex(randomIndex)
    }
    
    func unShufflePlaylist() {
        guard let currentTrack = self.getTrack() else { return }
        self.data = self.normalPlayList
        
        for (index, track) in self.data.enumerated() {
            if track.id == currentTrack.id {
                self.playIndex = index
            }
        }
        
        self.shuffled = false
    }
    
    func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.changePlaybackPositionCommand.isEnabled  = true
        commandCenter.changePlaybackPositionCommand.addTarget{ [unowned self] event in
            let event = event as! MPChangePlaybackPositionCommandEvent
            seekToSecond(Float(event.positionTime))
            return .success
        }
        
        commandCenter.playCommand.addTarget { [unowned self] event in
            if self.audioPlayer?.rate == 0.0 {
                self.play()
                return .success
            }
            return .commandFailed
        }
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.audioPlayer?.rate == 1.0 {
                self.pause()
                return .success
            }
            return .commandFailed
        }
        commandCenter.stopCommand.addTarget { [unowned self] event in
            if self.audioPlayer == nil { return .commandFailed }
            self.audioPlayer?.pause()
            self.seekToSecond(0)
            
            return .success
        }
        
        commandCenter.togglePlayPauseCommand.addTarget { [unowned self] event in
            if self.audioPlayer == nil { return .commandFailed }
            
            if self.isPlaying() {
                self.pause()
            } else {
                self.play()
            }
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            self.next()
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            self.prev()
            return .success
        }
    }
    
    func setupNowPlayingInfo() {
        guard let track = getTrack() else { return }

        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = track.name
        nowPlayingInfo[MPMediaItemPropertyArtist] = track.artistName
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = audioPlayer?.rate ?? 1.0

        if let imageURL = URL(string: track.image) {
            KingfisherManager.shared.retrieveImage(with: imageURL) { result in
                switch result {
                case .success(let value):
                    nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: value.image.size) { size in
                        return value.image
                    }
                case .failure(let error):
                    print("Failed to load image: \(error)")
                }
            }
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        cancellable = publisher.sink { [weak self] elapsedTime, totalTime in
            guard let self = self else { return }

            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = totalTime
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = self.audioPlayer?.rate ?? 1.0
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
    }
}

enum RepeatModes {
    case noRepeat
    case repeatAll
    case repeatCurrentTrack
}
