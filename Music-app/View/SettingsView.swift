//
//  SettingsView.swift
//  Music-app
//
//  Created by Ширин Янгибаева on 17.08.2023.
//

import SwiftUI
import PopupView
import Resolver

struct SettingsView: View {
    @Environment(\.presentationMode) var presentation
    @StateObject var vm = SettingVM()
    @State var showLangs : Bool = false
    @AppStorage(DefaultsKeys.lang.rawValue) var lang = Defaults.lang
    @StateObject var mainvm = Resolver.resolve(MainVM.self)
    @EnvironmentObject var coordinator: Coordinator
    @State var id: Int64 = 0
    @State var showWebView: Bool = false
    @State var showContactUs: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    @State var showPopUp : Bool = false
    let impactMed = UIImpactFeedbackGenerator(style: .medium)
    
    
    var body: some View {
        ZStack{
            Image("blur_payment")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .ignoresSafeArea()
            VStack{
                HStack{
                    Button(action: {
                        presentation.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40, alignment: .center)
                    })
                    .pressAnimation()
                    Spacer()
                }
                .padding(.horizontal, 20)
                
                ScrollView(showsIndicators: false){
                    HStack{
                        VStack{
                            Text(Defaults.fullName)
                                .foregroundColor(.white)
                                .font(.bold_16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(1)
                            HStack{
                                Text(Defaults.subsType)
                                    .foregroundColor(.accentColor)
                                    .font(.bold_12)
                                    .lineLimit(1)
                                Image(systemName: "circle.fill")
                                    .resizable()
                                    .frame(width: 3, height: 3)
                                    .foregroundColor(Color.textGray)
                                Text(Defaults.subsEndDate)
                                    .foregroundColor(.textGray)
                                    .font(.med_12)
                                    .lineLimit(1)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                        .background(.gray.opacity(0.1))
                        .cornerRadius(4)
                    }
                    
                    Text(LocalizedStringKey("main_settings"))
                        .foregroundColor(.white)
                        .font(.bold_16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                        .padding(.top, 20)
                    
                    Text(LocalizedStringKey("add_balance"))
                        .foregroundColor(.textGray)
                        .font(.med_12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                    
                    VStack{
                        BottomSheetBtnView(bgColor: Color.moreBg, type: .myBalance) {
                            coordinator.navigateTo(tab: 0, page: .register)
                        }
                        BottomSheetBtnView(bgColor: Color.moreBg, type: .contactUs) {
                            showContactUs.toggle()
                        }
                        HStack{
                            BottomSheetBtnView(bgColor: Color.moreBg, type: .version) {
                                
                            }
                            Text("1.0")
                                .foregroundColor(.accentColor)
                        }
                     
                            HStack{
                                BottomSheetBtnView(bgColor: Color.moreBg, type: .language) {
                                    showLangs.toggle()
                                }
                                
                               Spacer()
                                    
                                Text(LocalizedStringKey(lang))
                                    .foregroundColor(.accentColor)
                            }
                            .contentShape(Rectangle())
                            .pressWithAnimation {
                                showLangs.toggle()
                            }
                       
                    }
                    .padding(.horizontal)
                    .padding(.vertical)
                    .background(.gray.opacity(0.1))
                    .cornerRadius(4)
                    
                    
                    if !(Defaults.phone == "65000000"){
                        SubscriptionCard(subs: SubscriptionModel.example, selectedId: $vm.selectedId, isInSettings: true, onClick:  {
                            coordinator.navigateTo(tab: 0, page: .subsription)
                        })
                        .padding(.top, 32)
                        .padding(.top, 10)
                  
                
                    
                    Text(LocalizedStringKey("promo_card"))
                        .font(.bold_22)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 20)
                    
                    HStack{
                        TextField("", text: $vm.promoCode, onEditingChanged: { isEditing in
                            vm.isEditing = isEditing
                        }).placeholder(when: !vm.isEditing && vm.promoCode.isEmpty) {
                            Text(LocalizedStringKey("promo"))
                                .font(.med_15)
                                .foregroundColor(.textGray)
                        }.foregroundColor(.white)
                            .keyboardType(.default)
                            .font(.med_15)
                            .padding(.bottom, 2)
                           
                        Button{
                            vm.checkPromoCode()
                        }label: {
                            Text(LocalizedStringKey("continue"))
                                .foregroundColor(.black)
                                .font(.bold_14)
                                .padding(12)
                                .background{
                                    Color.accentColor
                                        .cornerRadius(3)
                                }
                        }
                    }
                    .foregroundColor(.textGray)
                    .padding(12)
                    .background(Color.bgLightBlack)
                    .cornerRadius(4)
                        
                    }
                    Spacer()
                        .frame(height: 75)
                }
                .padding(.horizontal, 20)
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .onChange(of: vm.promoMessage) { newValue in
            showPopUp.toggle()
        }
        .navigationBarBackButtonHidden(true)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgBlack)
        .onAppear{
            vm.getProfile()
            vm.getSubscribtions()
        }
        .sheet(isPresented: $vm.showWebview, content: {
            WebViewWithProgress(webViewModel: WebViewModel(url: vm.registerPayment?.formUrl ?? ""))
      
        })
        .popup(isPresented: $showPopUp) {
            HStack{
              
                Text(LocalizedStringKey(vm.promoMessage))
                    .padding(.leading, 5)
                
                Spacer()
            }
            .zIndex(3)
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(Color.bgLightBlack)
            .cornerRadius(2)
            .padding(.horizontal, 20)
            .padding(.bottom, 50)
            .onAppear{
                impactMed.impactOccurred()
            }
          
        } customize: {
            $0
                .type(.floater())
                .position(.bottom)
                .animation(.spring())
                .closeOnTapOutside(false)
                .isOpaque(false)
                .autohideIn(3)
        }
        .popup(isPresented: $showLangs) {
            VStack(alignment: .leading){
                Text(LocalizedStringKey("choose_lang"))
                    .font(.bold_16)
                    .foregroundStyle(.white)
                text(title: "tk", isLang: true, onClick: {
                    showLangs.toggle()
                    Defaults.lang = "tk"
                })
                text(title: "ru", isLang: true,  onClick: {
                    showLangs.toggle()
                    Defaults.lang = "ru"
                })
                text(title: "en", isLang: true,  onClick: {
                    showLangs.toggle()
                    Defaults.lang = "en"
                })
                
            }
            .padding(.horizontal, 20)
            .frame( height: 235, alignment: .center)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(Color.bgBlack)
            .cornerRadius(8)
            .padding(.horizontal, 38)
        } customize: {
            $0
                .type(.default)
                .position(.center)
                .animation(.spring())
                .closeOnTapOutside(true)
                .backgroundColor(.black.opacity(0.5))
        }
        .popup(isPresented: $showContactUs) {
            VStack(){
                Spacer()
                Group {
                    Text(LocalizedStringKey("contact_us"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.bold_22)
                        .foregroundColor(.white)
                    
                    VStack{
                        MultilineTextField("message", text: $vm.message)
                            .focused($isTextFieldFocused)
                        .frame(maxHeight: .infinity, alignment: .top)
                    }
                    .frame(height: 100)
                    .foregroundColor(.textGray)
                    .padding(20)
                    .background(Color.bgLightBlack)
                    .cornerRadius(4)
                }
                .padding(.bottom, 10)
                
                Spacer()
                    
                Button{
                    vm.contactUs()
                }label: {
                    if vm.contactUsProgress{
                        ProgressView()
                            .tint(Color.bgBlack)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .frame(height: 60)
                            .background(Color.accentColor)
                            .cornerRadius(4)
                    }else{
                        Text(LocalizedStringKey("send"))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .frame(height: 60)
                            .background(Color.accentColor)
                            .cornerRadius(4)
                            .font(.bold_16)
                            .foregroundColor(Color.bgBlack)
                    }
                }.pressAnimation()
            }
            .padding(20)
            .frame( height: 300, alignment: .center)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(Color.bgBlack)
            .cornerRadius(4)
            .padding(.horizontal, 38)
            .onChange(of: vm.contactSuccess) { newValue in
                showContactUs.toggle()
                mainvm.popUpType = .successSent
            }
            .onChange(of: vm.contactError) { newValue in
                showContactUs.toggle()
                mainvm.popUpType = .failMessage
            }
            .onAppear {
                       isTextFieldFocused = true
                   }
        } customize: {
            $0
                .type(.default)
                .position(.center)
                .closeOnTapOutside(true)
                .backgroundColor(.black.opacity(0.5))
        }
    }
}

extension SettingsView{
    @ViewBuilder
    func text(title: String, description: String? = "", isLang: Bool = false, onClick: @escaping () -> ()) -> some View{
        Button{
            onClick()
        }label:{
            HStack{
                VStack(alignment: .leading){
                    Text(LocalizedStringKey(title))
                        .font(.bold_14)
                        .foregroundStyle(.white)
                    if !isLang{
                        Text(description ?? "")
                            .font(.med_12)
                            .foregroundStyle(.white)
                    }
                }
                Spacer()
                if !isLang{
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal, 10)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 4)
                .stroke(.gray.opacity(0.3), lineWidth: 1))
        }.pressAnimation()
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
