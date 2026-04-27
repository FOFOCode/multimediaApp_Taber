//
//  multimediaApp_taberApp.swift
//  multimediaApp_taber
//
//  Created by Rodolfo Rivas on 6/1/26.
//

import SwiftUI
import AVFoundation

@main
struct multimediaApp_taberApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .animation(.easeInOut(duration: 0.5), value: isDarkMode)
                .onAppear {
                    setupNotifications()
                }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            switch newPhase {
            case .background, .inactive:
                stopAllMedia()
            case .active:
                NotificationService.shared.clearBadge()
                Task {
                    await NotificationService.shared.fetchDailyVerse()
                    await NotificationService.shared.scheduleAllNotifications()
                }
            @unknown default:
                break
            }
        }
    }
    
    private func setupNotifications() {
        Task {
            await NotificationService.shared.checkAuthorizationStatus()
            await NotificationService.shared.fetchDailyVerse()
            await NotificationService.shared.scheduleAllNotifications()
        }
    }
    
    private func stopAllMedia() {
        NotificationCenter.default.post(name: .stopAllMedia, object: nil)
        deactivateAudioSession()
    }
    
    private func deactivateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Error deactivateAudioSession: \(error)")
        }
    }
}
