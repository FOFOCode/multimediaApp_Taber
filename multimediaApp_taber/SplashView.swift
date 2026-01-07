import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var logoScale: CGFloat = 0.6
    @State private var logoOpacity: Double = 0
    @State private var textOffset: CGFloat = 30
    @State private var textOpacity: Double = 0
    @State private var ringScale: CGFloat = 0.8
    @State private var ringOpacity: Double = 0
    @State private var pulseAnimation = false
    
    var body: some View {
        ZStack {
            AppBackground(style: .splash)
            if isActive {
                HomeView()
                    .transition(.opacity.combined(with: .scale(scale: 1.02)))
            } else {
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Logo con anillos decorativos
                    ZStack {
                        // Anillos pulsantes
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.dodgerBlue.opacity(0.3), Color.brilliantAzure.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                                .frame(width: 200 + CGFloat(index * 40), height: 200 + CGFloat(index * 40))
                                .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                                .opacity(ringOpacity * (1 - Double(index) * 0.25))
                                .animation(
                                    .easeInOut(duration: 1.8)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.2),
                                    value: pulseAnimation
                                )
                        }
                        
                        // Círculo de fondo glassmorphism
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 180, height: 180)
                            .shadow(color: .cobaltBlue.opacity(0.2), radius: 30, x: 0, y: 15)
                        
                        Image("AppIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140)
                            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                            .shadow(color: .cobaltBlue.opacity(0.35), radius: 20, x: 0, y: 12)
                    }
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    
                    VStack(spacing: 8) {
                        Text("Taber Móvil")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.cobaltBlue, Color.twitterBlue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Tu entretenimiento en un solo lugar")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.twitterBlue.opacity(0.8))
                    }
                    .padding(.top, 28)
                    .offset(y: textOffset)
                    .opacity(textOpacity)
                    
                    Spacer()
                    
                    // Indicador de carga
                    HStack(spacing: 6) {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(Color.dodgerBlue)
                                .frame(width: 8, height: 8)
                                .scaleEffect(pulseAnimation ? 1.2 : 0.8)
                                .animation(
                                    .easeInOut(duration: 0.6)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.15),
                                    value: pulseAnimation
                                )
                        }
                    }
                    .padding(.bottom, 60)
                    .opacity(textOpacity)
                }
                .onAppear {
                    // Animación de entrada secuencial
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                        logoScale = 1.0
                        logoOpacity = 1.0
                    }
                    
                    withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                        ringOpacity = 1.0
                    }
                    
                    withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.4)) {
                        textOffset = 0
                        textOpacity = 1.0
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        pulseAnimation = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            isActive = true
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}

