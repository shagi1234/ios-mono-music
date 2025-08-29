//
//  String.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 17.08.2023.
//

import Foundation

extension String {
    var url: URL? {
        return URL(string: self)
    }
    
    var stringUrl: String {
        return self
    }
    
    var stringAudioUrl: String {
        return self.replacingOccurrences(of: ".mp3", with: ".m3u8")
    }
}
