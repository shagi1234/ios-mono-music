//
//  Font.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 15.08.2023.
//

import SwiftUI

extension UIFont {
    static let bold_22: UIFont = UIFont.systemFont(ofSize: 22, weight: .bold)
    static let bold_16: UIFont = UIFont.systemFont(ofSize: 16, weight: .bold)
    static let bold_14: UIFont = UIFont.systemFont(ofSize: 14, weight: .bold)
    static let med_15: UIFont = UIFont.systemFont(ofSize: 15, weight: .medium)
}

extension Font {
    static let bold_50: Font = .system(size: 50, weight: .bold, design: .default)
    static let bold_35: Font = .system(size: 35, weight: .bold, design: .default)
    static let bold_22: Font = .system(size: 22, weight: .bold, design: .default)
    static let bold_20: Font = .system(size: 20, weight: .bold, design: .default)
    static let bold_16: Font = .system(size: 16, weight: .bold, design: .default)
    static let bold_14: Font = .system(size: 14, weight: .bold, design: .default)
    static let bold_12: Font = .system(size: 12, weight: .bold, design: .default)
    static let bold_10: Font = .system(size: 10, weight: .bold, design: .default)
    
    static let med_15: Font = .system(size: 15, weight: .medium, design: .default)
    static let med_12: Font = .system(size: 12, weight: .medium, design: .default)

    static let reg_15: Font = .system(size: 15, weight: .regular, design: .default)
    static let reg_30: Font = .system(size: 30, weight: .regular, design: .default)
    
}

extension Text {

    func customTextStyleBold(size: CGFloat = 30, color: Color = .white) -> some View {
        self
            .font(.custom("NeueMachina-Ultrabold", size: size))
            .foregroundColor(color)
    }
}
