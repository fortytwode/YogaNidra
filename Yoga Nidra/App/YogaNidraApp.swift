import SwiftUI

@main
struct YogaNidraApp: App {
    @StateObject private var progressManager = ProgressManager.shared
    @StateObject private var playerState = PlayerState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(progressManager)
                .environmentObject(playerState)
        }
    }
} 