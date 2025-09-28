//
//  LottieView.swift
//  Music-app
//
//  Created by Shahruh on 25.09.2025.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let animationName: String
    let loopMode: LottieLoopMode
    let animationSpeed: CGFloat
    let tintColor: UIColor?
    
    init(
        name: String,
        loopMode: LottieLoopMode = .loop,
        speed: CGFloat = 1,
        tintColor: Color? = nil
    ) {
        self.animationName = name
        self.loopMode = loopMode
        self.animationSpeed = speed
        self.tintColor = tintColor != nil ? UIColor(tintColor!) : nil
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        let animationView = LottieAnimationView()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
        if let animation = LottieAnimation.named(animationName) {
            animationView.animation = animation
            animationView.contentMode = .scaleAspectFit
            animationView.loopMode = loopMode
            animationView.animationSpeed = animationSpeed
            
            // Apply tint color if provided
            if let tintColor = tintColor {
                animationView.tintColor = tintColor
                // Alternative method for better color support
                animationView.backgroundColor = UIColor.clear
                view.tintColor = tintColor
            }
            
            animationView.play()
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let animationView = uiView.subviews.first as? LottieAnimationView {
            if let tintColor = tintColor {
                animationView.tintColor = tintColor
                uiView.tintColor = tintColor
            }
        }
    }
}

struct AdvancedLottieView: UIViewRepresentable {
    let animationName: String
    let loopMode: LottieLoopMode
    let animationSpeed: CGFloat
    let colorKeyPath: String?
    let color: UIColor?
    
    init(
        name: String,
        loopMode: LottieLoopMode = .loop,
        speed: CGFloat = 1,
        colorKeyPath: String? = nil,
        color: Color? = nil
    ) {
        self.animationName = name
        self.loopMode = loopMode
        self.animationSpeed = speed
        self.colorKeyPath = colorKeyPath
        self.color = color != nil ? UIColor(color!) : nil
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        let animationView = LottieAnimationView()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
        if let animation = LottieAnimation.named(animationName) {
            animationView.animation = animation
            animationView.contentMode = .scaleAspectFit
            animationView.loopMode = loopMode
            animationView.animationSpeed = animationSpeed
            
            // Advanced color control using key paths
            if let keyPath = colorKeyPath, let color = color {
                let colorProvider = ColorValueProvider(color.lottieColorValue)
                animationView.setValueProvider(colorProvider, keypath: AnimationKeypath(keypath: keyPath))
            }
            // Fallback to tint color
            else if let color = color {
                animationView.tintColor = color
            }
            
            animationView.play()
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Handle updates if needed
    }
}

// MARK: - Usage Examples
/*
// Basic usage with tint color:
LottieView(
    name: "loading",
    loopMode: .loop,
    speed: 1.0,
    tintColor: .blue
)

// With accent color:
LottieView(
    name: "loading",
    loopMode: .loop,
    speed: 1.0,
    tintColor: .accentColor
)

// With custom color:
LottieView(
    name: "loading",
    loopMode: .loop,
    speed: 1.0,
    tintColor: Color(red: 0.2, green: 0.8, blue: 0.4)
)

// Advanced color control (if you know the keypath):
AdvancedLottieView(
    name: "loading",
    loopMode: .loop,
    speed: 1.0,
    colorKeyPath: "**.Fill 1.Color",
    color: .red
)
*/
