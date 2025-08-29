//
//  DownloadManager.swift
//  Music-app
//
//  Created by Shirin on 05.11.2023.
//

import Foundation
import Resolver
import UIKit

class DownloadManager: NSObject, ObservableObject, URLSessionDownloadDelegate {

    static let shared = DownloadManager()
    
    @Published var currentDownloadingSong: (song: SongModel, progress: Double)?
    @Published var downloadQueue: [Int64: SongModel] = [:]
    @Published var playlistDownloadQueue: [Int64: PlaylistModel] = [:]
    @Published var mainVm = Resolver.resolve(MainVM.self)
    private var activeDownloadTask: URLSessionDownloadTask?
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    private var session: URLSession!

    override init() {
        super.init()
        let configuration = URLSessionConfiguration.default
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        downloadPendingQueue()
    }

    private func downloadPendingQueue() {
        let queue = AppDatabase.shared.getQueue()
        queue.forEach { i in
            downloadQueue[i.id] = i.song
        }
        downloadNext()
    }
    
    func restartDownload() {
        activeDownloadTask?.cancel()
        activeDownloadTask = nil
        mainVm.downloadError = false
        mainVm.downloadingPlaylist = nil
        downloadNext()
    }
    
    func addSong(song: DownloadQueue) {
        downloadQueue[song.id] = song.song
        downloadNext()
    }
    
    func downloadSongs(songs: [SongModel]) {
        songs.forEach { i in
            downloadQueue[i.id] = i
        }
        downloadNext()
    }
    
    func deleteSong(song: SongModel) {
        if downloadQueue[song.id] == nil { return }
        
        downloadQueue.removeValue(forKey: song.id)
        if song.id == currentDownloadingSong?.song.id {
            activeDownloadTask?.cancel()
            activeDownloadTask = nil
            downloadNext()
        }
    }
    
    func downloadNext() {
        if activeDownloadTask != nil { return }
        
        guard let nextSongId = downloadQueue.keys.first, let song = downloadQueue[nextSongId] else {
            activeDownloadTask = nil
            return
        }
        
        Task {
            await downloadSong(song: song)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let songId = currentDownloadingSong?.song.id else { return }
        
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentsURL.appendingPathComponent(downloadTask.originalRequest?.url?.lastPathComponent ?? "audiofile.mp3")

        try? fileManager.removeItem(at: destinationURL)

        do {
            try fileManager.moveItem(at: location, to: destinationURL)
            print("File successfully downloaded to: \(destinationURL)")

            DispatchQueue.main.async {
                AppDatabase.shared.updateSongLocalPath(id: songId, localPath: destinationURL.lastPathComponent)
                self.downloadQueue.removeValue(forKey: songId)
                self.currentDownloadingSong = nil
                self.activeDownloadTask = nil
                self.downloadNext()
                self.endBackgroundTask()
            }
        } catch {
            print("Error moving file: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.mainVm.downloadError = true
                self.mainVm.downloadingPlaylist = AppDatabase.shared.getPlaylistsRelatedToSong(data: self.currentDownloadingSong?.song)
                self.currentDownloadingSong = nil
                self.activeDownloadTask = nil
                self.downloadNext()
                self.endBackgroundTask()
            }
        }
    }

    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            self.currentDownloadingSong?.progress = progress
        }
    }

    private func downloadSong(song: SongModel) async {
        guard let urlString = song.audio.url?.absoluteString else { return }
        
        DispatchQueue.main.async {
            self.currentDownloadingSong = (song, 0)
        }
        
        beginBackgroundTask()
        
        activeDownloadTask = session.downloadTask(with: URL(string: urlString)!)
        activeDownloadTask?.resume()
    }
    
    private func beginBackgroundTask() {
        backgroundTaskID = UIApplication.shared.beginBackgroundTask {
            UIApplication.shared.endBackgroundTask(self.backgroundTaskID)
            self.backgroundTaskID = .invalid
        }
    }
    
    private func endBackgroundTask() {
        UIApplication.shared.endBackgroundTask(backgroundTaskID)
        backgroundTaskID = .invalid
    }
}
