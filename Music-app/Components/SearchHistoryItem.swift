//
//  SearchHistoryItem.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 17.08.2023.
//

import SwiftUI

struct SearchHistoryItem: View {
    var data: String
    var onSelect: ()->()
    
    var body: some View {
        HStack {
            Text(data)
                .frame(maxWidth: .infinity, alignment: .center)
                .font(.bold_16)
                .foregroundColor(.white)
                .lineLimit(0)
                .multilineTextAlignment(.leading)
                .padding(.horizontal)
                .padding(.vertical, 5)
                .background(Color.bgLightBlack)
                .cornerRadius(30)
                .onTapGesture {
                    onSelect()
                }
//            
//            Image(systemName: "xmark")
//                .foregroundColor(.white)
//                .frame(width: 50, height: 30, alignment: .center)
//                .contentShape(Rectangle())
//                .onTapGesture {
//                    onDelete()
//                }
        }
    }
}

struct SearchHistoryItem_Previews: PreviewProvider {
    static var previews: some View {
        SearchHistoryItem(data: "qwerty", onSelect: { }).preferredColorScheme(.dark)
    }
}
