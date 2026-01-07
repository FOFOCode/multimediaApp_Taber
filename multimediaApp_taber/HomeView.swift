import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground(style: .home)
                VStack(spacing: 22) {
                    VStack(spacing: 6) {
                        Text("Bienvenido")
                            .font(.largeTitle.bold())
                        Text("a Taber Móvil")
                            .font(.title2.weight(.semibold))
                    }
                    .foregroundStyle(Color.aliceBlue)
                    .multilineTextAlignment(.center)
                    .shadow(color: Color.cobaltBlue.opacity(0.25), radius: 10, x: 0, y: 6)
                    .padding(.top, 10)

                    Spacer(minLength: 10)

                    VStack(spacing: 16) {
                        NavigationLink(destination: RadioView()) {
                            AppActionCard(
                                icon: "dot.radiowaves.left.and.right",
                                title: "Radio Bautista 106 FM",
                                gradient: [Color.dodgerBlue, Color.brilliantAzure],
                                minHeight: 132
                            )
                        }

                        NavigationLink(destination: TVView()) {
                            AppActionCard(
                                icon: "tv.fill",
                                title: "Taber TV’S",
                                gradient: [Color.twitterBlue, Color.oceanDeep],
                                minHeight: 132
                            )
                        }
                    }

                    Spacer(minLength: 0)

                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 14)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .onAppear {
            NotificationCenter.default.post(name: .stopAllMedia, object: nil)
        }
    }
    
    struct HomeView_Previews: PreviewProvider {
        static var previews: some View {
            HomeView()
        }
    }
    
}
