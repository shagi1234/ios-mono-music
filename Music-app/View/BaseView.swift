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
                    .onAppear {
                        print("🔐 Showing Auth View - User not logged in")
                    }
                    .transition(.opacity)
                    .id(authNavigationID) // Use unique ID to force recreation
                    
                } else if loggedFirstTime {
                    // 2. First Time Login - Show Registration Screen
                    NavigationStack(path: $coordinator.paths[0]) {
                        Color.clear
                            .onAppear {
                                print("📝 First time user - navigating to registration")
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
                    
                } else if subsType.isEmpty {
                    // 3. No Subscription - Show Subscription Plans
                    NavigationStack(path: $coordinator.paths[0]) {
                        Color.clear
                            .onAppear {
                                print("💳 No subscription type - navigating to subscription plans")
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
                    
                } else if subsHasEnded || vm.hasSubscriptionExpired() {
                    // 4. Subscription Expired (Any Type) - Show Renewal Screen
                    NavigationStack(path: $coordinator.paths[0]) {
                        SubsEndView()
                            .preferredColorScheme(.dark)
                            .backport.navigationDestination(for: Coordinator.Page.self) { page in
                                coordinator.view(for: page)
                            }
                            .onAppear {
                                print("⚠️ Showing Subscription End View")
                                print("   - subsType: \(subsType)")
                                print("   - subsHasEnded: \(subsHasEnded)")
                                print("   - subsEndDate: \(subsEndDate)")
                            }
                    }
                    .environmentObject(coordinator)
                    .transition(.opacity)
                    .id("subs-end-view")
                    
                } else {
                    // 4. Active Subscription OR No Subscription Type - Show Main App or Navigate
                    ZStack {
                        if subsType.isEmpty {
                            // No subscription type after registration - navigate to subscription selection
                            NavigationStack(path: $coordinator.paths[0]) {
                                Color.clear
                                    .onAppear {
                                        print("💳 No subscription type after registration - navigating to subscription plans")
                                        coordinator.navigateTo(tab: 0, page: .subsription)
                                    }
                                    .preferredColorScheme(.dark)
                                    .backport.navigationDestination(for: Coordinator.Page.self) { page in
                                        coordinator.view(for: page)
                                    }
                            }
                            .environmentObject(coordinator)
                        } else {
                            // Active subscription - show main app
                            MainView()
                                .preferredColorScheme(.dark)
                                .environment(\.locale, .init(identifier: lang))
                                .environmentObject(networkMonitor)
                                .onAppear {
                                    print("✅ Showing Main View")
                                    print("   - logged: \(logged)")
                                    print("   - subsHasEnded: \(subsHasEnded)")
                                    print("   - subsEndDate: \(subsEndDate)")
                                    print("   - subsType: \(subsType)")
                                    print("   - loggedFirstTime: \(loggedFirstTime)")
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
                print("🔄 BaseView: logged changed to \(newValue)")
                if newValue {
                    print("   ✓ User logged in")
                    print("   ✓ loggedFirstTime: \(loggedFirstTime)")
                    print("   ✓ subsType: \(subsType)")
                    print("   ✓ subsHasEnded: \(subsHasEnded)")
                    print("   ✓ subsEndDate: \(subsEndDate)")
                    
                    // Reset auth navigation to clear OTP view
                    authNavigationID = UUID()
                    
                    // Clear navigation path by creating new empty array
                    coordinator.paths[0] = NavigationPath()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        vm.checkSubscriptionStatus()
                    }
                } else {
                    // Reset auth navigation when logging out
                    authNavigationID = UUID()
                    coordinator.paths[0] = NavigationPath()
                }
            }
            .onChange(of: subsEndDate) { newValue in
                print("🔄 BaseView: subsEndDate changed to \(newValue)")
                if !newValue.isEmpty && logged {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        vm.checkSubscriptionStatus()
                    }
                }
            }
            .onChange(of: subsHasEnded) { newValue in
                print("🔄 BaseView: subsHasEnded changed to \(newValue)")
            }
            .onChange(of: loggedFirstTime) { newValue in
                print("🔄 BaseView: loggedFirstTime changed to \(newValue)")
            }
            .onChange(of: subsType) { newValue in
                print("🔄 BaseView: subsType changed to \(newValue)")
            }
            .onReceive(Tools.shared.$presentedBottomsheet) {
                self.bottomsheet = $0
            }
            .onAppear {
                print("🏠 BaseView appeared")
                print("   - logged: \(logged)")
                print("   - loggedFirstTime: \(loggedFirstTime)")
                print("   - subsType: \(subsType)")
                print("   - subsHasEnded: \(subsHasEnded)")
                print("   - subsEndDate: \(subsEndDate)")
                
                Task {
                    await appUpdateManager.checkForUpdates() { updateInfo in
                        Tools.shared.presentedBottomsheet = .showUpdateSheet(appUpdateManager)
                    }
                }
            }
        }
    }
}
