//
//  LocalPlaylistItem.swift
//  Music-app
//
//  Created by Shirin on 12.10.2023.
//

import SwiftUI

struct LocalPlaylistItem: View {
    var data: PlaylistModel
    
    var body: some View {
        HStack {
            Image("playlist-placeholder")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
            
            VStack(spacing: 4) {
                Text(data.name)
                    .font(.bold_16)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(LocalizedStringKey("\(data.count ?? 0) songs"))
                    .font(.reg_15)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }.frame(height: 40)
            .contentShape(Rectangle())
    }
}

struct LocalPlaylistItem_Previews: PreviewProvider {
    static var previews: some View {
        LocalPlaylistItem(data: .example)
            .preferredColorScheme(.dark)
    }
}
