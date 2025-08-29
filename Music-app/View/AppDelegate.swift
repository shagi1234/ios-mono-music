//
//  AppDelegate.swift
//  Music-app
//
//  Created by SURAY on 24.08.2024.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    var backgroundCompletionHandler: (() -> Void)?

    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        debugPrint("handleEventsForBackgroundURLSession: \(identifier)")
        backgroundCompletionHandler = completionHandler
    }
    func application(
           _ application: UIApplication,
           didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
       ) -> Bool {
        
           return true
       }
}

