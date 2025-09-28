//
//  PaymentView.swift
//  Music-app
//
//  Created by SURAY on 04.10.2024.
//

import SwiftUI
import PopupView
import Resolver

struct SubscriptionView: View {
    @StateObject var vm  = Resolver.resolve(SettingVM.self)
    @StateObject var signUpVM = SignUpVM()
    @State var showWebView: Bool = false
    @State var showPopUp : Bool = false
    let impactMed = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        ZStack {
            Image("blur_payment")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .ignoresSafeArea()
            
            VStack{
                    SubscriptionHeader()
                    .frame(height: 38)
                    .frame(maxWidth: .infinity, alignment: .top)
                if !vm.inProgressSubscriptions {
                    ScrollView(showsIndicators: false){
                        ForEach(vm.subsciptions.enumeratedArray(), id: \.offset){ ind, i in
                            SubscriptionCard(subs: i, selectedId: $vm.selectedId, onClick: {
                                if i.price == 0{
                                    signUpVM.subscribetoFreePlan()
                                }else{
                                    vm.showPopup.toggle()
                                }
                                vm.selectedId = i.id
                            })
                        }
                        
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
                            }.pressAnimation()
                        }
                        .foregroundColor(.textGray)
                        .padding(12)
                        .background(Color.bgLightBlack)
                        .cornerRadius(4)
                        Spacer()
                            .frame(height: 70)
                    }
                    .gesture(
                        DragGesture(minimumDistance: 10)
                            .onChanged { value in
                                if value.translation.height > 0 {
                                    hideKeyboard()
                                    print("Dragged to top")
                                }
                            }
                    )
                } else {
                    AppLoadingView()
                }
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
          
        }
        .background(Color.bgBlack)
        .navigationBarBackButtonHidden()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onTapGesture {
            hideKeyboard()
        }
        .onChange(of: vm.promoMessage) { newValue in
            showPopUp.toggle()
        }
        .onAppear{
            vm.getSubscribtions()
            vm.getPaymentMethods()
        }
        .sheet(isPresented: $vm.showWebview, content: {
            WebViewWithProgress(webViewModel: WebViewModel(url: vm.registerPayment?.formUrl ?? ""))
                .onDisappear{
                    vm.getProfile()
                    if !Defaults.subsType.isEmpty{
                        Defaults.subsHasEnded = false
                    }
                }
        })
        .popup(isPresented: $vm.showPopup) {
            VStack(alignment: .leading){
                Text(LocalizedStringKey("choose_card"))
                    .font(.bold_16)
                    .foregroundStyle(.white)
                
                Spacer()
                Text(LocalizedStringKey("bank_pop_up"))
                    .font(.med_15)
                    .foregroundColor(.textGray)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .padding(.bottom, 20)
                
                ForEach(vm.payMeth.enumeratedArray(), id: \.offset){ ind, i in
                    text(title: i.title, description: i.description, onClick: {
                        vm.registerPayment(subscriptionId: vm.selectedId ?? 0, paymentType: i.type)
                        vm.showPopup = false
                    })
                }
            }
            .padding(20)
            .frame( height: 394, alignment: .center)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(Color.bgBlack)
            .cornerRadius(4)
            .padding(.horizontal, 38)
        } customize: {
            $0
                .type(.default)
                .position(.center)
                .animation(.spring())
                .closeOnTapOutside(true)
                .backgroundColor(.black.opacity(0.5))
        }
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
            .padding(.bottom, 20)
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
    }
}


extension SubscriptionView{
    @ViewBuilder
    func text(title: String, description: String , isLang: Bool = false, onClick: @escaping () -> ()) -> some View{
        Button{
            onClick()
        }label:{
            HStack{
                VStack(alignment: .leading){
                    Text(LocalizedStringKey(title))
                        .font(.bold_16)
                        .foregroundStyle(.white)
                    if !isLang{
                        Text(description)
                            .font(.med_15)
                            .foregroundColor(.textGray)
                    }
                }
                Spacer()
                if !isLang{
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 82)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 4)
                .stroke(Color.bgLightBlack, lineWidth: 1))
        }.pressAnimation()
    }
}

#Preview {
    SubscriptionView()
        .preferredColorScheme(.dark)
}
