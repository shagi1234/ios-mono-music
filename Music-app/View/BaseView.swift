import SwiftUI
import NavigationStackBackport

@main
struct BaseView: App {
    @StateObject var vm = MainVM()
    @AppStorage(DefaultsKeys.logged.rawValue) var logged = Defaults.logged
    @AppStorage(DefaultsKeys.lang.rawValue) var lang = Defaults.lang
    @AppStorage(DefaultsKeys.subsHasEnded.rawValue) var subsHasEnded = Defaults.subsHasEnded
    @StateObject var networkMonitor = NetworkMonitor()
    @StateObject var appUpdateManager = AppUpdateManager(appID: "6743871651")
    
    @StateObject var coordinator = Coordinator()
    @State var bottomsheet: BottomSheet?
    
    var body: some Scene {
        WindowGroup {
            Group {
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
                        ZStack{
                            MainView()
                                .preferredColorScheme(.dark)
                                .environment(\.locale, .init(identifier: lang))
                                .environmentObject(networkMonitor)
                                .onAppear {
                                    vm.checkSubscriptionStatus()
                                }
                            
                            if bottomsheet != nil {
                                ZStack {
                                    Color(red: 0.212, green: 0.255, blue: 0.322).opacity(0.4)
                                    
                                    Blur(style: .systemUltraThinMaterial)
                                        .onTapGesture {
                                            withAnimation{
                                                Tools.shared.presentedBottomsheet = nil
                                            }
                                        }
                                        .transition(.opacity)
                                }.ignoresSafeArea()
                            }
                            
                            coordinator.getBottomSheets()
                        }
                    }
                }
            }
            .onReceive(Tools.shared.$presentedBottomsheet) {
                self.bottomsheet = $0
            }
            .onAppear {
                Task {
                    await appUpdateManager.checkForUpdates() { updateInfo in
                        Tools.shared.presentedBottomsheet = .showUpdateSheet(appUpdateManager)
                    }
                }
            }
        }
    }
}
