import SwiftUI

struct ContactView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var appearAnimation = false
    
    var body: some View {
        ZStack {
            AppBackground(style: .detail)
            
            VStack(spacing: 0) {
                AppHeaderBar(title: "Contacto")
                
                ScrollView {
                    VStack(spacing: 32) {
                        Image(systemName: "envelope.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.dodgerBlue, Color.twitterBlue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color.cobaltBlue.opacity(0.3), radius: 10, x: 0, y: 5)
                            .padding(.top, 40)
                        
                        Text(L10n.contactUs.localized())
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color.cobaltBlue)
                            .padding(.bottom, -8)
                        
                        VStack(spacing: 16) {
                            VStack(spacing: 4) {
                                Text(L10n.generalPastor.localized())
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(Color.primary)
                                
                                Text("Pastor@tabernaculosantana.net")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.secondary)
                            }
                            
                            Button {
                                openEmail()
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "paperplane.fill")
                                        .font(.headline.weight(.semibold))
                                    
                                    Text(L10n.sendMessage.localized())
                                        .font(.headline.weight(.semibold))
                                }
                                .foregroundStyle(Color.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    Capsule()
                                        .fill(Color.twitterBlue)
                                        .shadow(color: Color.twitterBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                                )
                            }
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color.cardBackground)
                                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                        )
                        .padding(.horizontal, 20)
                        
                        Spacer()
                    }
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 20)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appearAnimation = true
            }
        }
    }
    
    private func openEmail() {
        let email = "Pastor@tabernaculosantana.net"
        if let gmailURL = URL(string: "googlegmail://co?to=\(email)"), UIApplication.shared.canOpenURL(gmailURL) {
            openURL(gmailURL)
        } else if let defaultURL = URL(string: "mailto:\(email)") {
            openURL(defaultURL)
        }
    }
}

#Preview {
    ContactView()
}
