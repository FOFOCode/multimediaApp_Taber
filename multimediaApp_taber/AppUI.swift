import SwiftUI
import AVKit

extension Notification.Name {
    static let stopAllMedia = Notification.Name("stopAllMedia")
}

enum AppBackgroundStyle {
    case home
    case detail
    case splash
}

struct AppBackground: View {
    let style: AppBackgroundStyle

    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: startPoint,
            endPoint: endPoint
        )
        .ignoresSafeArea()
        .overlay(
            LinearGradient(
                gradient: Gradient(colors: [Color.aliceBlue.opacity(0.12), Color.cobaltBlue.opacity(0.10)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }

    private var colors: [Color] {
        switch style {
        case .home:
            return [Color.icyBlue, Color.coolSky, Color.cobaltBlue]
        case .detail:
            return [Color.aliceBlue, Color.skyBlue, Color.coolSky2]
        case .splash:
            return [Color.aliceBlue, Color.icyBlue, Color.coolSky]
        }
    }

    private var startPoint: UnitPoint {
        switch style {
        case .home:
            return .topLeading
        case .detail:
            return .top
        case .splash:
            return .topLeading
        }
    }

    private var endPoint: UnitPoint {
        switch style {
        case .home:
            return .bottomTrailing
        case .detail:
            return .bottom
        case .splash:
            return .bottomTrailing
        }
    }
}

struct AppHeaderBar: View {
    let title: String

    @Environment(\.dismiss) private var dismiss
    @State private var isPressed = false

    var body: some View {
        HStack(spacing: 12) {
            Button {
                dismiss()
            } label: {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 44, height: 44)
                        .shadow(color: Color.cobaltBlue.opacity(0.1), radius: 8, x: 0, y: 4)
                    
                    Circle()
                        .stroke(Color.aliceBlue.opacity(0.5), lineWidth: 1)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color.cobaltBlue)
                }
            }
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
            .accessibilityLabel("Volver")

            Spacer(minLength: 0)

            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Color.cobaltBlue)
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            Spacer(minLength: 0)

            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
}

struct AppActionCard: View {
    let icon: String
    let title: String
    let gradient: [Color]
    var minHeight: CGFloat = 0

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.aliceBlue.opacity(0.16))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color.aliceBlue)
            }

            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.aliceBlue)
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.aliceBlue.opacity(0.9))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity)
        .frame(minHeight: minHeight)
        .background(
            LinearGradient(
                gradient: Gradient(colors: gradient),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color.cobaltBlue.opacity(0.14), radius: 10, x: 0, y: 6)
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct AppAVPlayerViewController: UIViewControllerRepresentable {
    let player: AVPlayer
    var showsPlaybackControls: Bool = true
    var allowsPictureInPicture: Bool = true
    var updatesNowPlayingInfoCenter: Bool = true

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = showsPlaybackControls
        controller.allowsPictureInPicturePlayback = allowsPictureInPicture
        controller.updatesNowPlayingInfoCenter = updatesNowPlayingInfoCenter
        
        // Configurar para que no pause automáticamente
        controller.delegate = context.coordinator
        
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        if uiViewController.player !== player {
            uiViewController.player = player
        }
        uiViewController.showsPlaybackControls = showsPlaybackControls
        uiViewController.allowsPictureInPicturePlayback = allowsPictureInPicture
        uiViewController.updatesNowPlayingInfoCenter = updatesNowPlayingInfoCenter
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(player: player)
    }
    
    class Coordinator: NSObject, AVPlayerViewControllerDelegate {
        let player: AVPlayer
        
        init(player: AVPlayer) {
            self.player = player
            super.init()
        }
        
        // Reanudar reproducción después de cambios de pantalla completa
        func playerViewController(
            _ playerViewController: AVPlayerViewController,
            willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator
        ) {
            coordinator.animate(alongsideTransition: nil) { _ in
                // Asegurar que sigue reproduciendo después de salir de pantalla completa
                if self.player.timeControlStatus != .playing {
                    self.player.play()
                }
            }
        }
        
        func playerViewController(
            _ playerViewController: AVPlayerViewController,
            willBeginFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator
        ) {
            coordinator.animate(alongsideTransition: nil) { _ in
                // Asegurar que sigue reproduciendo al entrar a pantalla completa
                if self.player.timeControlStatus != .playing {
                    self.player.play()
                }
            }
        }
    }
}
