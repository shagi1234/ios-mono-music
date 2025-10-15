import SwiftUI
import Resolver

struct SubsEndView: View {
    @EnvironmentObject var coordinator: Coordinator
    @StateObject var playervm  = Resolver.resolve(PlayerVM.self)
    
    @AppStorage(DefaultsKeys.subsHasEnded.rawValue) var subsHasEnded: Bool = false
    @AppStorage(DefaultsKeys.subsEndDate.rawValue) var subsEndDate: String = ""
    @AppStorage(DefaultsKeys.logged.rawValue) var logged: Bool = false
    
    var body: some View {
        ZStack{
            Image("blur")
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .ignoresSafeArea()
            VStack{
                Spacer()
                    .frame(maxHeight: 94)
                Image("mono-music")
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
                    .frame(maxHeight: 93)
                VStack{
                    Text(LocalizedStringKey("subscription_ended"))
                        .foregroundColor(.white)
                        .font(.bold_22)
                        .multilineTextAlignment(.center)
                        .frame(maxHeight: .infinity, alignment: .top)
                    
                    Text(LocalizedStringKey("choose_plan_to_continue"))
                        .foregroundColor(.textGray)
                        .font(.med_15)
                        .multilineTextAlignment(.center)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                }
                .frame(width: 291, height: 319)
                
                Spacer()
                    .frame(height: 32)
                
                Button{
                    coordinator.navigateTo(tab: 0, page: .subsription)
                }label: {
                    Text(LocalizedStringKey("see_plans"))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: 48)
                        .background(Color.accentColor)
                        .cornerRadius(4)
                        .font(.bold_16)
                        .foregroundColor(Color.bgBlack)
                        .padding(.horizontal, 20)
                }
                
                Button{
                    Defaults.logout()
                    playervm.clearPlayer()
                    playervm.removeObserversFromPlayer()
                    playervm.currentTrack = nil
                }label: {
                    Text(LocalizedStringKey("log_out"))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .frame(height: 48)
                        .background(Color.clear)
                        .cornerRadius(4)
                        .font(.bold_16)
                        .foregroundColor(Color.redCustom)
                        .padding(.horizontal, 20)
                }.pressAnimation()
                
                Spacer()
                    .frame(maxHeight: .infinity)
            }
        }
    }
    }
}

#Preview {
    SubsEndView()
        .preferredColorScheme(.dark)
}
