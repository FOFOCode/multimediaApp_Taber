import SwiftUI
import AVKit
import AVFoundation
import Combine

struct TVView: View {
    @ObservedObject private var localization = LocalizationManager.shared
    private let videoURL = URL(string: "https://live20.bozztv.com/akamaissh101/ssh101/tabertv2024/chunks.m3u8")!
    @State private var player: AVPlayer?
    @State private var playerItem: AVPlayerItem?
    @State private var appearAnimation = false
    @State private var shouldPlay = true
    @State private var isBuffering = true
    @State private var showError = false
    @State private var cancellables = Set<AnyCancellable>()

    var body: some View {
        ZStack {
            AppBackground(style: .detail)
            
            VStack(spacing: 0) {
                AppHeaderBar(title: L10n.tv.localized())
                
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
                                Text(L10n.tvTitle.localized())
                                    .font(.title2.weight(.bold))
                                    .foregroundStyle(Color.cobaltBlue)
                                
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 8, height: 8)
                                    Text(L10n.live.localized().uppercased())
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

                                // Indicador de buffering
                                if isBuffering {
                                    VStack(spacing: 16) {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(1.5)
                                        Text(L10n.loading.localized())
                                            .font(.subheadline)
                                            .foregroundStyle(.white.opacity(0.7))
                                    }
                                }

                                // Reproductor
                                if let player = player, !showError {
                                    AppAVPlayerViewController(
                                        player: player,
                                        showsPlaybackControls: true,
                                        allowsPictureInPicture: true,
                                        updatesNowPlayingInfoCenter: true
                                    )
                                    .aspectRatio(16 / 9, contentMode: .fit)
                                    .onAppear {
                                        isBuffering = false
                                    }
                                }

                                // Indicador de error
                                if showError {
                                    VStack(spacing: 12) {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .font(.system(size: 40))
                                            .foregroundStyle(.orange)
                                        Text(L10n.videoLoadError.localized())
                                            .font(.subheadline)
                                            .foregroundStyle(.white.opacity(0.8))
                                        Button("Reintentar") {
                                            setupPlayer()
                                        }
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 8)
                                        .background(Capsule().fill(Color.dodgerBlue))
                                    }
                                }
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
                                InfoPill(icon: "play.tv.fill", text: L10n.streaming.localized())
                                InfoPill(icon: "antenna.radiowaves.left.and.right", text: L10n.live.localized())
                                InfoPill(icon: "airplayvideo", text: L10n.airplay.localized())
                            }
                            
                            Text(L10n.christianTv24.localized())
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
            setupPlayer()
            
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
            cancellables.removeAll()
        }
    }

    private func setupPlayer() {
        isBuffering = true
        showError = false
        player?.pause()
        cancellables.removeAll()
        
        configureAudioSession()
        
        let item = AVPlayerItem(url: videoURL)
        item.preferredForwardBufferDuration = 2
        
        playerItem = item
        player = AVPlayer(playerItem: item)
        player?.automaticallyWaitsToMinimizeStalling = false
        
        item.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [self] status in
                switch status {
                case .readyToPlay:
                    isBuffering = false
                    player?.play()
                    HomeDashboardService.shared.beginMediaSession(source: "tv")
                case .failed:
                    isBuffering = false
                    showError = true
                case .unknown:
                    break
                @unknown default:
                    break
                }
            }
            .store(in: &cancellables)
        
        item.publisher(for: \.isPlaybackBufferEmpty)
            .receive(on: DispatchQueue.main)
            .sink { [self] isEmpty in
                if isEmpty {
                    isBuffering = true
                }
            }
            .store(in: &cancellables)
        
        item.publisher(for: \.isPlaybackLikelyToKeepUp)
            .receive(on: DispatchQueue.main)
            .sink { [self] likelyToKeepUp in
                if likelyToKeepUp {
                    isBuffering = false
                }
            }
            .store(in: &cancellables)
        
        shouldPlay = true
        player?.seek(to: .zero)
        player?.play()
    }
    
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .moviePlayback, options: [.allowAirPlay, .allowBluetooth])
            try session.setActive(true)
        } catch {
            print("Error configurando audio session: \(error)")
        }
    }
    
    private func stopPlayback() {
        shouldPlay = false
        player?.pause()
        player = nil
        playerItem = nil
        HomeDashboardService.shared.endMediaSession(source: "tv")
        
        // Optimización de batería y recursos: Desactivar la sesión de audio
        DispatchQueue.global(qos: .background).async {
            do {
                try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            } catch {
                print("Error configurando audio session: \(error)")
            }
        }
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

