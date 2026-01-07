import SwiftUI
import AVKit

struct TVView: View {
    private let videoURL: URL
    @State private var player: AVPlayer

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

                VStack(spacing: 20) {
                    VStack(spacing: 12) {
                        Image(systemName: "tv.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 66, height: 66)
                            .foregroundStyle(Color.twitterBlue)
                            .shadow(color: Color.coolSky.opacity(0.16), radius: 14, x: 0, y: 6)

                        Text("Taber TV'S")
                            .font(.title.bold())
                            .foregroundStyle(Color.twitterBlue)
                    }

                    AppAVPlayerViewController(player: player)
                        .aspectRatio(16 / 9, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.aliceBlue.opacity(0.22), lineWidth: 1)
                        )
                        .shadow(color: Color.cobaltBlue.opacity(0.10), radius: 14, x: 0, y: 10)
                }
                .padding(.horizontal, 20)
                .padding(.top, 36)

                Spacer(minLength: 0)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if player.currentItem == nil {
                player.replaceCurrentItem(with: AVPlayerItem(url: videoURL))
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .stopAllMedia)) { _ in
            stopPlayback()
        }
        .onDisappear {
            stopPlayback()
        }
    }

    private func stopPlayback() {
        player.pause()
    }
}

#Preview {
    TVView()
}

