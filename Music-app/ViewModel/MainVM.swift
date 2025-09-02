//
//  MainVM.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 17.08.2023.
//

import Foundation
import Resolver
import Kingfisher

class MainVM: ObservableObject {
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
        guard !Defaults.subsEndDate.isEmpty else { return false }
        
        let currentDate = Date()
        let endDate = dateFromString(Defaults.subsEndDate)
        
        return currentDate >= endDate
    }
    
    func checkSubscriptionStatus() {
        if hasSubscriptionExpired() {
            DispatchQueue.main.async {
                Defaults.subsHasEnded = true
                Defaults.subsType = ""
            }
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
