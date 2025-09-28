//
//  HomeViewWrapper.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 17.08.2023.
//

import SwiftUI

struct ScrollableHStack <Content: View>: View {
    
    var title: String
    var strongTitle: Bool
    var isAllButton : Bool
    var spacing: CGFloat
    var content: () -> Content
    var onClick : () -> ()
    
    
    init(title: String,
         strongTitle: Bool = true,
         isAllButton : Bool = false,
         spacing: CGFloat,
         click: @escaping () -> (),
         @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.strongTitle = strongTitle
        self.isAllButton = isAllButton
        self.spacing = spacing
        self.content = content
        self.onClick = click
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack{
                Text(LocalizedStringKey(title))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                    .font(strongTitle ? .bold_22 : .reg_15)
                    .foregroundColor(strongTitle ? .white : .textGray)
                    .padding(.bottom, 20)
                
                Spacer()
                if isAllButton{
                    Image(systemName: "chevron.right")
                         .foregroundColor(Color.accentColor)
                         .padding(.trailing, 20)
                         .frame(maxHeight: .infinity, alignment: .top)
                }
            }
            .padding(.horizontal, 20)
            .frame(height: 35)
            .contentShape(Rectangle())
            .pressWithAnimation {
                onClick()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top , spacing: 0) {
                    content()
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
