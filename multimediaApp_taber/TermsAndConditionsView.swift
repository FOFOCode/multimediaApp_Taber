import SwiftUI

struct TermsAndConditionsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var appearAnimation = false
    
    var body: some View {
        ZStack {
            AppBackground(style: .detail)
            
            VStack(spacing: 0) {
                // Custom Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text(L10n.goBack.localized())
                                .font(.subheadline.weight(.medium))
                        }
                        .foregroundStyle(Color.cobaltBlue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.aliceBlue)
                                .shadow(color: Color.cobaltBlue.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color.aliceBlue.opacity(0.9))
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text(L10n.termsTitle.localized())
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.cobaltBlue)
                            .padding(.bottom, 8)
                        
                        Group {
                            Text(L10n.termsAcceptanceTitle.localized())
                                .font(.headline)
                                .foregroundStyle(Color.twitterBlue)
                            Text(L10n.termsAcceptanceText.localized())
                                .font(.body)
                                .foregroundStyle(Color.primary)
                            
                            Text(L10n.termsLicenseTitle.localized())
                                .font(.headline)
                                .foregroundStyle(Color.twitterBlue)
                            Text(L10n.termsLicenseText.localized())
                                .font(.body)
                                .foregroundStyle(Color.primary)
                            
                            Text(L10n.termsDisclaimerTitle.localized())
                                .font(.headline)
                                .foregroundStyle(Color.twitterBlue)
                            Text(L10n.termsDisclaimerText.localized())
                                .font(.body)
                                .foregroundStyle(Color.primary)
                            
                            Text(L10n.termsLimitationsTitle.localized())
                                .font(.headline)
                                .foregroundStyle(Color.twitterBlue)
                            Text(L10n.termsLimitationsText.localized())
                                .font(.body)
                                .foregroundStyle(Color.primary)
                        }
                        
                        Group {
                            Text(L10n.termsPrivacyTitle.localized())
                                .font(.headline)
                                .foregroundStyle(Color.twitterBlue)
                            Text(L10n.termsPrivacyText.localized())
                                .font(.body)
                                .foregroundStyle(Color.primary)
                            
                            Text(L10n.termsModificationsTitle.localized())
                                .font(.headline)
                                .foregroundStyle(Color.twitterBlue)
                            Text(L10n.termsModificationsText.localized())
                                .font(.body)
                                .foregroundStyle(Color.primary)
                        }
                        
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.cardBackground)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    )
                    .padding()
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                appearAnimation = true
            }
        }
    }
}

#Preview {
    TermsAndConditionsView()
}
