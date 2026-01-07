import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    
    var body: some View {
        ZStack {
            AppBackground(style: .splash)
            if isActive {
                HomeView()
            } else {
                VStack {
                    Spacer()
                    Image("AppIcon") // Usa el nombre exacto de tu logo en Assets
                        .resizable()
                        .scaledToFit()
                        .frame(width: 178)
                        .shadow(color: .cobaltBlue.opacity(0.23), radius: 18, x: 0, y: 10)
                    Text("Taber Móvil")
                        .font(.largeTitle.bold())
                        .foregroundColor(.cobaltBlue)
                        .padding(.top, 18)
                        .shadow(color: .white.opacity(0.18), radius: 5, x: 0, y: 1)
                    Spacer()
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
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

