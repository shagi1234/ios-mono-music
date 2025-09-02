//
//  Music_appApp.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 15.08.2023.
//

import SwiftUI
import NavigationStackBackport

@main
struct BaseView: App {
    @StateObject var vm = MainVM()
    @AppStorage(DefaultsKeys.logged.rawValue) var logged = Defaults.logged
    @AppStorage(DefaultsKeys.lang.rawValue) var lang = Defaults.lang
    @AppStorage(DefaultsKeys.subsHasEnded.rawValue) var subsHasEnded = Defaults.subsHasEnded
    @StateObject var networkMonitor = NetworkMonitor()
    
    @StateObject var coordinator = Coordinator()
    
    var body: some Scene {
        WindowGroup {
            if !logged {
                NavigationStack(path: $coordinator.paths[0]) {
                    SignUpView()
                        .preferredColorScheme(.dark)
                        .backport.navigationDestination(for: Coordinator.Page.self) { page in
                            coordinator.view(for: page)
                        }
                }
                .environmentObject(coordinator)
                .environmentObject(networkMonitor)
            } else {
                if subsHasEnded || vm.hasSubscriptionExpired() {
                    NavigationStack(path: $coordinator.paths[0]) {
                        SubsEndView()
                            .preferredColorScheme(.dark)
                            .backport.navigationDestination(for: Coordinator.Page.self) { page in
                                coordinator.view(for: page)
                            }
                    }
                    .environmentObject(coordinator)
                } else {
                    MainView()
                        .preferredColorScheme(.dark)
                        .environment(\.locale, .init(identifier: lang))
                        .environmentObject(networkMonitor)
                        .onAppear {
                            vm.checkSubscriptionStatus()
                        }
                }
            }
        }
    }
}
