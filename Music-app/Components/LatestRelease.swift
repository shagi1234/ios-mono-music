//
//  LatestRelease.swift
//  Music-app
//
//  Created by SURAY on 01.03.2024.
//

import SwiftUI
import Kingfisher

struct LatestRelease: View {
    var latestRelese : LatestReleaseModel
    var isAlbum : Bool
    var onClick : () -> ()
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                Text(LocalizedStringKey("latest_release"))
                    .font(.med_15)
                    .foregroundStyle(Color.textGray)
                Spacer()
                Text((isAlbum ? latestRelese.album?.name : latestRelese.song?.name) ?? "")
                    .font(.bold_16)
                HStack{
                    Text(isAlbum ? "Album" : "Single")
                        .font(.med_15)
                        .foregroundStyle(Color.textGray)
                    Image(systemName: "circle.fill")
                        .resizable()
                        .frame(width: 3, height: 3)
                        .foregroundColor(Color.textGray)
                    Text(isAlbum ? String(latestRelese.album?.year ?? 0) : !isAlbum  ? String(latestRelese.song?.year ?? 0) : "" )
                        .font(.med_15)
                        .foregroundStyle(Color.textGray)
                }
            }
            Spacer()
            KFImage(isAlbum ? latestRelese.album?.image?.url : latestRelese.song?.image.url)
                .placeholder{ Image("cover-img").resizable().scaledToFill().cornerRadius(10)}
                .fade(duration: 0.25)
                .resizable()
                .frame(width: 70, height: 70)
                .cornerRadius(4)
                .scaledToFill()
            
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
        .frame(height: 90)
        .background(Color.textBlack)
        .cornerRadius(4)
        .listRowSeparator(.hidden)
        .onTapGesture {
            onClick()
        }
    }
}

//#Preview {
//    LatestRelease()
//}
