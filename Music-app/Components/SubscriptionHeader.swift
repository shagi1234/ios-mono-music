//
//  PaymentHeader.swift
//  Music-app
//
//  Created by SURAY on 04.10.2024.
//

import SwiftUI

struct SubscriptionHeader: View {
    @Environment(\.presentationMode) var presentation

    
    var body: some View {
        HStack{
            Button(action: {
                presentation.wrappedValue.dismiss()
            }, label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40, alignment: .center)
            })
            Spacer()
            Text(LocalizedStringKey("choose_plan"))
                .font(.bold_22)
                .foregroundColor(.white)
            
            
            
            Spacer()
            Rectangle()
                .fill(.clear)
                .frame(width: 40, height: 40)
                
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SubscriptionHeader()
        .preferredColorScheme(.dark)
}
