//
//  SignUpView.swift
//  Music-app
//
//  Created by SURAY on 26.03.2024.
//

import SwiftUI
import NavigationStackBackport

struct SignUpView: View {
    @EnvironmentObject var coordinator: Coordinator

    var body: some View {
            VStack {
                Image("mono-music")
                    .padding(.top, 30)
                
                Spacer()
                
                HStack{
                    Text(LocalizedStringKey("enjoy_music"))
                        .customTextStyleBold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(width: 300, height: 120)
                    Spacer()
                }
                .padding(.bottom, 40)
                
                Button(action: {
                    coordinator.navigateTo(tab: 0, page: .login)
                }) {
                    Text(LocalizedStringKey("connect_service"))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: 48)
                        .background(Color.accentColor)
                        .cornerRadius(4)
                        .font(.bold_16)
                        .foregroundColor(Color.bgBlack)
                }
                
              Spacer()
                    .frame(maxHeight: 57)
                
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background{
                Image("intro-cover")
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
            }
            .onAppear{
                Defaults.lang =  NSLocale.current.languageCode ?? "tk"
            }
        }
    }


#Preview {
    SignUpView()
}
