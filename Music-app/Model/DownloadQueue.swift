//
//  DownloadQueue.swift
//  Music-app
//
//  Created by Shirin on 05.11.2023.
//

import Foundation
import GRDB

struct DownloadQueue: Codable {
    var id: Int64
    var song: SongModel
}

extension DownloadQueue: FetchableRecord, MutablePersistableRecord { }
