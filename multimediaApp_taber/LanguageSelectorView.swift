import SwiftUI

struct LanguageSelectorView: View {
    @ObservedObject var localization = LocalizationManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedLanguage: String
    
    init() {
        _selectedLanguage = State(initialValue: LocalizationManager.shared.currentLanguage)
    }
    
    var body: some View {
        ZStack {
            AppBackground(style: .detail)
            
            VStack(spacing: 0) {
                // Header personalizado
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(Color.cobaltBlue)
                        }
                    }
                    
                    Spacer()
                    
                    Text(L10n.language.localized())
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color.cobaltBlue)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                VStack(spacing: 16) {
                    // Español
                    LanguageOption(
                        flag: "🇸🇻",
                        language: "Español",
                        code: "es",
                        isSelected: selectedLanguage == "es"
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedLanguage = "es"
                            localization.changeLanguage(to: "es")
                        }
                    }
                    
                    // English
                    LanguageOption(
                        flag: "🇺🇸",
                        language: "English",
                        code: "en",
                        isSelected: selectedLanguage == "en"
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedLanguage = "en"
                            localization.changeLanguage(to: "en")
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
    }
}

struct LanguageOption: View {
    let flag: String
    let language: String
    let code: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Flag
                Text(flag)
                    .font(.system(size: 40))
                
                // Language name
                Text(language)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.cobaltBlue)
                
                Spacer()
                
                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.dodgerBlue)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? Color.dodgerBlue.opacity(0.1) : Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(
                        isSelected ? Color.dodgerBlue : Color.aliceBlue.opacity(0.2),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(color: Color.cobaltBlue.opacity(isSelected ? 0.15 : 0.05), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LanguageSelectorView()
}
