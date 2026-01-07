import SwiftUI

struct HomeView: View {
    @StateObject private var localization = LocalizationManager.shared
    @State private var appearAnimation = false
    @State private var cardAppear = [false, false, false]
    @State private var showLanguageSelector = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground(style: .home)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Botón de idioma en la esquina superior derecha
                        HStack {
                            Spacer()
                            Button {
                                showLanguageSelector = true
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "globe")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text(localization.currentLanguage.uppercased())
                                        .font(.caption.weight(.bold))
                                }
                                .foregroundStyle(Color.aliceBlue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(.ultraThinMaterial)
                                        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        // Header con saludo dinámico
                        VStack(spacing: 12) {
                            Text(greetingText)
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(Color.aliceBlue.opacity(0.9))
                            // Icono decorativo
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "waveform.circle.fill")
                                    .font(.system(size: 44))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color.aliceBlue, Color.icyBlue],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .symbolEffect(.pulse, options: .repeating)
                            }
                            .shadow(color: Color.cobaltBlue.opacity(0.3), radius: 15, x: 0, y: 8)
                            .padding(.bottom, 4)
                            
                            VStack(spacing: 6) {
                                Text(greetingText)
                                    .font(.title3.weight(.medium))
                                    .foregroundStyle(Color.aliceBlue.opacity(0.9))
                                
                                Text(L10n.appName.localized())
                                    .font(.system(size: 38, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.aliceBlue)
                            }
                            
                            Text(L10n.selectContent.localized())
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color.aliceBlue.opacity(0.75))
                                .padding(.top, 4)
                        }
                        .multilineTextAlignment(.center)
                        .shadow(color: Color.cobaltBlue.opacity(0.25), radius: 10, x: 0, y: 6)
                        .padding(.top, 30)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 20)
                        
                        // Cards de contenido
                        VStack(spacing: 20) {
                            NavigationLink(destination: RadioView()) {
                                EnhancedActionCard(
                                    icon: "dot.radiowaves.left.and.right",
                                    title: L10n.radioTitle.localized(),
                                    subtitle: L10n.radioSubtitle.localized(),
                                    description: L10n.radioDescription.localized(),
                                    gradient: [Color.dodgerBlue, Color.brilliantAzure, Color.twitterBlue],
                                    accentIcon: "antenna.radiowaves.left.and.right"
                                )
                            }
                            .opacity(cardAppear[0] ? 1 : 0)
                            .offset(y: cardAppear[0] ? 0 : 30)
                            
                            NavigationLink(destination: TVView()) {
                                EnhancedActionCard(
                                    icon: "tv.fill",
                                    title: L10n.tvTitle.localized(),
                                    subtitle: L10n.tvSubtitle.localized(),
                                    description: L10n.tvDescription.localized(),
                                    gradient: [Color.twitterBlue, Color.oceanDeep, Color.cobaltBlue],
                                    accentIcon: "play.tv.fill"
                                )
                            }
                            .opacity(cardAppear[1] ? 1 : 0)
                            .offset(y: cardAppear[1] ? 0 : 30)
                            
                            NavigationLink(destination: InfoView()) {
                                EnhancedActionCard(
                                    icon: "info.circle.fill",
                                    title: L10n.infoTitle.localized(),
                                    subtitle: L10n.infoSubtitle.localized(),
                                    description: L10n.infoDescription.localized(),
                                    gradient: [Color.brilliantAzure, Color.coolSky2, Color.skyBlue],
                                    accentIcon: "calendar.badge.clock"
                                )
                            }
                            .opacity(cardAppear[2] ? 1 : 0)
                            .offset(y: cardAppear[2] ? 0 : 30)
                        }
                        .padding(.top, 10)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .sheet(isPresented: $showLanguageSelector) {
            LanguageSelectorView()
        }
        .onAppear {
            NotificationCenter.default.post(name: .stopAllMedia, object: nil)
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appearAnimation = true
            }
            
            for index in 0..<3 {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.2 + Double(index) * 0.15)) {
                    cardAppear[index] = true
                }
            }
        }
    }
    
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12: return L10n.goodMorning.localized()
        case 12..<19: return L10n.goodAfternoon.localized()
        default: return L10n.goodEvening.localized()
        }
    }
}

// Card mejorada con más detalles visuales
struct EnhancedActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let description: String
    let gradient: [Color]
    let accentIcon: String
    
    var body: some View {
        HStack(spacing: 0) {
            // Lado izquierdo con icono grande
            VStack {
                ZStack {
                    Circle()
                        .fill(Color.aliceBlue.opacity(0.2))
                        .frame(width: 70, height: 70)
                    
                    Circle()
                        .fill(Color.aliceBlue.opacity(0.15))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(Color.aliceBlue)
                }
            }
            .frame(width: 100)
            .padding(.vertical, 24)
            
            // Contenido central
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.aliceBlue)
                
                Text(subtitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.aliceBlue.opacity(0.85))
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(Color.aliceBlue.opacity(0.7))
                    .padding(.top, 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 24)
            
            // Flecha con fondo
            VStack {
                ZStack {
                    Circle()
                        .fill(Color.aliceBlue.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.aliceBlue)
                }
            }
            .padding(.trailing, 16)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 140)
        .background(
            ZStack {
                // Gradiente principal
                LinearGradient(
                    gradient: Gradient(colors: gradient),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Icono decorativo de fondo
                Image(systemName: accentIcon)
                    .font(.system(size: 120, weight: .ultraLight))
                    .foregroundStyle(Color.aliceBlue.opacity(0.08))
                    .offset(x: 80, y: 20)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.aliceBlue.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.cobaltBlue.opacity(0.25), radius: 15, x: 0, y: 10)
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
