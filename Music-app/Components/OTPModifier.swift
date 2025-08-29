//
//  OTPModifier.swift
//  Music-app
//
//  Created by SURAY on 26.03.2024.
//

import SwiftUI
import Combine

struct OtpModifer: ViewModifier {

    @Binding var pin : String 
    @StateObject var vm = RegisterVM()
    var textLimt = 1

    func limitText(_ upper : Int) {
        if pin.count > upper {
            self.pin = String(pin.prefix(upper))
        }
    }


    //MARK -> BODY
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .keyboardType(.numberPad)
            .onReceive(Just(pin)) {_ in limitText(textLimt)}
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .background(Color.bgLightBlack.cornerRadius(5))
            .overlay(
                     Group {  
                         if !vm.editing {
                             Text(LocalizedStringKey(pin))
                                 .font(.med_15)
                                 .foregroundColor(.white)
                                 .frame(maxWidth: .infinity, alignment: .center)
                         }
                     }
                 )
//            .background(
//                RoundedRectangle(cornerRadius: 5)
//                    .stroke(Color.accentColor, lineWidth: 2)
//            )
    }
}
