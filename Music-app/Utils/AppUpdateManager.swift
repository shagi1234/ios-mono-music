//
//  AppStoreResponse.swift
//  Music-app
//
//  Created by Shahruh on 25.09.2025.
//

import Foundation
import UIKit

struct AppStoreResponse: Codable {
    let results: [AppStoreResult]
}

struct AppStoreResult: Codable {
    let version: String
    let releaseNotes: String?
    let trackViewUrl: String
    let minimumOsVersion: String
}

struct UpdateInfo {
    let currentVersion: String
    let latestVersion: String
    let releaseNotes: String
    let appStoreURL: String
    let isUpdateAvailable: Bool
    let isForceUpdate: Bool
}

class AppUpdateManager: ObservableObject {
    @Published var updateInfo: UpdateInfo?
    
    private let appID: String
    private let forceUpdateVersions: [String]
    
    init(appID: String, forceUpdateVersions: [String] = []) {
        self.appID = appID
        self.forceUpdateVersions = forceUpdateVersions
    }
    
    func checkForUpdates(completion: ( (UpdateInfo) -> Void)? = nil) async {
          do {
              let updateInfo = try await fetchUpdateInfo()
              await MainActor.run {
                  self.updateInfo = updateInfo
                  if updateInfo.isUpdateAvailable {
                      completion?(updateInfo)
                  }
              }
          } catch {
              print("Failed to check for updates: \(error)")
          }
      }
    
    private func fetchUpdateInfo() async throws -> UpdateInfo {
        guard let url = URL(string: "https://itunes.apple.com/lookup?id=\(appID)") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(AppStoreResponse.self, from: data)
        
        guard let result = response.results.first else {
            throw URLError(.badServerResponse)
        }
        
        let currentVersion = getCurrentAppVersion()
        let latestVersion = result.version
        let isUpdateAvailable = isVersion(latestVersion, newerThan: currentVersion)
        let isForceUpdate = forceUpdateVersions.contains(currentVersion)
        
        return UpdateInfo(
            currentVersion: currentVersion,
            latestVersion: latestVersion,
            releaseNotes: result.releaseNotes ?? "Bug fixes and improvements",
            appStoreURL: result.trackViewUrl,
            isUpdateAvailable: isUpdateAvailable,
            isForceUpdate: isForceUpdate
        )
    }
    
    private func getCurrentAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    private func isVersion(_ version1: String, newerThan version2: String) -> Bool {
        return version1.compare(version2, options: .numeric) == .orderedDescending
    }
    
    func openAppStore() {
        guard let updateInfo = updateInfo,
              let url = URL(string: updateInfo.appStoreURL) else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func dismissUpdate() {
        guard let updateInfo = updateInfo, !updateInfo.isForceUpdate else { return }
        
        DispatchQueue.main.async {
            Tools.shared.presentedBottomsheet = nil
        }
        
        UserDefaults.standard.set(updateInfo.latestVersion, forKey: "dismissedUpdateVersion")
    }
    
    private func shouldShowUpdateForVersion(_ version: String) -> Bool {
        let dismissedVersion = UserDefaults.standard.string(forKey: "dismissedUpdateVersion")
        return dismissedVersion != version
    }
}
