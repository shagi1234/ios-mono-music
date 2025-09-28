//
//  Tools.swift
//  Music-app
//
//  Created by Shahruh Air on 25.09.2025.
//
import SwiftUI

class Tools: ObservableObject {
    @Published var presentedBottomsheet: BottomSheet? = nil
    
    static var shared = Tools()
    
}
