//
//  MyPlaylistsHeader.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 17.08.2023.
//

import SwiftUI

struct MyPlaylistsHeader: View {
    var onAdd: ()->()
    let impactMed = UIImpactFeedbackGenerator(style: .light)
    var body: some View {
        HStack {
            Text(LocalizedStringKey("my_playlists"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.bold_22)
                .foregroundColor(.white)
                .lineLimit(0)
                .multilineTextAlignment(.leading)

            Button {
                onAdd()
               
                impactMed.impactOccurred()
            } label: {
                Image("add_library")
                    .renderingMode(.template)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44, alignment: .center)
            }.pressAnimation()
            
        }
        .frame(maxWidth: .infinity)
        .background(Color.bgBlack)
        .padding(.horizontal, 20)
            .padding(.vertical, 10)
    }
}

struct MyPlaylistsHeader_Previews: PreviewProvider {
    static var previews: some View {
        MyPlaylistsHeader(onAdd: {
            
        })
    }
}
