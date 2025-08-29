//
//  ConditionalSimultaneousGesture.swift
//  Music-app
//
//  Created by SURAY on 21.08.2024.
//

import SwiftUI


struct ConditionalSimultaneousGesture<GestureType: Gesture>: ViewModifier {
    var applyGesture: Bool
    var dragGesture: GestureType

    func body(content: Content) -> some View {
        if applyGesture {
            return AnyView(content.simultaneousGesture(dragGesture))
        } else {
            return AnyView(content)
        }
    }
}

extension View {
    func conditionalSimultaneousGesture<GestureType: Gesture>(_ applyGesture: Bool, dragGesture: GestureType) -> some View {
        self.modifier(ConditionalSimultaneousGesture(applyGesture: applyGesture, dragGesture: dragGesture))
    }
}



