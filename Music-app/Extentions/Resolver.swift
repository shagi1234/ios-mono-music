//
//  Resolver.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 15.08.2023.
//

import Foundation
import Resolver

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        register { MainVM() }.scope(.application)
        register { PlayerVM(songService: SongService()) }.scope(.application)
        register { LibraryVM() }.scope(.application)
        register { SettingVM() }.scope(.application)
        
        register { HomeRepo() }
        register { PlaylistRepo() }
        register { AuthRepo()}
        
    }
}
