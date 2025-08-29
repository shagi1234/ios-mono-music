//
//  MiniPlayerText.swift
//  Music-app
//
//  Created by SURAY on 26.01.2025.
//

import SwiftUI

struct MiniPlayerText: View {
    let name: String
    let artistName: String
    var body: some View {
        HStack {
            Spacer()
                .frame(width: 52, height: 47)
            
            VStack(spacing: 6) {
                MarqueeText(
                    text: name,
                    font: .bold_16,
                    leftFade: 1,
                    rightFade: 1,
                    startDelay: 0,
                    alignment: .leading
                )
                .foregroundColor(.white)
                
                MarqueeText(
                    text: artistName,
                    font: .med_15,
                    leftFade: 1,
                    rightFade: 1,
                    startDelay: 0,
                    alignment: .leading
                )
                .foregroundColor(.white)
            }
        }
    }
}


