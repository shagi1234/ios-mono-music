//
//  StorageKeys.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 16.08.2023.
//

import Foundation

enum DefaultsKeys: String {
    case token
    case refreshToken
    case logged
    case lang
    case searchHistory
    case phone
    case loggedFirstTime
    case fullName
    case birthDay
    case subsEndDate
    case gender
    case loggedOut
    case subsType
    case subsHasEnded
    
}

class Defaults {

    static var token: String {
        get { UserDefaults.standard.string(forKey: DefaultsKeys.token.rawValue) ?? "" }
        set { UserDefaults.standard.setValue(newValue, forKey: DefaultsKeys.token.rawValue) }
    }
    
    static var refreshToken: String {
        get { UserDefaults.standard.string(forKey: DefaultsKeys.refreshToken.rawValue) ?? "" }
        set { UserDefaults.standard.setValue(newValue, forKey: DefaultsKeys.refreshToken.rawValue) }
    }
    
    static var logged: Bool {
        get { UserDefaults.standard.bool(forKey: DefaultsKeys.logged.rawValue) }
        set { UserDefaults.standard.setValue(newValue, forKey: DefaultsKeys.logged.rawValue) }
    }
    
    static var lang: String {
        get { UserDefaults.standard.string(forKey: DefaultsKeys.lang.rawValue) ?? "tk" }
        set { UserDefaults.standard.setValue(newValue, forKey: DefaultsKeys.lang.rawValue) }
    }
    
    static var searchHistory: [String] {
        get { UserDefaults.standard.stringArray(forKey: DefaultsKeys.searchHistory.rawValue) ?? [] }
        set { UserDefaults.standard.setValue(newValue, forKey: DefaultsKeys.searchHistory.rawValue) }
    }
    
    static var phone: String {
        get { UserDefaults.standard.string(forKey: DefaultsKeys.phone.rawValue) ?? "" }
        set { UserDefaults.standard.setValue(newValue, forKey: DefaultsKeys.phone.rawValue) }
    }
    
    static var loggedFirstTime: Bool {
        get { UserDefaults.standard.bool(forKey: DefaultsKeys.loggedFirstTime.rawValue) }
        set { UserDefaults.standard.setValue(newValue, forKey: DefaultsKeys.loggedFirstTime.rawValue) }
    }
    
    static var loggedOut: Bool {
        get { UserDefaults.standard.bool(forKey: DefaultsKeys.loggedOut.rawValue) }
        set { UserDefaults.standard.setValue(newValue, forKey: DefaultsKeys.loggedOut.rawValue) }
    }
    
    static var fullName: String {
        get { UserDefaults.standard.string(forKey: DefaultsKeys.fullName.rawValue) ?? "" }
        set { UserDefaults.standard.setValue(newValue, forKey: DefaultsKeys.fullName.rawValue) }
    }
    
    static var birthDay: String {
        get { UserDefaults.standard.string(forKey: DefaultsKeys.birthDay.rawValue) ?? "" }
        set { UserDefaults.standard.setValue(newValue, forKey: DefaultsKeys.birthDay.rawValue) }
    }
    
    static var subsEndDate: String {
        get { UserDefaults.standard.string(forKey: DefaultsKeys.subsEndDate.rawValue) ?? "" }
        set { UserDefaults.standard.setValue(newValue, forKey: DefaultsKeys.subsEndDate.rawValue) }
    }
    
    static var gender: String {
        get { UserDefaults.standard.string(forKey: DefaultsKeys.gender.rawValue) ?? "" }
        set { UserDefaults.standard.setValue(newValue, forKey: DefaultsKeys.gender.rawValue) }
    }

    static var subsType: String {
        get { UserDefaults.standard.string(forKey: DefaultsKeys.subsType.rawValue) ?? "" }
        set { UserDefaults.standard.setValue(newValue, forKey: DefaultsKeys.subsType.rawValue) }
    }
    
    
    static var subsHasEnded: Bool {
        get { UserDefaults.standard.bool(forKey: DefaultsKeys.subsHasEnded.rawValue) }
        set { UserDefaults.standard.setValue(newValue, forKey: DefaultsKeys.subsHasEnded.rawValue) }
    }

    static func logout(){
        token = ""
        refreshToken = ""
        phone = ""
        fullName = ""
        logged = false
        birthDay = ""
        subsEndDate = ""
        subsType = ""
        subsHasEnded = false
        searchHistory = []
        loggedFirstTime = false
        lang = "tk"
        AppDatabase.shared.deleteAllPlaylists()
    }
    
}
