//
//  SearchbarBtn.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 17.08.2023.
//

import SwiftUI

import SwiftUI

struct SearchBar: View {
    @State var searchKey = ""
    @FocusState var focused: Bool
    @State private var debounceWorkItem: DispatchWorkItem?
    
    var isDisabled = false
    var onValueChange: ((String) -> Void)?
    var onSubmit: ((String) -> Void)?
    
    var body: some View {
        HStack {
            ZStack(alignment: .leading) {
                if searchKey.isEmpty {
                    Text(LocalizedStringKey("search"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.textGray)
                        .font(.med_15)
                }
                
                TextField("", text: $searchKey, onCommit: {
                    onSubmit?(searchKey)
                })
                .font(.med_15)
                .foregroundColor(.white)
                .disabled(isDisabled)
                .frame(height: 60)
                .onChange(of: searchKey) { newValue in
                    debounceRequest(newValue)
                }
                .focused($focused)
            }
            
            if searchKey.isEmpty {
                Image("search")
                    .renderingMode(.template)
                    .foregroundColor(.textGray)
            } else {
                Button {
                    searchKey = ""
                    onValueChange?("")
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.textGray)
                        .frame(width: 40, height: 40)
                }.pressAnimation()
            }
        }
        .padding(.horizontal, 16)
        .background(Color.bgLightBlack)
        .contentShape(Rectangle())
        .cornerRadius(5)
        .onTapGesture { focused.toggle() }
        .onAppear {
            if isDisabled || !searchKey.isEmpty { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.focused = true
            }
        }
        .onDisappear {
            focused = false
        }
        .disabled(isDisabled)
    }
   
    private func debounceRequest(_ value: String) {
        debounceWorkItem?.cancel()
        
        let workItem = DispatchWorkItem {
            onValueChange?(value)
        }
        
        debounceWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
    }
}

struct SearchbarBtn_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar()
    }
}
