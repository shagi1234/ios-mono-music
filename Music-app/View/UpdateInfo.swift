//
//  UpdateInfo.swift
//  Music-app
//
//  Created by Shahruh on 25.09.2025.
//

import SwiftUI

struct UpdateSheetView: View {
    var appUpdateManager: AppUpdateManager
    
    var body: some View {
        BottomSheetView {
            VStack(spacing: 32) {
                
                HStack(alignment: .top) {
                    
                    ZStack {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 100, height: 100)
                        
                        Text("🚀")
                            .font(.system(size: 40))
                    }
                    
                    
                    Spacer()
                    if !(appUpdateManager.updateInfo?.isForceUpdate ?? false) {
                        Button(action: {
                            appUpdateManager.dismissUpdate()
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .resizable()
                                .font(.title2)
                                .foregroundColor(.gray)
                                .padding(10)
                                .frame(width: 30,height: 30)
                                .background(
                                    Circle()
                                        .fill(Color.black)
                                )
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.top, 20)
                
                VStack(spacing: 16) {
                    Text(LocalizedStringKey("update_title"))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity,alignment: .leading)
                    
                    Text(LocalizedStringKey("update_description"))
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(4)
                        .frame(maxWidth: .infinity,alignment: .leading)
                    
                }
                
                VStack(spacing: 12) {
                    Button(action: {
                        appUpdateManager.openAppStore()
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.body)
                            Text(LocalizedStringKey("update_button"))
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.yellow)
                        )
                    }
                    
                    if !(appUpdateManager.updateInfo?.isForceUpdate ?? false) {
                        Button(action: {
                            appUpdateManager.dismissUpdate()
                            dismiss()
                        }) {
                            Text(LocalizedStringKey("later_button"))
                                .font(.body)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                        }
                    }
                }
                
            }.padding(.horizontal,10)
                .padding(.bottom,10)
                .background(Color.bgLightBlack)
                .interactiveDismissDisabled(appUpdateManager.updateInfo?.isForceUpdate ?? false)
        }
    }
    
    func dismiss() {
        withAnimation(.easeInOut(duration: 0.4)) {
            Tools.shared.presentedBottomsheet = nil
        }
    }
}
