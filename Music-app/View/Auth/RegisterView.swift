//
//  Register.swift
//  Music-app
//
//  Created by SURAY on 27.03.2024.
//

import SwiftUI
import Resolver

struct RegisterView: View {
    @EnvironmentObject var coordinator: Coordinator
    @StateObject var vm = RegisterVM()
    @StateObject var otpvm = OtpVM()
    @StateObject var mainvm = Resolver.resolve(MainVM.self)
    @Environment(\.presentationMode) var presentation
    @State private var isMaleSelected: Bool = true
    @StateObject var playervm  = Resolver.resolve(PlayerVM.self)
    
    var body: some View {
        ZStack{
            if !Defaults.logged{
                Image("blur")
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .ignoresSafeArea()
            }
            
            VStack{
                HStack{
                    Button(action: {
                        presentation.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40, alignment: .center)
                    }).pressAnimation()
                    
                    Spacer()
                }
                GeometryReader{ geo in
                    ScrollView{
                        VStack(alignment: .leading){
                            if Defaults.logged{
                                Text(LocalizedStringKey("my_balance"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.bold_16)
                                    .foregroundColor(.white)
                                    .lineLimit(0)
                                    .multilineTextAlignment(.leading)
                                    .padding(.top, 20)
                                
                            }else{
                                Image("mono-music")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.top, 94)
                                Text(LocalizedStringKey("finish_registration"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.bold_22)
                                    .foregroundColor(.white)
                                    .lineLimit(0)
                                    .multilineTextAlignment(.leading)
                                    .padding(.bottom, 10)
                                    .padding(.top, 20)
                                
                                Text(LocalizedStringKey("add_additional_info"))
                                    .frame(maxWidth: 250, alignment: .leading)
                                    .font(.med_15)
                                    .foregroundColor(.textGray)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                            }
                            
                            Group {
                                if Defaults.logged == false{
                                    Text(LocalizedStringKey("bithday"))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .font(.bold_16)
                                        .foregroundColor(.white)
                                        .lineLimit(0)
                                        .multilineTextAlignment(.leading)
                                        .padding(.top, 40)
                                    HStack(alignment: .center){
                                        TextField(LocalizedStringKey("day"), text: $vm.day, onEditingChanged: { isEditing in
                                            vm.editing = isEditing
                                        })
                                        .modifier(OtpModifer(pin: $vm.day, textLimt: 2))
                                        .placeholder(when: !vm.editing) {
                                            Text(LocalizedStringKey("day"))
                                                .font(.med_15)
                                                .foregroundColor(.textGray)
                                                .frame(maxWidth: .infinity, alignment: .center)
                                        }
                                        
                                        TextField(LocalizedStringKey("month"), text: $vm.month, onEditingChanged: { isEditing in
                                            vm.editing = isEditing
                                        })
                                        .modifier(OtpModifer(pin: $vm.month, textLimt: 2))
                                        
                                        TextField(LocalizedStringKey("year"), text: $vm.year, onEditingChanged: { isEditing in
                                            vm.editing = isEditing
                                        })
                                        .modifier(OtpModifer(pin: $vm.year, textLimt: 4))
                                    }
                                    .padding(.top, 8)
                                    
                                    TextField("", text: $vm.fullname, onEditingChanged: { isEditing in
                                        vm.editingFullName = isEditing
                                    }).placeholder(when: vm.fullname.isEmpty) {
                                        Text(LocalizedStringKey("fullname"))
                                            .font(.med_15)
                                            .foregroundColor(.textGray)
                                    }.foregroundColor(.white)
                                        .keyboardType(.default)
                                        .font(.med_15)
                                        .padding(.bottom, 2)
                                        .foregroundColor(.textGray)
                                        .padding(20)
                                        .background(Color.bgLightBlack)
                                        .cornerRadius(4)
                                }
                                
                                if Defaults.logged {
                                    Text(LocalizedStringKey("username"))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .font(.bold_10)
                                        .foregroundColor(.white)
                                        .lineLimit(0)
                                        .multilineTextAlignment(.leading)
                                        .padding(.top, 40)
                                    TextField("", text: $vm.fullname, onEditingChanged: { isEditing in
                                        vm.editingFullName = isEditing
                                    }).placeholder(when: vm.fullname.isEmpty) {
                                        Text(LocalizedStringKey("fullname"))
                                            .font(.med_15)
                                            .foregroundColor(.textGray)
                                    }.foregroundColor(.white)
                                        .keyboardType(.default)
                                        .font(.med_15)
                                        .padding(.bottom, 2)
                                        .foregroundColor(.textGray)
                                        .padding( 20)
                                        .background(Color.bgLightBlack)
                                        .padding(.bottom, 16)
                                        .cornerRadius(4)
                                    
                                    Group {
                                        Text(LocalizedStringKey("phone_num"))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .font(.bold_10)
                                            .foregroundColor(.white)
                                            .lineLimit(0)
                                            .multilineTextAlignment(.leading)
                                        
                                        HStack{
                                            Text("+993")
                                                .foregroundColor(.white)
                                                .font(.med_15)
                                            TextField("", text: $vm.phoneNum, onEditingChanged: { isEditing in
                                                vm.editing = isEditing
                                            }).placeholder(when: !vm.editing) {
                                                Text("")
                                                    .font(.med_15)
                                                    .foregroundColor(.textGray)
                                            }.foregroundColor(.white)
                                                .keyboardType(.phonePad)
                                                .font(.med_15)
                                                .padding(.bottom, 2)
                                            
                                        }
                                        .foregroundColor(.textGray)
                                        .padding( 20)
                                        .background(Color.bgLightBlack)
                                        .padding(.bottom, 16)
                                        .cornerRadius(4)
                                        
                                        Text(LocalizedStringKey("bithday"))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .font(.bold_10)
                                            .foregroundColor(.white)
                                            .lineLimit(0)
                                            .multilineTextAlignment(.leading)
                                        
                                        HStack(alignment: .center){
                                            TextField(LocalizedStringKey("day"), text: $vm.day, onEditingChanged: { isEditing in
                                                vm.editing = isEditing
                                            })
                                            .modifier(OtpModifer(pin: $vm.day, textLimt: 2))
                                            .placeholder(when: !vm.editing) {
                                                Text(LocalizedStringKey("day"))
                                                    .font(.med_15)
                                                    .foregroundColor(.textGray)
                                                    .frame(maxWidth: .infinity, alignment: .center)
                                            }
                                            TextField(LocalizedStringKey("month"), text: $vm.month, onEditingChanged: { isEditing in
                                                vm.editing = isEditing
                                            })
                                            .modifier(OtpModifer(pin: $vm.month, textLimt: 2))
                                            
                                            
                                            TextField(LocalizedStringKey("year"), text: $vm.year, onEditingChanged: { isEditing in
                                                vm.editing = isEditing
                                            })
                                            .modifier(OtpModifer(pin: $vm.year, textLimt: 4))
                                        }
                                    }
                                    
                                }
                                Text(LocalizedStringKey("gender"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.bold_10)
                                    .foregroundColor(.white)
                                    .padding(.top, 16)
                                HStack{
                                    Toggle(isOn: Binding<Bool>(
                                        get: { vm.gender == .male },
                                        set: { if $0 { vm.gender = .male } }
                                    )) {
                                        Text(LocalizedStringKey(Gender.male.rawValue))
                                            .foregroundColor(.white)
                                            .font(.med_15)
                                    }
                                    .toggleStyle(CheckboxToggleStyle())
                                    
                                    Toggle(isOn: Binding<Bool>(
                                        get: { vm.gender == .female },
                                        set: { if $0 { vm.gender = .female } }
                                    )) {
                                        Text(LocalizedStringKey(Gender.female.rawValue))
                                            .foregroundColor(.white)
                                            .font(.med_15)
                                    }
                                    .toggleStyle(CheckboxToggleStyle())
                                }
                                .padding(.top, 5)
                                Spacer()
                                Button{
                                    vm.updateProfile()
                                }label: {
                                    if  vm.inProgress{
                                        ProgressView()
                                            .tint(Color.bgBlack)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .frame(height: 48)
                                            .background(Color.accentColor)
                                            .cornerRadius(4)
                                    }else{
                                        Text(LocalizedStringKey("continue"))
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .frame(height: 48)
                                            .background(Color.accentColor)
                                            .cornerRadius(4)
                                            .font(.bold_16)
                                            .foregroundColor(Color.bgBlack)
                                    }
                                }.pressAnimation()
                                .padding(.vertical, 20)
                                
                                if Defaults.logged {
                                    Button{
                                        Defaults.logout()
                                        playervm.clearPlayer()
                                        playervm.removeObserversFromPlayer()
                                        playervm.currentTrack = nil
                                    }label:{
                                        HStack{
                                            Image("log-out")
                                            Text(LocalizedStringKey("log_out"))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .font(.bold_16)
                                                .foregroundColor(.white)
                                                .multilineTextAlignment(.leading)
                                        }
                                    }.pressAnimation()
                                }
                                
                                Spacer()
                                    .frame( height: 75)
                            }
                        }
                        .frame(minHeight: geo.size.height)
                        .onTapGesture { hideKeyboard() }
                        .onAppear{
                            vm.editing = true
                            vm.fullname = Defaults.fullName
                            vm.phoneNum = Defaults.phone
                            if Defaults.logged && !Defaults.birthDay.isEmpty{
                                vm.separateDate()
                            }
                        }
                        .padding(.horizontal, 20)
                        .navigationBarBackButtonHidden(true)
                        .onChange(of: vm.successfullyUpdated) { newValue in
                            if Defaults.logged{
                                coordinator.navigateBack(tab: 0)
                            }else{
                                if Defaults.subsType.isEmpty{
                                    coordinator.navigateTo(tab: 0, page: .subsription)
                                }else{
                                    Defaults.logged = true;
                                }
                            }
                            vm.separateDate()
                            hideKeyboard()
                        }
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                }
            }
        }
        .background(Color.bgBlack)
    }
}



#Preview {
    RegisterView()
}
