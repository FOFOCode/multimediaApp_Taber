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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            switch newPhase {
            case .background, .inactive:
                stopAllMedia()
            case .active:
                break
            @unknown default:
                break
            }
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
