//
//  SubsEndView.swift
//  Music-app
//
//  Created by SURAY on 31.10.2024.
//

import SwiftUI

struct SubsEndView: View {
    @EnvironmentObject var coordinator: Coordinator
    var body: some View {
        ZStack{
            Image("blur")
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .ignoresSafeArea()
            VStack{
                Spacer()
                    .frame(maxHeight: 94)
                Image("mono-music")
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
                    .frame(maxHeight: 93)
                VStack{
                    Text(LocalizedStringKey("subscription_ended"))
                        .foregroundColor(.white)
                        .font(.bold_22)
                        .multilineTextAlignment(.center)
                        .frame(maxHeight: .infinity, alignment: .top)
                    
                    Text(LocalizedStringKey("choose_plan_to_continue"))
                        .foregroundColor(.textGray)
                        .font(.med_15)
                        .multilineTextAlignment(.center)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                }
                .frame(width: 291, height: 319)
                
                Spacer()
                    .frame(height: 32)
                Button{
                    coordinator.navigateTo(tab: 0, page: .subsription)
                }label: {
                    Text(LocalizedStringKey("see_plans"))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: 48)
                        .background(Color.accentColor)
                        .cornerRadius(4)
                        .font(.bold_16)
                        .foregroundColor(Color.bgBlack)
                        .padding(.horizontal, 20)
                }
                
                Spacer()
                    .frame(maxHeight: .infinity)
            }
        }
    }
}

#Preview {
    SubsEndView()
        .preferredColorScheme(.dark)
}
