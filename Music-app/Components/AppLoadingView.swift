//
//  AppLoadingView.swift
//  Music-app
//
//  Created by MacBook Air on 25.09.2025.
//

import SwiftUI

struct AppLoadingView : View {
    
    var body: some View {
        VStack{
            Spacer()
            HStack{
                Spacer()
                LottieView(
                    name: "loading",
                    loopMode: .loop,
                    speed: 1.0
                )
                Spacer()
            }
            Spacer()
        }
    }
}
