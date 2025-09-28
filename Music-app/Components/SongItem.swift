//
//  SongItem.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 17.08.2023.
//

import SwiftUI
import Kingfisher
import Resolver

struct SongItem: View {
    @StateObject private var downloadManager = DownloadManager.shared
    @StateObject var vm = Resolver.resolve(PlayerVM.self)
    var data: SongModel
    var current: Bool
    @State var isPlaying : Bool
    var moveOn = false
    var isAlbum : Bool = false
    var index: Int = 0
    @State var disabled : Bool = false
    var onMore: (()->())? = nil
    var drag: (()->())? = nil
    @State  var offset : CGFloat = 0
    @State var isDragging : Bool = false
    let minDragThreshold: CGFloat = 20
    let impactMed = UIImpactFeedbackGenerator(style: .medium)
    private var scale: CGFloat {
           UIScreen.main.scale
       }
    
    var body: some View {

        ZStack{
            if isDragging && drag != nil{
                ZStack{
                    Color.accentColor
                        .frame(width: 200)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .opacity(isDragging ? 1 : 0)
                    Image("inserted")
                        .renderingMode(.template)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .frame(maxHeight: .infinity, alignment: .center)
                        .offset(x: offset - offset / 2)
                }
                .frame(minHeight: isAlbum ? 64 : 70, maxHeight: isAlbum ? 64 : 70)
            }
            if drag != nil{
                songItem()
                    .frame(minHeight: isAlbum ? 64 : 70, maxHeight: isAlbum ? 64 : 70)
                    .frame(maxWidth: UIScreen.main.bounds.width )
                    .background( drag != nil ? Color.bgBlack : Color.clear)
                    .offset(x:  offset )
                
                
            }else{
                songItem()
                    .frame(minHeight: 60, maxHeight:  60)
                    .background( drag != nil ? Color.bgBlack : Color.clear)
            }
        }
        .frame(maxWidth: UIScreen.main.bounds.width )
    }
}

extension SongItem{
    @ViewBuilder
    func songItem() -> some View{
        HStack {
            if !isAlbum{
                    KFImage(data.image.url)
                        .placeholder{ Image("cover-img").resizable().scaledToFill().cornerRadius(5)   .frame(width: 60, height: 60)}
                        .resizable()
                        .fade(duration: 0.25)
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .cornerRadius(5)
                        .clipped()
                        .overlay(
                            ZStack {
                                if disabled{
                                    RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.black.opacity(0.5))
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                }
                                
                                if downloadManager.downloadQueue[data.id] != nil {
                                    ZStack {
                                        CircularProgressView(progress: downloadManager.currentDownloadingSong?.song.id != data.id ? 0 : downloadManager.currentDownloadingSong?.progress ?? 0)
                                            .frame(width: 32, height: 32, alignment: .center)
                                        
                                        Image(systemName: "arrow.down.to.line")
                                            .imageScale(.small)
                                            .accentColor(.white)
                                        
                                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .background(Color.black.opacity(0.5))
                                }
                            }
                        )
            }else{
                Text("\(index)")
                    .font(.med_15)
                    .foregroundColor(disabled ? .textGray : .white)
            }
            
            HStack {
                VStack {
                    if  current {
                        HStack{
                            if vm.isPlaying(){
                                ActivityIndicatorView(type: .audioEqualizer, color: Color("AccentColor"), size: 14, isAnimating: vm.isPlaying())
                                    .frame(width: 12, height: 14, alignment: .center)
                            }
                            Text(data.name)
                                .font(.bold_16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(1)
                                .foregroundColor(Color.accentColor)
                        }
                    } else {
                        Text(data.name)
                            .font(.bold_16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(1)
                            .foregroundColor(disabled ? .textGray : .white)
                          
                    }
                       
                    
                    HStack(spacing: 4) {
                        if isAlbum{
                            if downloadManager.downloadQueue[data.id] != nil {
                                ZStack {
                                    CircularProgressView(progress: downloadManager.currentDownloadingSong?.song.id != data.id ? 0 : downloadManager.currentDownloadingSong?.progress ?? 0 )
                                        .frame(width: 12, height: 12, alignment: .center)
                                    
                                    Image(systemName: "arrow.down.to.line")
                                        .resizable()
                                        .imageScale(.small)
                                        .accentColor(.white)
                                        .frame(width: 8, height: 8, alignment: .center)
                                    
                                }
                            }else{
                                if AppDatabase.shared.getSong(id:  data.id)?.localPath != nil {
                                    Image(systemName: "checkmark.circle")
                                        .renderingMode(.template)
                                        .foregroundColor(.accentColor)
                                        .imageScale(.small)
                                }
                            }
                        }else{
                            
                            if AppDatabase.shared.getSong(id:  data.id)?.localPath != nil {
                                Image(systemName: "checkmark.circle")
                                    .renderingMode(.template)
                                    .foregroundColor(.accentColor)
                                    .imageScale(.small)
                            }
                        }
                        
                        Text(data.artists.map { $0.name }.joined(separator: ", "))
                            .font(.med_15)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(1)
                            .foregroundColor(.textGray)
                    }
                }
                if onMore != nil {
                    Image("v-more-16")
                        .frame(width: 44, height: 44, alignment: .center)
                        .contentShape(Rectangle())
                        .padding(.trailing, 15)
                        .foregroundColor(disabled ? .textGray : .white)
                        .pressWithAnimation {
                            onMore?()
                            impactMed.impactOccurred()
                        }
                } else if moveOn {
                    Image("h-lines-20")
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44, alignment: .center)
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 25, coordinateSpace: .local)
                    .onChanged { value in
                        if abs(value.translation.width) > abs(value.translation.height) {
                            if value.translation.width < 0 && abs(value.translation.width) > minDragThreshold {
                                withAnimation(.spring) {
                                    self.isDragging = true
                                    offset = value.translation.width
                                }
                            }
                        }
                    }
                    .onEnded { value in
                        withAnimation(.bouncy) {
                            isDragging = false
                            if abs(offset) >= UIScreen.main.bounds.width / 7 {
                                offset = .zero
                                drag?()
                               
                                impactMed.impactOccurred()
                            } else {
                                offset = .zero
                            }
                        }
                    }
            )
        }
        .contentShape(Rectangle())
    }
}







struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.5), lineWidth: 2)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: progress)
        }
    }
}

