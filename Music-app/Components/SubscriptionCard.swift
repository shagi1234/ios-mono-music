//
//  PaymentCard.swift
//  Music-app
//
//  Created by SURAY on 04.10.2024.
//

import SwiftUI

struct SubscriptionCard: View {
    var subs: SubscriptionModel
    @Binding var selectedId: Int64?
    var isInSettings: Bool = false
    var onClick: ()->()
    var body: some View {
        HStack{
            if !isInSettings{
                Image(systemName: selectedId == subs.id ? "checkmark.circle" : "circle")
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.top, 20)
                    .padding(.horizontal, 12)
                    .foregroundColor(subs.price == 0 ? .black : selectedId == subs.id ? .accentColor : .white)
                
            }
            
            
            VStack{
                VStack{
                    if isInSettings{
                        Text(LocalizedStringKey("payment"))
                            .font(.bold_22)
                            .frame(maxWidth: .infinity, alignment: .leading )
                            .foregroundColor(subs.price == 0 ? .black : .white)
                            .padding(.horizontal, 12)
                        
                        Text(LocalizedStringKey("payment_options"))
                            .frame(maxWidth: .infinity, alignment: .leading )
                            .font(.reg_15)
                            .foregroundColor(subs.price == 0 ? .black : .textGray)
                            .padding(.horizontal, 12)
                    }else{
                        Text(subs.name)
                            .font(.bold_22)
                            .frame(maxWidth: .infinity, alignment: .leading )
                            .foregroundColor(subs.price == 0 ? .black : .white)
                        Text(String(format: NSLocalizedString("days", comment: ""), subs.days ?? 0))
                            .frame(maxWidth: .infinity, alignment: .leading )
                            .foregroundColor(subs.price == 0 ? .black : .textGray)
                        
                        if subs.price == 0{
                            Spacer()
                        }
                        if subs.price ?? 0 > 0{
                            Text(String(format: NSLocalizedString("manat", comment: ""), subs.price ?? 0))
                                .font(.bold_20)
                                .frame(maxWidth: .infinity, alignment: .leading )
                                .foregroundColor( .accentColor)
                                .padding(.top, 20)
                                .onTapGesture {
                                    print(subs.id)
                                }
                        }
                    }
                    
                }
                .frame(height: subs.price ?? 0 > 0 ? 82 : 66)
                .frame(maxWidth: .infinity, alignment: .leading )
                .frame(maxHeight: .infinity, alignment: .top )
                .padding(.top, 20)
            }
            
            if subs.price == 0 && !isInSettings{
                Image("gift")
                    .frame(maxHeight: .infinity, alignment: .bottomTrailing )
            }
            
            if isInSettings{
                Image(systemName: "chevron.right")
                    .foregroundColor(.black)
                    .padding(.trailing, 12)
            }
            
            if let disc = subs.discountAmount, subs.price ?? 0 > 0 && (subs.discount != false){
                Color.accentColor
                    .cornerRadius(3)
                    .frame(width: 60, height: 22)
                    .padding(.horizontal, 12)
                    .padding(.top, 20)
                
                    .overlay{
                        Text("-\(disc)%")
                            .foregroundColor( .black)
                            .padding(.top, 20)
                    }
                    .frame(maxHeight: .infinity, alignment: .top )
                
            }
        }
        .frame(height: subs.price ?? 0 > 0 ? 122 : 106)
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke( selectedId == subs.id || subs.price == 0 || isInSettings ? Color.accentColor : .clear, lineWidth: 1)
            
        )
        .onTapGesture {
            onClick()
        }
        .background{
            if subs.price == 0{
                Color.accentColor
                    .cornerRadius(8)
            }else{
                Color.gray.opacity(0.1)
                    .cornerRadius(8)
            }
            
        }
    }
}


