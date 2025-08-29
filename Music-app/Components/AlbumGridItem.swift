//
//  AlbumGridItem.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 17.08.2023.
//

import SwiftUI
import Kingfisher

struct AlbumGridItem: View {
    var data: PlaylistModel
    
    var body: some View {
        ZStack {
            KFImage(data.image?.url)
                .placeholder{ Image("cover-img").resizable().scaledToFill().cornerRadius(5)}
//                .cacheMemoryOnly()
                .fade(duration: 0.25)
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width*0.8,
                       height: UIScreen.main.bounds.width*0.8)
                .cornerRadius(10)
                .clipped()

            VStack {
                Spacer()

                LinearGradient(colors: [.black.opacity(0.9), .black.opacity(0.4), .clear], startPoint: .bottom, endPoint: .top)
                    .frame(width: UIScreen.main.bounds.width*0.8,
                           height: UIScreen.main.bounds.width*0.3)
                    .cornerRadius(10)
            }
            
            VStack {
                Spacer()
                
                HStack {
                    VStack(spacing: 4) {
                        Text(data.name)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.white)
                            .font(.bold_16)
                            .padding(.horizontal, 10)
                        
                        Text(data.artists?.first?.name ?? "")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(1)
                            .foregroundColor(.textGray)
                            .font(.reg_15)
                            .padding(.horizontal, 10)
                    }
                    
                    Text(String(data.year ?? 0))
//                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .lineLimit(1)
                        .foregroundColor(.textLightGray)
                        .font(.bold_14)
                        .padding(.horizontal, 10)
                    
                }
            }.padding(.bottom, 10)
        }.frame(width: UIScreen.main.bounds.width*0.8,
                height: UIScreen.main.bounds.width*0.8)
        .padding(.horizontal, 5)
            .padding(.vertical, 15)
    }
}

struct AlbumGridItem_Previews: PreviewProvider {
    static var previews: some View {
        AlbumGridItem(data: PlaylistModel.example)
            .preferredColorScheme(.dark)
    }
}
