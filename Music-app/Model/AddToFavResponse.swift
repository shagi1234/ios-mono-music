//
//  AddToFavResponse.swift
//  Music-app
//
//  Created Shahruh on 01.10.2025.
//

struct AddToFavResponse: Codable {
    let message: String
    let liked: Bool
}

struct LikedSongCountResponse: Codable {
    let favorites_count: Int
}

struct LikedSongModel: Codable {
    var song: SongModel
    var likedAt: String
    
    enum CodingKeys: String, CodingKey {
        case song = "song"
        case likedAt = "liked_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var song = try container.decode(SongModel.self, forKey: .song)
        // Mark all liked songs as liked
        song.isLiked = true
        self.song = song
        self.likedAt = try container.decode(String.self, forKey: .likedAt)
    }
}

