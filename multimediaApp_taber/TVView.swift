import SwiftUI
import AVKit

struct TVView: View {
    private let videoURL: URL
    @State private var player: AVPlayer
    @State private var appearAnimation = false
    @State private var shouldPlay = true

    init() {
        let url = URL(string: "https://live20.bozztv.com/akamaissh101/ssh101/tabertv2024/chunks.m3u8")!
        self.videoURL = url
        _player = State(initialValue: AVPlayer(url: url))
    }

    var body: some View {
        ZStack {
            AppBackground(style: .detail)
            
            VStack(spacing: 0) {
                AppHeaderBar(title: "TV")
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header con información del canal
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.twitterBlue, Color.oceanDeep],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 60, height: 60)
                                    .shadow(color: Color.cobaltBlue.opacity(0.2), radius: 10, x: 0, y: 5)
                                
                                Image(systemName: "tv.fill")
                                    .font(.system(size: 26, weight: .semibold))
                                    .foregroundStyle(Color.aliceBlue)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Taber TV's")
                                    .font(.title2.weight(.bold))
                                    .foregroundStyle(Color.cobaltBlue)
                                
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 8, height: 8)
                                    Text("EN VIVO")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(Color.red)
                                    
                                    Text("•")
                                        .foregroundStyle(Color.gray)
                                    
                                    Text("HD")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(Color.twitterBlue)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(
                                            Capsule()
                                                .fill(Color.twitterBlue.opacity(0.15))
                                        )
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 4)
                        .padding(.top, 20)
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 15)
                        
                        // Reproductor de video mejorado
                        VStack(spacing: 0) {
                            ZStack {
                                // Fondo del reproductor
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(Color.black)
                                
                                AppAVPlayerViewController(
                                    player: player,
                                    showsPlaybackControls: true,
                                    allowsPictureInPicture: true,
                                    updatesNowPlayingInfoCenter: true
                                )
                                .aspectRatio(16 / 9, contentMode: .fit)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.aliceBlue.opacity(0.3), Color.twitterBlue.opacity(0.1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                            .shadow(color: Color.cobaltBlue.opacity(0.2), radius: 20, x: 0, y: 12)
                        }
                        .opacity(appearAnimation ? 1 : 0)
                        .scaleEffect(appearAnimation ? 1 : 0.95)
                        
                        // Información adicional
                        VStack(spacing: 16) {
                            // Card de información
                            HStack(spacing: 12) {
                                InfoPill(icon: "play.tv.fill", text: "Streaming")
                                InfoPill(icon: "antenna.radiowaves.left.and.right", text: "En vivo")
                                InfoPill(icon: "airplayvideo", text: "AirPlay")
                            }
                            
                            Text("Televisión cristiana las 24 horas")
                                .font(.subheadline)
                                .foregroundStyle(Color.twitterBlue.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 8)
                        .opacity(appearAnimation ? 1 : 0)
                        
                        Spacer(minLength: 60)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if player.currentItem == nil {
                player.replaceCurrentItem(with: AVPlayerItem(url: videoURL))
            }
            
            shouldPlay = true
            // Reproducir automáticamente
            player.play()
            
            // Observar cambios de tasa para mantener la reproducción
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem,
                queue: .main
            ) { _ in
                if shouldPlay {
                    player.seek(to: .zero)
                    player.play()
                }
            }
            
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                appearAnimation = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .stopAllMedia)) { _ in
            stopPlayback()
        }
        .onDisappear {
            shouldPlay = false
            stopPlayback()
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        }
    }

    private func stopPlayback() {
        player.pause()
    }
}

// Componente para las píldoras de información
struct InfoPill: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
            Text(text)
                .font(.caption.weight(.medium))
        }
        .foregroundStyle(Color.twitterBlue)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.twitterBlue.opacity(0.1))
        )
    }
}

#Preview {
    TVView()
}

