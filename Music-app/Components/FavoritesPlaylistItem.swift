//
//  FavoritesPlaylistItem.swift
//  Music-app
//
//  Created by MacBook Air on 01.10.2025.
//

import SwiftUI

struct FavoritesItem: View {
    var songCount: Int
    
    var body: some View {
        HStack {
            Image("FavoritesCover")
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .cornerRadius(3)
                .clipped()
            
            VStack(spacing: 6) {
                Text(LocalizedStringKey("Favorites"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(2)
                    .foregroundColor(.white)
                    .font(.bold_16)
                    .multilineTextAlignment(.leading)
                
                HStack(spacing: 4) {
                    Image("save-playlist")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 24, height: 24, alignment: .center)
                        .foregroundColor(.textGray)
                    
                    Text(LocalizedStringKey("playlist"))
                        .lineLimit(1)
                        .foregroundColor(.textGray)
                        .font(.med_15)
                    
                    Text(LocalizedStringKey("• \(songCount) " + "songs"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                        .foregroundColor(.textGray)
                        .font(.med_15)
                }
            }
        }
        .padding(.vertical, 5)
    }
}
