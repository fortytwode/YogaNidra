import SwiftUI
import StoreKit
import FirebaseCore
import FirebaseAnalytics

/// Handles Firebase file uploads during app initialization
private actor FirebaseInitializer {
    static let shared = FirebaseInitializer()
    
    private init() {}
    
    func uploadTestFiles() async {
        // Test a subset of files first
        let testFiles = [
            "Brief_Reset_Brittney",
            "Deep_Sleep_Journey_Drew",
            "Energy_Renewal_James",
            "Anxiety_Release_Drew",
            "Peaceful_Night_Aria"
        ]
        
        do {
            for fileName in testFiles {
                // Try different bundle paths
                let possiblePaths = [
                    Bundle.main.path(forResource: fileName, ofType: "mp3"),
                    Bundle.main.path(forResource: fileName, ofType: "mp3", inDirectory: "Resources/Audio"),
                    Bundle.main.path(forResource: fileName, ofType: "mp3", inDirectory: "Audio")
                ].compactMap { $0 }
                
                if let audioPath = possiblePaths.first {
                    let fileURL = URL(fileURLWithPath: audioPath)
                    print("📤 Starting upload of \(fileName).mp3...")
                    print("📂 File path: \(audioPath)")
                    
                    let downloadURL = try await FirebaseManager.shared.uploadMeditation(
                        fileURL: fileURL,
                        fileName: "\(fileName).mp3"
                    ) { progress in
                        print("Upload progress for \(fileName): \(Int(progress.progress * 100))%")
                    }
                    
                    print("✅ \(fileName).mp3 uploaded successfully!")
                    print("📎 Download URL: \(downloadURL)")
                } else {
                    print("⚠️ Could not find \(fileName).mp3 in the bundle")
                }
            }
            print("🎉 All test files uploaded successfully!")
        } catch {
            print("❌ Upload failed: \(error.localizedDescription)")
            print("Error details: \(error)")
        }
    }
}

@main
struct YogaNidraApp: App {
    @StateObject private var progressManager = ProgressManager.shared
    @StateObject private var playerState = PlayerState()
    @StateObject private var storeManager = StoreManager.shared
    @StateObject private var onboardingManager = OnboardingManager.shared
    @StateObject private var audioManager = AudioManager.shared
    @StateObject private var sheetPresenter = Presenter()
    @StateObject private var overlayManager = OverlayManager.shared
    
    init() {
        FirebaseApp.configure()
        
        #if DEBUG
        // Upload test files in debug builds
        Task {
            await FirebaseInitializer.shared.uploadTestFiles()
        }
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if onboardingManager.isOnboardingCompleted {
                    ContentView()
                } else {
                    OnboardingContainerView()
                }
            }
            .onReceive(progressManager.showRaitnsDialogPublisher) {
                overlayManager.showOverlay(RatingPromptView())
            }
            .overlayContent(overlayManager)
            .sheet(item: $sheetPresenter.presenation) { destination in
                switch destination {
                case .sessionDetials(let session):
                    SessionDetailView(session: session)
                case .subscriptionPaywall:
                    SubscriptionView()
                }
            }
            .onReceive(onboardingManager.$isOnboardingCompleted) { isCompleted in
                guard isCompleted else { return }
                audioManager.stop()
            }
            .onReceive(storeManager.onPurchaseCompletedPublisher) { reason in
                switch reason {
                case .purchased(let whileOnboarding):
                    if whileOnboarding {
                        withAnimation {
                            onboardingManager.isOnboardingCompleted = true
                        }
                    }
                case .restored(let whileOnboarding):
                    if whileOnboarding {
                        withAnimation {
                            onboardingManager.isOnboardingCompleted = true
                        }
                    }
                case .whileTransactionUpdate:
                    break
                }
            }
            .environmentObject(progressManager)
            .environmentObject(playerState)
            .environmentObject(storeManager)
            .environmentObject(onboardingManager)
            .environmentObject(audioManager)
            .environmentObject(sheetPresenter)
            .environmentObject(overlayManager)
        }
    }
}
