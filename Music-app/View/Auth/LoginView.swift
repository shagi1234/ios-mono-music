//
//  ContentView.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 15.08.2023.
//

import SwiftUI
import PopupView

struct LoginView: View {
    @EnvironmentObject var coordinator: Coordinator
    @StateObject var vm = LoginVM()
    @State var showingPopup = false
    @State var numError = false
    
    var body: some View {
        ZStack{
            Image("blur")
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .ignoresSafeArea()
            VStack(alignment: .leading){
                Spacer()
                  .frame(maxHeight: 94)
                Image("mono-music")
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
                  .frame(maxHeight: 60)
                Text(LocalizedStringKey("welcome"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.bold_22)
                    .foregroundColor(.white)
                    .lineLimit(0)
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, 10)
             
                Text(LocalizedStringKey("enter_phone_num"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.med_15)
                    .foregroundColor(.textGray)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .padding(.trailing, 100)
                  Spacer()
                    .frame(maxHeight: 60)
                Group {
                    Text(LocalizedStringKey("phone_num"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.bold_16)
                        .foregroundColor(.white)
                        .lineLimit(0)
                        .multilineTextAlignment(.leading)
                    
                    HStack{
                        if vm.editing{
                            Text("+993")
                                .foregroundColor(.white)
                                .font(.med_15)
                        }
                        TextField("", text: $vm.phone, onEditingChanged: { isEditing in
                            vm.editing = isEditing
                        }).placeholder(when: !vm.editing) {
                            Text(LocalizedStringKey("phone"))
                                .font(.med_15)
                                .foregroundColor(.textGray)
                        }.foregroundColor(.white)
                            .keyboardType(.phonePad)
                            .font(.med_15)
                            .padding(.bottom, 2)
                        Image("phone")
                    }
                    .foregroundColor(.textGray)
                    .padding(20)
                    .background(Color.bgLightBlack)
                    .cornerRadius(4)
                    
                    if numError || vm.fail {
                        Text("Invalid phone number")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.med_15)
                            .foregroundColor(.red)
                            .padding(.top, 3)
                    }
                }
                Spacer()
                  .frame(maxHeight: 20)
                Button{
                    if vm.phone.count == 8{
                        vm.sendOtp()
                    }else{
                        numError = true
                    }
                } label: {
                    if  vm.inProgress{
                        ProgressView()
                            .tint(Color.bgBlack)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .frame(height: 48)
                            .background(Color.accentColor)
                            .cornerRadius(4)
                    }else{
                        Text(LocalizedStringKey("get_otp"))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .frame(height: 48)
                            .background(Color.accentColor)
                            .cornerRadius(4)
                            .font(.bold_16)
                            .foregroundColor(Color.bgBlack)
                    }
                    
                }.pressAnimation()
                
                Spacer()
                    .frame(maxHeight: .infinity)
                
            }
            .onAppear{
                vm.editing = true
                
            }
            .padding(.horizontal, 20)
            .onChange(of: vm.success) { newValue in
                coordinator.navigateTo(tab: 0, page: .otp)
                vm.phone = ""
                hideKeyboard()
            }
            .onChange(of: vm.phone) { newValue in
                numError = false
            }
            .onTapGesture {
                vm.phone = ""
                hideKeyboard()
            }
        }
        .preferredColorScheme(.dark)
        .navigationBarBackButtonHidden(true)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgBlack)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
