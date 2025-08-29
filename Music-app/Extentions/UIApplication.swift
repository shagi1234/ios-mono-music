//
//  UIApplication.swift
//  Music-app
//
//  Created by Shirin on 10.10.2023.
//

import UIKit.UIApplication

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
