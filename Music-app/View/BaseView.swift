import SwiftUI
import NavigationStackBackport

@main
struct BaseView: App {
    @StateObject var vm = MainVM()
    @AppStorage(DefaultsKeys.logged.rawValue) var logged: Bool = false
    @AppStorage(DefaultsKeys.lang.rawValue) var lang: String = "en"
    @AppStorage(DefaultsKeys.subsHasEnded.rawValue) var subsHasEnded: Bool = false
    @AppStorage(DefaultsKeys.subsEndDate.rawValue) var subsEndDate: String = ""
    @AppStorage(DefaultsKeys.subsType.rawValue) var subsType: String = ""
    @AppStorage(DefaultsKeys.loggedFirstTime.rawValue) var loggedFirstTime: Bool = false
    @StateObject var networkMonitor = NetworkMonitor()
    @StateObject var appUpdateManager = AppUpdateManager(appID: "6743871651")
    
    @StateObject var coordinator = Coordinator()
    @State var bottomsheet: BottomSheet?
    @State private var authNavigationID = UUID() // Add this to force recreation
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if !logged {
                    // 1. Not Logged In - Show Auth/OTP Flow
                    NavigationStack(path: $coordinator.paths[0]) {
                        SignUpView()
                            .preferredColorScheme(.dark)
                            .backport.navigationDestination(for: Coordinator.Page.self) { page in
                                coordinator.view(for: page)
                            }
                    }
                    .environmentObject(coordinator)
                    .environmentObject(networkMonitor)
                    .transition(.opacity)
                    .id(authNavigationID)
                    
                } else if loggedFirstTime {
                    // 2. First Time Login - Show Registration Screen
                    NavigationStack(path: $coordinator.paths[0]) {
                        Color.clear
                            .onAppear {
                                coordinator.navigateTo(tab: 0, page: .register)
                            }
                            .preferredColorScheme(.dark)
                            .backport.navigationDestination(for: Coordinator.Page.self) { page in
                                coordinator.view(for: page)
                            }
                    }
                    .environmentObject(coordinator)
                    .transition(.opacity)
                    .id("registration-view")
                    
                } else if subsHasEnded || (!subsEndDate.isEmpty && vm.hasSubscriptionExpired()) {
                    NavigationStack(path: $coordinator.paths[0]) {
                        SubsEndView()
                            .preferredColorScheme(.dark)
                            .backport.navigationDestination(for: Coordinator.Page.self) { page in
                                coordinator.view(for: page)
                            }
                    }
                    .environmentObject(coordinator)
                    .transition(.opacity)
                    .id("subs-end-view")

                } else if subsType.isEmpty {
                    NavigationStack(path: $coordinator.paths[0]) {
                        Color.clear
                            .onAppear {
                                coordinator.navigateTo(tab: 0, page: .subsription)
                            }
                            .preferredColorScheme(.dark)
                            .backport.navigationDestination(for: Coordinator.Page.self) { page in
                                coordinator.view(for: page)
                            }
                    }
                    .environmentObject(coordinator)
                    .transition(.opacity)
                    .id("subscription-selection-view")
                    
                } else {
                    ZStack {
                        if subsType.isEmpty {
                            NavigationStack(path: $coordinator.paths[0]) {
                                Color.clear
                                    .onAppear {
                                        coordinator.navigateTo(tab: 0, page: .subsription)
                                    }
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
                        
                        if bottomsheet != nil {
                            ZStack {
                                Color(red: 0.212, green: 0.255, blue: 0.322).opacity(0.4)
                                
                                Blur(style: .systemUltraThinMaterial)
                                    .onTapGesture {
                                        withAnimation {
                                            Tools.shared.presentedBottomsheet = nil
                                        }
                                    }
                                    .transition(.opacity)
                            }.ignoresSafeArea()
                        }
                        
                        coordinator.getBottomSheets()
                    }
                    .transition(.opacity)
                    .id("main-view")
                }
            }
            .animation(.easeInOut(duration: 0.3), value: logged)
            .animation(.easeInOut(duration: 0.3), value: subsHasEnded)
            .animation(.easeInOut(duration: 0.3), value: loggedFirstTime)
            .animation(.easeInOut(duration: 0.3), value: subsType)
            .onChange(of: logged) { newValue in
                if newValue {
                    authNavigationID = UUID()
                    coordinator.paths[0] = NavigationPath()
                    if !subsEndDate.isEmpty {
                        vm.checkSubscriptionStatus()
                    }
                } else {
                    authNavigationID = UUID()
                    coordinator.paths[0] = NavigationPath()
                }
            }
            .onChange(of: subsEndDate) { newValue in
                if !newValue.isEmpty && logged {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        vm.checkSubscriptionStatus()
                    }
                }
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active && logged && !subsEndDate.isEmpty {
                    vm.checkSubscriptionStatus()
                }
            }
            .onReceive(Tools.shared.$presentedBottomsheet) {
                self.bottomsheet = $0
            }
            .onAppear {
                if logged && !subsEndDate.isEmpty {
                    vm.checkSubscriptionStatus()
                }

                Task {
                    await appUpdateManager.checkForUpdates() { updateInfo in
                        Tools.shared.presentedBottomsheet = .showUpdateSheet(appUpdateManager)
                    }
                }
            }
        }
    }
}
