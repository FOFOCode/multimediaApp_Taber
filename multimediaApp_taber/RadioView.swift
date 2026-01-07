import SwiftUI
import AVFoundation

struct RadioView: View {
    private let radioURL = URL(string: "https://uk23freenew.listen2myradio.com/live.mp3?typeportmount=s1_22775_stream_184249510")!
    @State private var player: AVPlayer? = nil
    @State private var isPlaying = false
    
    var body: some View {
        ZStack {
            AppBackground(style: .detail)
            VStack(spacing: 0) {
                AppHeaderBar(title: "Radio")

                VStack(spacing: 28) {
                    VStack(spacing: 14) {
                        Image(systemName: "dot.radiowaves.left.and.right")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 66, height: 66)
                            .foregroundStyle(Color.dodgerBlue)
                            .shadow(color: Color.coolSky.opacity(0.22), radius: 14, x: 0, y: 6)

                        Text("Radio Bautista 106 FM")
                            .font(.title.bold())
                            .foregroundStyle(Color.cobaltBlue)
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        if isPlaying {
                            stopPlayback()
                        } else {
                            startPlayback()
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(
                                    isPlaying
                                    ? LinearGradient(gradient: Gradient(colors: [Color.twitterBlue, Color.cobaltBlue]), startPoint: .top, endPoint: .bottom)
                                    : LinearGradient(gradient: Gradient(colors: [Color.coolSky2, Color.dodgerBlue]), startPoint: .leading, endPoint: .trailing)
                                )
                                .frame(width: 92, height: 92)
                                .shadow(color: Color.cobaltBlue.opacity(0.14), radius: 14, x: 0, y: 8)

                            Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                                .font(.system(size: 44, weight: .semibold))
                                .foregroundStyle(Color.aliceBlue)
                                .offset(x: isPlaying ? 0 : 2)
                        }
                    }
                    .accessibilityLabel(isPlaying ? "Detener radio" : "Reproducir radio")
                }
                .padding(.horizontal, 20)
                .padding(.top, 48)

                Spacer(minLength: 0)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onReceive(NotificationCenter.default.publisher(for: .stopAllMedia)) { _ in
            stopPlayback()
        }
        .onDisappear {
            stopPlayback()
        }
    }

    private func startPlayback() {
        configureAudioSessionIfPossible()
        if player == nil {
            player = AVPlayer(url: radioURL)
        }
        player?.playImmediately(atRate: 1.0)
        isPlaying = true
    }

    private func stopPlayback() {
        player?.pause()
        isPlaying = false
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
    
    struct RadioView_Previews: PreviewProvider {
        static var previews: some View {
            RadioView()
        }
    }
    
}
