//
//  VPNMonitor.swift
//  Music-app
//
//  Created by SURAY on 19.08.2024.
//
import SwiftUI
import Foundation

class VPNMonitor: ObservableObject {
    @Published var isConnected: Bool = false
    
    private let vpnChecker = VpnChecker()
    
    func startMonitoring() {
        print("started monitoring")
        isConnected = VpnChecker.isVpnActive()
        print(self.isConnected)
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main, using: { [weak self] _ in
            self?.isConnected = VpnChecker.isVpnActive()
        })
    }
}


struct VpnChecker {
    private static let vpnProtocolsKeysIdentifiers = [
        "tap", "tun", "ppp", "ipsec", "utun"
    ]

    static func isVpnActive() -> Bool {
        guard let cfDict = CFNetworkCopySystemProxySettings() else { return false }
        let nsDict = cfDict.takeRetainedValue() as NSDictionary
        guard let keys = nsDict["__SCOPED__"] as? NSDictionary,
            let allKeys = keys.allKeys as? [String] else { return false }

        // Checking for tunneling protocols in the keys
        for key in allKeys {
            for protocolId in vpnProtocolsKeysIdentifiers
                where key.starts(with: protocolId) {
                return true
            }
        }
        return false
    }
}
