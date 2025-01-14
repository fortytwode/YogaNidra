import SwiftUI

@main
struct YogaNidraApp: App {
    @StateObject private var progressManager = ProgressManager.shared
    @StateObject private var playerState = PlayerState()
    @StateObject private var storeManager = StoreManager.shared
    @StateObject private var onboardingManager = OnboardingManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(progressManager)
                .environmentObject(playerState)
                .environmentObject(storeManager)
                .environmentObject(onboardingManager)
        }
    }
}