//
//  ContactUs.swift
//  Music-app
//
//  Created by SURAY on 09.08.2024.
//

import SwiftUI

struct ContactUsView: View {
    @Environment(\.presentationMode) var presentation
    @StateObject var vm = SettingVM()
    var body: some View {
        VStack{
            HStack{
                Button(action: {
                    presentation.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40, alignment: .center)
                })
                Spacer()
            }
            .padding(.horizontal, 20)
            GeometryReader{ geometry in
                ScrollView{
                    VStack{
                        Spacer()
                        Group {
                            Text(LocalizedStringKey("contact_us"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.bold_22)
                                .foregroundColor(.white)
                            
                            VStack{
                                MultilineTextField("message", text: $vm.message) {
                                    
                                }
                                .frame(maxHeight: .infinity, alignment: .top)
                            }
                            .frame(height: 100)
                            .foregroundColor(.textGray)
                            .padding(20)
                            .background(Color.bgLightBlack)
                            .cornerRadius(4)
                        }
                        .padding(.bottom, 20)
                        
                        Spacer()
                            
                        Button{
                            vm.contactUs()
                        }label: {
                            if vm.inProgress{
                                ProgressView()
                                    .tint(Color.bgBlack)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .frame(height: 60)
                                    .background(Color.accentColor)
                                    .cornerRadius(4)
                            }else{
                                Text(LocalizedStringKey("continue"))
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .frame(height: 60)
                                    .background(Color.accentColor)
                                    .cornerRadius(4)
                                    .font(.bold_16)
                                    .foregroundColor(Color.bgBlack)
                            }
                        }
                        Spacer()
                            .frame(height: 75)
                    }
                    .frame(width: geometry.size.width)
                    .frame(minHeight: geometry.size.height)
                 
                }
            }
            .padding(.horizontal, 20)
        }
        .navigationBarBackButtonHidden(true)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgBlack)
        .onTapGesture {
            hideKeyboard()
        }
    }
}

#Preview {
    ContactUsView()
}
