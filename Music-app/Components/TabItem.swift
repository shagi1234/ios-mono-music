//
//  TabItem.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 18.08.2023.
//

import SwiftUI

struct TabItem: View {
    
    var data: TabItemModel
    @Binding var selectedInd: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Image(data.tag == selectedInd ? data.selectedImage : data.image)
                .renderingMode(.template)
                .foregroundColor(data.tag == selectedInd ? .accentColor : .white)
                .frame(minWidth: 24, minHeight: 24)

            Text(LocalizedStringKey(data.title))
                .font(.med_12)
                .foregroundColor(data.tag == selectedInd ? .accentColor : .white)
                .lineLimit(1)
        }.frame(minWidth: 70, maxWidth: .infinity, minHeight: 60)
            .pressWithAnimation {
                selectedInd = data.tag
            }
    }
}

struct TabItem_Previews: PreviewProvider {
    @State static var ind = 1
    
    static var previews: some View {
        TabItem(data: .home, selectedInd: $ind)
            .preferredColorScheme(.dark)
    }
}
