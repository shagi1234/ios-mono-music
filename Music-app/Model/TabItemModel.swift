//
//  TabItemModel.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 18.08.2023.
//

import Foundation

struct TabItemModel {
    var title: String
    var image: String
    var selectedImage: String
    var tag: Int
    
    static let home = TabItemModel(title: "home", image: "home-tabbar", selectedImage: "home-tabbar-fill", tag: 0)
    static let search = TabItemModel(title: "search", image: "search-tabbar", selectedImage: "search-tabbar-fill", tag: 1)
    static let playlists = TabItemModel(title: "songs_tab", image: "playlist-tabbar", selectedImage: "playlist-tabbar-fill", tag: 2)
}
