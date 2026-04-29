import SwiftUI
import AVFoundation
import Combine

struct RadioStation: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let description: String
    let dial: String
    let urlString: String
}

struct RadioView: View {
    @ObservedObject private var localization = LocalizationManager.shared
    
    let stations = [
        RadioStation(
            name: "Radio Bautista Original",
            description: L10n.radioBautistaDesc.localized(),
            dial: "106.1 FM",
            urlString: "https://uk5freenew.listen2myradio.com/live.mp3?typeportmount=s1_39762_stream_848017234"
        ),
        RadioStation(
            name: "Radio Neuma Stereo",
            description: L10n.radioNeumaDesc.localized(),
            dial: "Digital",
            urlString: "https://uk24freenew.listen2myradio.com/live.mp3?typeportmount=s1_19235_stream_187124824"
        )
    ]
    
    @State private var selectedStationIndex = 0
    
    @State private var player: AVPlayer? = nil
    @State private var isPlaying = false
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var appearAnimation = false
    @State private var waveAnimation = false
    @State private var playerStatus: AVPlayer.Status = .unknown
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        ZStack {
            AppBackground(style: .detail)
            
            VStack(spacing: 0) {
                AppHeaderBar(title: L10n.radio.localized())
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Visualizador de audio
                        ZStack {
                            // Anillos pulsantes cuando está reproduciendo
                            ForEach(0..<4, id: \.self) { index in
                                PulsingRing(index: index, isPlaying: isPlaying, waveAnimation: waveAnimation)
                            }
                            
                            // Círculo de fondo glassmorphism
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 110, height: 110)
                                .shadow(color: Color.cobaltBlue.opacity(0.2), radius: 20, x: 0, y: 10)
                            
                            // Gradiente interior
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: isPlaying ?
                                            [Color.dodgerBlue.opacity(0.3), Color.brilliantAzure.opacity(0.1)] :
                                            [Color.skyBlue.opacity(0.2), Color.icyBlue.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                            
                            // Icono de radio
                            Image(systemName: isPlaying ? "waveform" : "dot.radiowaves.left.and.right")
                                .font(.system(size: 36, weight: .medium))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.dodgerBlue, Color.twitterBlue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .symbolEffect(.variableColor, options: .repeating, isActive: isPlaying)
                        }
                        .padding(.top, 16)
                        .opacity(appearAnimation ? 1 : 0)
                        .scaleEffect(appearAnimation ? 1 : 0.8)
                        
                        // Selector de Emisoras
                        VStack(alignment: .leading, spacing: 12) {
                            Text(L10n.chooseStation.localized())
                                .font(.headline)
                                .foregroundStyle(Color.cobaltBlue)
                                .padding(.horizontal, 24)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(0..<stations.count, id: \.self) { index in
                                        Button {
                                            selectedStationIndex = index
                                            // Detener cualquier radio de fondo y cambiar
                                            stopPlayback()
                                        } label: {
                                            VStack(alignment: .leading, spacing: 6) {
                                                Image(systemName: "antenna.radiowaves.left.and.right")
                                                    .font(.title2)
                                                    .foregroundStyle(selectedStationIndex == index ? .white : Color.twitterBlue)
                                                
                                                Text(stations[index].name)
                                                    .font(.subheadline.weight(.semibold))
                                                    .foregroundStyle(selectedStationIndex == index ? .white : Color.primary)
                                                
                                                Text(stations[index].dial)
                                                    .font(.caption)
                                                    .foregroundStyle(selectedStationIndex == index ? Color.white.opacity(0.8) : Color.secondary)
                                            }
                                            .padding(16)
                                            .frame(width: 160, alignment: .leading)
                                            .background(
                                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                    .fill(selectedStationIndex == index ? Color.twitterBlue : Color.cardBackground)
                                                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 8)
                            }
                        }
                        .opacity(appearAnimation ? 1 : 0)
                        
                        // Información de la estación seleccionada
                        VStack(spacing: 12) {
                            Text(stations[selectedStationIndex].name)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.cobaltBlue)
                                .multilineTextAlignment(.center)
                            
                            Text(stations[selectedStationIndex].description)
                                .font(.subheadline)
                                .foregroundStyle(Color.gray)
                                .multilineTextAlignment(.center)
                            
                            HStack(spacing: 8) {
                                Image(systemName: "antenna.radiowaves.left.and.right")
                                    .font(.system(size: 14, weight: .semibold))
                                Text(stations[selectedStationIndex].dial)
                                    .font(.headline.weight(.semibold))
                            }
                            .foregroundStyle(Color.twitterBlue)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.dodgerBlue.opacity(0.12))
                            )
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(isPlaying ? Color.green : Color.gray.opacity(0.5))
                                    .frame(width: 8, height: 8)
                                    .scaleEffect(isPlaying && waveAnimation ? 1.2 : 1.0)
                                    .animation(
                                        isPlaying ?
                                            .easeInOut(duration: 0.8).repeatForever(autoreverses: true) :
                                            .default,
                                        value: waveAnimation
                                    )
                                
                                Text(isPlaying ? L10n.live.localized() : L10n.paused.localized())
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(isPlaying ? Color.green : Color.gray)
                            }
                            .padding(.top, 4)
                        }
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 20)
                        
                        // Botón de reproducción mejorado
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                if isPlaying {
                                    stopPlayback()
                                } else {
                                    startPlayback()
                                }
                            }
                        } label: {
                            ZStack {
                                // Sombra exterior
                                Circle()
                                    .fill(Color.cobaltBlue.opacity(0.15))
                                    .frame(width: 90, height: 90)
                                    .blur(radius: 8)
                                
                                // Círculo principal
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: isPlaying ?
                                                [Color.oceanDeep, Color.cobaltBlue] :
                                                [Color.dodgerBlue, Color.brilliantAzure]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 76, height: 76)
                                    .shadow(color: Color.cobaltBlue.opacity(0.3), radius: 10, x: 0, y: 6)
                                
                                // Borde brillante
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.aliceBlue.opacity(0.5), Color.clear],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                                    .frame(width: 76, height: 76)
                                
                                // Icono
                                Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                                    .font(.system(size: 30, weight: .semibold))
                                    .foregroundStyle(Color.aliceBlue)
                                    .offset(x: isPlaying ? 0 : 3)
                            }
                            .scaleEffect(isPlaying ? 1.05 : 1.0)
                        }
                        .accessibilityLabel(isPlaying ? "Detener radio" : "Reproducir radio")
                        .padding(.top, 8)
                        .opacity(appearAnimation ? 1 : 0)
                        
                        // Indicador de carga
                        if isLoading && !isPlaying {
                            HStack(spacing: 8) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color.twitterBlue))
                                Text(L10n.connecting.localized())
                                    .font(.subheadline)
                                    .foregroundStyle(Color.twitterBlue.opacity(0.7))
                            }
                            .padding(.top, 8)
                        }
                        
                        // Mensaje de error con botón de reintento
                        if let error = errorMessage {
                            VStack(spacing: 12) {
                                HStack(spacing: 6) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundStyle(Color.orange)
                                    Text(error)
                                        .font(.subheadline)
                                        .foregroundStyle(Color.orange)
                                }
                                
                                Button {
                                    retryPlayback()
                                } label: {
                                    Text(L10n.retry.localized())
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(Color.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(Color.dodgerBlue)
                                        )
                                }
                            }
                            .padding(.top, 8)
                        }
                        
                        Spacer(minLength: 60)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            cancellables.removeAll()
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                appearAnimation = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .stopAllMedia)) { _ in
            stopPlayback()
        }
        .onDisappear {
            stopPlayback()
        }
    }
    
    private var radioURL: URL {
        return URL(string: stations[selectedStationIndex].urlString)!
    }

    private func startPlayback() {
        errorMessage = nil
        configureAudioSessionIfPossible()
        player?.pause()
        player = nil
        
        let playerItem = AVPlayerItem(url: radioURL)
        // Optimización de batería: Limitar buffer para stream en vivo
        playerItem.preferredForwardBufferDuration = 5.0
        
        player = AVPlayer(playerItem: playerItem)
        player?.automaticallyWaitsToMinimizeStalling = true
        
        playerItem.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [self] status in
                handleStatusChange(status)
            }
            .store(in: &cancellables)
        
        playerItem.publisher(for: \.isPlaybackBufferEmpty)
            .receive(on: DispatchQueue.main)
            .sink { [self] isEmpty in
                if isEmpty && !isPlaying {
                    isLoading = true
                }
            }
            .store(in: &cancellables)
        
        isLoading = true
        player?.play()
        HomeDashboardService.shared.beginMediaSession(source: "radio")
        isPlaying = true
        waveAnimation = true
    }
    
    private func handleStatusChange(_ status: AVPlayerItem.Status) {
        switch status {
        case .readyToPlay:
            isLoading = false
            errorMessage = nil
        case .failed:
            isLoading = false
            isPlaying = false
            waveAnimation = false
            errorMessage = player?.currentItem?.error?.localizedDescription ?? L10n.connectionError.localized()
        case .unknown:
            break
        @unknown default:
            break
        }
    }
    
    private func retryPlayback() {
        player?.pause()
        player = nil
        cancellables.removeAll()
        startPlayback()
    }

    private func stopPlayback() {
        player?.pause()
        player = nil
        HomeDashboardService.shared.endMediaSession(source: "radio")
        isPlaying = false
        waveAnimation = false
        
        // Optimización de batería de Apple: Desactivar la sesión de audio al pausar
        // permite que el hardware de audio entre en reposo.
        DispatchQueue.global(qos: .background).async {
            do {
                try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            } catch {
                print("No se pudo desactivar la sesión de audio: \(error.localizedDescription)")
            }
        }
    }

    private func configureAudioSessionIfPossible() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default, options: [.allowAirPlay, .allowBluetooth])
            try session.setActive(true)
        } catch {
            // Si falla, igual intentamos reproducir con AVPlayer.
        }
    }
}

struct RadioView_Previews: PreviewProvider {
    static var previews: some View {
        RadioView()
    }
}

struct PulsingRing: View {
    let index: Int
    let isPlaying: Bool
    let waveAnimation: Bool
    
    var body: some View {
        Circle()
            .stroke(
                LinearGradient(
                    colors: [Color.dodgerBlue.opacity(0.4), Color.brilliantAzure.opacity(0.1)],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                lineWidth: isPlaying ? 3 : 1
            )
            .frame(
                width: 160 + CGFloat(index * 35),
                height: 160 + CGFloat(index * 35)
            )
            .scaleEffect(isPlaying && waveAnimation ? 1.15 : 1.0)
            .opacity(isPlaying ? (1.0 - Double(index) * 0.2) : 0.3)
            .animation(
                isPlaying ?
                    .easeInOut(duration: 1.2)
                    .repeatForever(autoreverses: true)
                    .delay(Double(index) * 0.15) :
                    .easeOut(duration: 0.3),
                value: waveAnimation
            )
    }
}
