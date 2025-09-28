//
//  OtpView.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 15.08.2023.
//

import SwiftUI

struct OtpView: View {
    private var activeIndicatorColor: Color = .accentColor
    private var inactiveIndicatorColor: Color = .clear
    private let doSomething: (String) -> Void = {_ in }
    private let length: Int = 6
    @Environment(\.presentationMode) var presentation
    @FocusState private var isKeyboardShowing: Bool
    @StateObject var vm = OtpVM()
    @EnvironmentObject var coordinator: Coordinator
    
    var body: some View {
        ZStack{
            Image("blur")
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .ignoresSafeArea()
            
            VStack{
                HStack{
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40, alignment: .center)
                        .onTapGesture {
                            print("tap")
                            presentation.wrappedValue.dismiss()
                            
                        }
                        .padding(.horizontal, 20)
                    Spacer()
                }
                ScrollView {
                    VStack(alignment: .leading) {
                        Spacer()
                            .frame(height: 50)
                        Image("mono-music")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .frame(maxHeight: .infinity, alignment: .top)
                        Spacer()
                            .frame(height: 60)
                        
                        VStack{
                            Text(LocalizedStringKey("write_otp"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.bold_22)
                                .foregroundColor(.white)
                                .padding(.bottom, 10)
                            
                            HStack{
                                Text(LocalizedStringKey("enter_otp_code"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.med_15)
                                    .foregroundColor(.textGray)
                                    .lineLimit(4)
                                    .multilineTextAlignment(.leading)
                                    .padding(.trailing, 40)
                                Spacer()
                            }
                            
                            Spacer()
                                .frame(height: 60)
                            HStack{
                                Text(LocalizedStringKey("code_entry"))
                                    .frame(maxWidth: 235, alignment: .leading)
                                    .font(.bold_16)
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(maxHeight: .infinity, alignment: .top)
                        
                        
                        HStack(spacing: 0){
                            ForEach(0...length-1, id: \.self) { index in
                                OTPTextBox(index)
                            }
                        }.background(content: {
                            TextField("", text: $vm.otpText.limit(6))
                                .keyboardType(.numberPad)
                                .textContentType(.oneTimeCode)
                                .frame(width: 1, height: 1)
                                .opacity(0.001)
                                .blendMode(.screen)
                                .focused($isKeyboardShowing)
                                .onChange(of: vm.otpText) { newValue in
                                    if newValue.count == length {
                                        doSomething(newValue)
                                    }
                                }
                                .onAppear {
                                    DispatchQueue.main.async {
                                        isKeyboardShowing = true
                                    }
                                }
                        })
                        .contentShape(Rectangle())
                        .padding(.bottom, 20)
                        .onTapGesture {
                            isKeyboardShowing = true
                        }
                        
                        if let message = vm.failMessage{
                            Text(LocalizedStringKey(message))
                                .font(.bold_16)
                                .foregroundColor(.redCustom)
                        }
                        
                        if vm.inProgress{
                            ProgressView()
                                .tint(Color.bgBlack)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .frame(height: 48)
                                .background(Color.accentColor)
                                .cornerRadius(4)
                            
                            Spacer()
                                .frame(maxHeight: .infinity)
                        } else {
                            Button{
                                hideKeyboard()
                                vm.verify(otp: vm.otpText)
                            }label: {
                                Text(LocalizedStringKey("confirm"))
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .frame(height: 48)
                                    .background(Color.accentColor)
                                    .cornerRadius(4)
                                    .font(.bold_16)
                                    .foregroundColor(Color.bgBlack)
                            }.pressAnimation()
                            
                            if vm.timeRemaining > 0 {
                                HStack {
                                    let secs = String("0\(vm.timeRemaining)".reversed().prefix(2).reversed())
                                    Text(LocalizedStringKey("resend_after"))
                                        .font(.bold_16)
                                        .foregroundColor(.accentColor)
                                    
                                    Text(" 00:\(secs)")
                                        .font(.bold_16)
                                        .foregroundColor(.accentColor)
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 12)
                            } else {
                                Button {
                                    vm.retry()
                                } label: {
                                    HStack{
                                        Text(LocalizedStringKey("resend"))
                                            .font(.bold_16)
                                            .foregroundColor(.accentColor)
                                        Image("restart")
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.top, 12)
                                }.pressAnimation()
                            }
                            Spacer()
                                .frame(maxHeight: .infinity)
                            
                        }
                        
                    }
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity,
                           //                               minHeight: UIScreen.main.bounds.height - geo.safeAreaInsets.bottom-geo.safeAreaInsets.top - 60,
                           maxHeight: .infinity)
                }
                .onTapGesture { hideKeyboard() }
            }
            .preferredColorScheme(.dark)
            .onChange(of: vm.success) { _ in
                if vm.loggedFirstTime {
                    coordinator.navigateTo(tab: 0, page: .register)
                    vm.otpText = ""
                }else if !vm.loggedFirstTime  && Defaults.subsType == ""{
                    coordinator.navigateTo(tab: 0, page: .subsription)
                }else if !vm.loggedFirstTime && !Defaults.subsHasEnded.description.isEmpty {
                    Defaults.logged = true
                }
            }
            .onAppear{
                isKeyboardShowing = true
                if vm.timer == nil {
                    vm.startTimer()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgBlack)
        .navigationBarBackButtonHidden(true)
        
    }
    
    @ViewBuilder
    func OTPTextBox(_ index: Int) -> some View {
        ZStack{
            if vm.otpText.count > index {
                let startIndex = vm.otpText.startIndex
                let charIndex = vm.otpText.index(startIndex, offsetBy: index)
                let charToString = String(vm.otpText[charIndex])
                Text(charToString)
                    .font(.med_15)
                    .foregroundColor(.white)
            } else {
                Text(" ")
            }
        }
        .frame( height: 60)
        .frame(maxWidth: .infinity)
        .background {
            let status = (isKeyboardShowing && vm.otpText.count == index)
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .stroke(status ? activeIndicatorColor : inactiveIndicatorColor)
                .animation(.easeInOut(duration: 0.2), value: status)
            
            
        }
        .background(Color.bgLightBlack.cornerRadius(5))
        .padding(.trailing, 9)
    }
}

@available(iOS 13.0, *)
extension Binding where Value == String {
    func limit(_ length: Int)->Self {
        if self.wrappedValue.count > length {
            DispatchQueue.main.async {
                self.wrappedValue = String(self.wrappedValue.prefix(length))
            }
        }
        return self
    }
}

@available(iOS 15.0, *)
struct OTPView_Previews: PreviewProvider {
    static var previews: some View {
        OtpView()
            .preferredColorScheme(.dark)
    }
}


