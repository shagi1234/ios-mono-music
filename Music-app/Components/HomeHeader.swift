//
//  HomeHeader.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 17.08.2023.
//

import SwiftUI
import Resolver

struct HomeHeader: View {
    @EnvironmentObject var coordinator: Coordinator
    @StateObject var mainVm = Resolver.resolve(MainVM.self)
    var body: some View {
        HStack {
        Image("new_logo")
                
            Spacer()
            Button {
                mainVm.selectedTab = 1
            } label: {
                Image("search-tabbar")
                    .renderingMode(.template)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40, alignment: .center)
            }
            
            Button {
                coordinator.navigateTo(tab: 0, page: .settings)
            } label: {
                Image("gear")
                    .renderingMode(.template)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40, alignment: .center)
            }
        }.padding(.horizontal, 20)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(Color.bgBlack)
    }
}

struct HomeHeader_Previews: PreviewProvider {
    static var previews: some View {
        HomeHeader()
            .preferredColorScheme(.dark)
    }
}
