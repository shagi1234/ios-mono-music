//
//  BottomSheetBtnView.swift
//  Music-app
//
//  Created by Shirin on 29.09.2023.
//

import SwiftUI

struct BottomSheetBtnView: View {
    var bgColor = Color.darkBlue
    var type: BottomSheetBtn
    var onClick: ()->()
    
    var body: some View {
        HStack {
            Image(type.data.leadingIcon)
                .resizable()
                .renderingMode(.template)
                .frame(width: type.data.title == "download_all_songs_in_playlist" ? 18 : 24, height:  type.data.title == "download_all_songs_in_playlist" ? 18 : 24, alignment: .center)
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 1){
                Text( LocalizedStringKey(type.data.title))
                    .font(.bold_16)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
  
            }

            if let icon = type.data.trailingIcon {
                Image(systemName: icon)
                    .frame(width: 24, height: 24, alignment: .center)
                    .foregroundColor(.white)
            }
        }.frame(height: 37)
            .listRowBackground(bgColor)
            .contentShape(Rectangle())
            .onTapGesture {
                onClick()
            }
    }
}

struct BottomSheetBtnView_Previews: PreviewProvider {
    static var previews: some View {
        BottomSheetBtnView(type: .addToPlaylist, onClick: {})
    }
}
