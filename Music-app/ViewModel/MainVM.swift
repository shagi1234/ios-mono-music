//
//  MainVM.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 17.08.2023.
//

import Foundation
import Resolver
import Kingfisher
import SwiftUI

class MainVM: ObservableObject {
    @AppStorage(DefaultsKeys.subsEndDate.rawValue) var subsEndDate: String = ""
    @AppStorage(DefaultsKeys.subsHasEnded.rawValue) var subsHasEnded: Bool = false
    
    @Published var expand : Bool = false
    @Published var selectedTab = 0
    @Published var oldTab = 0
    @Published var artistId: Int64?
    @Published var albumId: Int64?
    @Published var artists : [ArtistModel]?
    @Published var artistsCount : Int?
    @Published var canShowDelete : Bool?
    @Published var playlist: PlaylistModel?
    @Published var offset : CGFloat = 0
    @Published var playlistPresented = false
    @Published var playlistIds: [String: Int64] = [:]
    @Published var showPopUp : Bool = false
    @Published var deleted : Bool = false
    @Published var showNoConnectionPopUp : Bool = false
    @Published var changeOpacity : Bool = false
    @Published var showAddToPlaylist : Bool = false
    @Published var downloadError : Bool = false
    @Published var downloadingPlaylist : [PlaylistModel]?
    @Published var popUpType: PopupType? = nil
    
    
    init(){
        ImageCache.default.memoryStorage.config.expiration = .days(7)
    }
    
    func getDate() -> String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func hasSubscriptionExpired() -> Bool {
        guard !subsEndDate.isEmpty else {
            print("⚠️ No subscription end date")
            return false
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current
        
        guard let endDate = dateFormatter.date(from: subsEndDate) else {
            print("❌ Failed to parse date: \(subsEndDate)")
            return false
        }
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        
        guard let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) else {
            print("❌ Failed to set end of day")
            return false
        }
        
        let currentDate = Date()
        let hasExpired = currentDate > endOfDay
        
        print("📅 Subscription expired check:")
        print("   - Current: \(currentDate)")
        print("   - End Date: \(subsEndDate) at \(endOfDay)")
        print("   - Has Expired: \(hasExpired)")
        
        return hasExpired
    }
    
    func checkSubscriptionStatus() {
        let expired = hasSubscriptionExpired()
        
        print("🔍 Checking subscription status...")
        print("   - subsEndDate: \(subsEndDate)")
        print("   - Currently marked as expired: \(subsHasEnded)")
        print("   - Actually expired: \(expired)")
        
        if subsHasEnded != expired {
            print("   ⚡️ Updating subsHasEnded from \(self.subsHasEnded) to \(expired)")
            DispatchQueue.main.async {
                self.subsHasEnded = expired
            }
        } else {
            print("   ✓ No update needed - subsHasEnded already correct")
        }
    }
    
    private func dateFromString(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString) ?? Date.distantPast
    }
}

extension Defaults {
    static var hasActiveSubscription: Bool {
        return !subsHasEnded && !subsEndDate.isEmpty && !subsType.isEmpty
    }
    
    static func daysRemainingInSubscription() -> Int {
        guard !subsEndDate.isEmpty else { return 0 }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let endDate = formatter.date(from: subsEndDate) else { return 0 }
        
        let currentDate = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: currentDate, to: endDate)
        
        return max(0, components.day ?? 0)
    }
}
