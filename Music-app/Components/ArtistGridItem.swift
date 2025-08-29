//
//  ArtistGridItem.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 17.08.2023.
//

import SwiftUI
import Kingfisher
struct ArtistGridItem: View {
    var data: ArtistModel
    
    var body: some View {
        HStack {
            KFImage(data.image.url)
                .placeholder{ Image("cover-img").resizable().scaledToFill().cornerRadius(5)}
                .fade(duration: 0.25)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .roundedCorner(10, corners: [.topLeft, .bottomLeft])
                .clipped()

            VStack(spacing: 6) {
                Text(data.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(2)
                    .foregroundColor(.white)
                    .font(.bold_14)
                    .padding(.horizontal, 10)
                
                Text(LocalizedStringKey("\(data.count ?? 0) "+"songs"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .foregroundColor(.textGray)
                    .font(.med_12)
                    .padding(.horizontal, 10)
            }
  
        }
            .background(Color.bgLightBlack)
            .cornerRadius(10)
    }
}

struct ArtistGridItem_Previews: PreviewProvider {
    static var previews: some View {
        ArtistGridItem(data: .example)
            .preferredColorScheme(.dark)
    }
}
