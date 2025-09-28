//
//  PromoButtons.swift
//  Music-app
//
//  Created by SURAY on 19.04.2024.
//

import SwiftUI

struct PromoButtons: View{
    var subsription : SubscriptionModel
    var onClick: () -> ()
    var body: some View{
        HStack {
            Image("payment-dots")
                .resizable()
                .renderingMode(.template)
                .frame(width: 24, height: 24, alignment: .center)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 1){
                Text(subsription.name)
                    .font(.bold_16)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack{
                    Text("\(subsription.price ?? 0)")
                        .font(.bold_12)
                        .foregroundColor(.accentColor)
                        .multilineTextAlignment(.leading)
                    
                }
            }
            Image(systemName: "chevron.right")
                .frame(width: 24, height: 24, alignment: .center)
                .foregroundColor(.white)
        }.frame(height: 37)
            .listRowBackground(Color.bgBlack)
            .contentShape(Rectangle())
            .pressWithAnimation {
                onClick()
            }
    }
}


