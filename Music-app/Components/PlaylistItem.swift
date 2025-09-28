//
//  PlaylistItem.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 17.08.2023.
//

import SwiftUI
import Kingfisher


struct PlaylistItem: View {
    var data: PlaylistModel
    var onMore: ()->()
    @StateObject var vm = MyPlaylistsVM()
    @State var playlist: PlaylistModel?
    
    var body: some View {
        HStack {
            if data.type == "local"{
                if playlist?.songs?.count ?? 1 >= 4 {
                    VStack(spacing: 0){
                        HStack(spacing: 0){
                            KFImage(playlist?.songs?.last?.image.url)
                                .placeholder{ Image("cover-img").resizable().scaledToFill().cornerRadius(5)}
                                .fade(duration: 0.25)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 30, height: 30)
                              
                            KFImage(playlist?.songs?[(playlist?.songs?.count ?? 1) - 2].image.url)
                                .placeholder{ Image("cover-img").resizable().scaledToFill().cornerRadius(5)}
                                .fade(duration: 0.25)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 30, height: 30)
                           
                        }
                        HStack(spacing: 0){
                            KFImage(playlist?.songs?[(playlist?.songs?.count ?? 1) - 3].image.url)
                                .placeholder{ Image("cover-img").resizable().scaledToFill().cornerRadius(5)}
                                .fade(duration: 0.25)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 30, height: 30)
                            
                            KFImage(playlist?.songs?[(playlist?.songs?.count ?? 1) - 4].image.url)
                                .placeholder{ Image("cover-img").resizable().scaledToFill().cornerRadius(5)}
                                .fade(duration: 0.25)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 30, height: 30)
                                
                        }
                    }
                    .frame(width: 60, height: 60)
                    .cornerRadius(3)
                    .clipped()
                  
                }else{
                    KFImage(playlist?.songs?.last?.image.url)
                        .placeholder{ Image("cover-img").resizable().scaledToFill().cornerRadius(5)}
                        .fade(duration: 0.25)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .cornerRadius(3)
                        .clipped()
                }
                
                    
            }else{
                KFImage(data.cover?.url)
                    .placeholder{ Image("cover-img").resizable().scaledToFill().cornerRadius(5)}
                    .fade(duration: 0.25)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .cornerRadius(3)
                    .clipped()
            }
            
            VStack(spacing: 6) {
                Text(data.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(2)
                    .foregroundColor(.white)
                    .font(.bold_16)
                    .multilineTextAlignment(.leading)
                
                HStack(spacing: 4) {
                    Image(data.isDownloadOn == true ? "download-song" : "save-playlist")
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: data.isDownloadOn == true ? 14 : 24, height: data.isDownloadOn == true ? 14 : 24, alignment:.center)
                        .foregroundColor( data.isDownloadOn == true ? .accentColor :  .textGray)
                    
                    Text(LocalizedStringKey(data.type ?? ""))
                        .lineLimit(1)
                        .foregroundColor(.textGray)
                        .font(.med_15)
                    
                    Text(LocalizedStringKey("• \(data.count ?? 0) "+"songs"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                        .foregroundColor(.textGray)
                        .font(.med_15)
                }
            }
            
            Button {
                onMore()
            } label: {
                Image("v-more-16")
                    .frame( maxHeight: .infinity, alignment: .center)
            }.pressAnimation()
        }
        .padding(.vertical, 5)
        .onAppear{
            if data.type == "local" {
                self.playlist   =  vm.getLocalData(id: data.localId ?? 1)
            }
        }
    }
}

struct PlaylistItem_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistItem(data: .example, onMore: {
            
        }).preferredColorScheme(.dark)
    }
}
