//
//  PlayerSwipeUpView.swift
//  Music-app
//
//  Created by Shirin on 29.09.2023.
//

import SwiftUI

struct PlayerSwipeUpView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "chevron.up")
                .foregroundColor(.white)

            Text(LocalizedStringKey("swipe_for_more"))
                .font(.reg_15)
                .foregroundColor(.textLightGray)
                .lineLimit(0)
                .multilineTextAlignment(.leading)
        }.frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color.clear)
            .contentShape(Rectangle())
    }
}

struct PlayerSwipeUpView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerSwipeUpView()
    }
}
