//
//  CircularArtistItem.swift
//  Music-app
//
//  Created by Shahruh on 09.07.2025.
//


import SwiftUI
import Kingfisher

struct CircularArtistItem: View {
    var data: ArtistModel
    
    var body: some View {
        VStack(spacing: 10) {
            KFImage(data.image.url)
                .placeholder{ 
                    Image("cover-img")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                }
                .fade(duration: 0.25)
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .clipped()
            
            Text(data.name)
                .font(.bold_14)
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 120)
        }
        .frame(width: 120)
    }
}

struct CircularArtistItem_Previews: PreviewProvider {
    static var previews: some View {
        CircularArtistItem(data: .example)
            .preferredColorScheme(.dark)
            .background(Color.bgBlack)
    }
}
