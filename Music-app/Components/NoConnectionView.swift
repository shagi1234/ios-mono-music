//
//  NoConnectionView.swift
//  Music-app
//
//  Created by Shirin on 19.09.2023.
//

import SwiftUI

struct NoConnectionView: View {
    var refreshClick: ()->()
    
    var body: some View {
        VStack {
            Text(LocalizedStringKey("no_connection"))
                .foregroundColor(.white)
                .font(.bold_16)
                .padding(.bottom, 30)
            
            Button {
                refreshClick()
            } label: {
                Text(LocalizedStringKey("refresh"))
                    .foregroundColor(.white)
                    .font(.med_15)
                    .padding(.horizontal, 20)
                    .frame(height: 50)
                    .background(Color.accentColor)
                    .cornerRadius(10)
            }.pressAnimation()
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct NoConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        NoConnectionView {
            
        }
    }
}
