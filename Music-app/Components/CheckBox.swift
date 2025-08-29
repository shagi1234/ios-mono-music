//
//  CheckBox.swift
//  Music-app
//
//  Created by SURAY on 08.08.2024.
//

import SwiftUI

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                    .foregroundColor(configuration.isOn ? .yellow : .white)
                configuration.label
            }
        }
    }
}
