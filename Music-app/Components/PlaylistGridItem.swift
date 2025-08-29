//
//  PlaylistGridItem.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 17.08.2023.
//

import SwiftUI
import Kingfisher

struct PlaylistGridItem: View {
    var data: PlaylistModel
    var isalbums:  Bool = false
    
    var body: some View {
        VStack {
            KFImage(data.image?.url)
                .placeholder {
                    Image("cover-img")
                        .resizable()
                        .scaledToFill()
                        .cornerRadius(5)
                }
                .fade(duration: 0.25)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: UIScreen.main.bounds.width * (isalbums ? 0.45 : 0.4),
                       maxWidth: 180,
                       minHeight: UIScreen.main.bounds.width * (isalbums ? 0.45 : 0.4),
                       maxHeight: 180)
                .clipped()
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(10)
            
            
            Text(data.name)
                .frame(maxWidth: UIScreen.main.bounds.width * (isalbums ? 0.45 : 0.45) - 20, alignment: .leading)
                .frame(maxHeight: 20, alignment: .top)
                .foregroundColor(.white)
                .font(.bold_14)
                .padding(.horizontal, 10)
            
            Spacer()
        }
        .padding(.horizontal, 5)
    }
}

struct PlaylistGridItem_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistGridItem(data: PlaylistModel.example)
            .preferredColorScheme(.dark)
    }
}
