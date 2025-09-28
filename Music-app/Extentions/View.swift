//
//  View.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 19.08.2023.
//

import SwiftUI
import Combine

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            
            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
    var safeArea: UIEdgeInsets {
        if #available(iOS 15.0, *) {
            if let safeArea = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow?.safeAreaInsets {
                return safeArea
            }
        } else {
            if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                return window.safeAreaInsets
            }
        }
        return .zero
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

extension View {
    @ViewBuilder func onValueChanged<T: Equatable>(of value: T, perform onChange: @escaping (T) -> Void) -> some View {
        if #available(iOS 14.0, *) {
            self.onChange(of: value, perform: onChange)
        } else {
            self.onReceive(Just(value)) { (value) in
                onChange(value)
            }
        }
    }
}

public extension View {
    func animationObserver<Value: VectorArithmetic>(for value: Value,
                                                    onChange: ((Value) -> Void)? = nil,
                                                    onComplete: (() -> Void)? = nil) -> some View {
        self.modifier(AnimationObserverModifier(for: value,
                                                onChange: onChange,
                                                onComplete: onComplete))
    }
}

extension View {
    func measureSize(perform action: @escaping (CGSize) -> Void) -> some View {
        self.modifier(MeasureSizeModifier())
            .onPreferenceChange(SizePreferenceKey.self, perform: action)
    }
}
struct ScrollFriendlyButtonModifier: ViewModifier {
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.97 : 1)
            .opacity(isPressed ? 0.9 : 1)
            .animation(.easeInOut(duration: 0.15), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { _ in
                        if !isPressed {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .soft)
                            impactFeedback.impactOccurred()
                            
                            withAnimation(.easeInOut(duration: 0.15)) {
                                isPressed = true
                            }
                        }
                    }
                    .onEnded { value in
                        withAnimation(.easeInOut(duration: 0.15)) {
                            isPressed = false
                        }
                        
                        // Only allow button press if drag distance is very small
                        let distance = sqrt(pow(value.translation.width, 2) + pow(value.translation.height, 2))
                        if distance > 10 {
                            // Prevent button action on scroll by consuming the gesture
                        }
                    }
            )
    }
}

extension Button {
    func pressAnimation() -> some View {
        self
            .buttonStyle(PlainButtonStyle())
            .modifier(ScrollFriendlyButtonModifier())
    }
}

struct ScrollFriendlyPressModifier: ViewModifier {
    let action: () -> Void
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.97 : 1)
            .opacity(isPressed ? 0.9 : 1)
            .animation(.easeInOut(duration: 0.15), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { _ in
                        if !isPressed {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .soft)
                            impactFeedback.impactOccurred()
                            
                            withAnimation(.easeInOut(duration: 0.15)) {
                                isPressed = true
                            }
                        }
                    }
                    .onEnded { value in
                        withAnimation(.easeInOut(duration: 0.15)) {
                            isPressed = false
                        }
                        
                        let distance = sqrt(pow(value.translation.width, 2) + pow(value.translation.height, 2))
                        if distance <= 10 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                action()
                            }
                        }
                    }
            )
    }
}

extension View {
    func pressWithAnimation(_ action: @escaping () -> Void) -> some View {
        return self.modifier(ScrollFriendlyPressModifier(action: action))
    }
}

