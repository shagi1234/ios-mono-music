//
//  PlayingAnimatedView.swift
//  Music-app
//
//  Created by Shirin on 22.01.2024.
//

import SwiftUI
import NVActivityIndicatorView

struct ActivityIndicatorView: UIViewRepresentable {
    var type: NVActivityIndicatorType
    var color: Color
    var size: CGFloat
    var isAnimating: Bool

    func makeUIView(context: Context) -> NVActivityIndicatorView {
           let view = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: size, height: size), type: type, color: UIColor(color), padding: 0)
            view.startAnimating()
            return view
        }

        func updateUIView(_ uiView: NVActivityIndicatorView, context: Context) {
            if isAnimating {
                uiView.startAnimating()
            } else {
                uiView.stopAnimating()
            }
        }
}
