//
//  BottomSheetView.swift
//  Music-app
//
//  Created by Shahruh on 25.09.2025.
//


import SwiftUI
import Resolver

struct BottomSheetView<Content: View>: View {
    @StateObject var mainVM = MainVM()
    @GestureState private var translation: CGFloat = 0
    
    private var offset: CGFloat = 0
    var content: () -> Content
    
    init(content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            
            VStack(alignment: .center, spacing: 0) {
                
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.gray)
                    .frame(width: 56, height: 6)
                    .padding(8)
                
                self.content()
                    .padding(.horizontal, 8)
                
            }
            .frame(maxWidth: UIScreen.main.bounds.width - 16)
            .background(Color.bgLightBlack)
            .cornerRadius(32)
            .offset(y: max(self.offset, self.translation, 0))
            .animation(.interactiveSpring(), value: translation)
            .gesture(
                DragGesture().updating(self.$translation) { value, state, _ in
                    state = value.translation.height
                    
                }.onEnded { value in
                    let snapDistance = UIScreen.main.bounds.height/4
                    guard abs(value.translation.height) > snapDistance else { return }
                    
                    DispatchQueue.main.async {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        Tools.shared.presentedBottomsheet = nil
                    }
                }
            )
//            .padding(.bottom,safeArea.bottom)
        }
    }
}

struct RoundedCornerShape: Shape {
    var corners: UIRectCorner
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
