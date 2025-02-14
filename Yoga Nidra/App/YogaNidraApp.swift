import SwiftUI
import StoreKit
import FirebaseCore
import FirebaseAnalytics
import FirebaseAuth
import FirebaseCrashlytics

class AppState: ObservableObject {
    static let shared = AppState()
    @Published var selectedTab: Int = 0
    @Published var shouldShowValentrineDayTab: Bool = false
    @Published var isNewFeature: Bool = true  // Will show highlight on the tab
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
    @StateObject private var appState = AppState.shared
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if onboardingManager.isOnboardingCompleted {
                    ContentView()
                        .environmentObject(playerState)
                        .environmentObject(sheetPresenter)
                        .environmentObject(overlayManager)
                        .environmentObject(audioManager)
                        .environmentObject(appState)
                        .onAppear {
                            if let user = Auth.auth().currentUser {
                                print("✅ User authenticated: \(user.uid)")
                            } else {
                                print("❌ User not authenticated")
                                // Create an anonymous user
                                Task {
                                    do {
                                        let result = try await Auth.auth().signInAnonymously()
                                        print("✅ Anonymous user created: \(result.user.uid)")
                                    } catch {
                                        print("❌ Failed to create anonymous user: \(error)")
                                    }
                                }
                            }
                        }
                        .onLoad {
                            audioManager.stopOnboardingMusic()
                        }
                } else {
                    OnboardingContainerView()
                        .environmentObject(onboardingManager)
                        .environmentObject(audioManager)
                        .onLoad {
                            audioManager.startOnboardingMusic()
                        }
                }
            }
            .onOpenURL { url in
                print("📱 Universal Link received: \(url.absoluteString)")
                print("📱 URL components: \(url)")
                print("📱 URL scheme: \(url.scheme ?? "none")")
                print("📱 URL host: \(url.host ?? "none")")
                print("📱 URL path: \(url.path)")
                
                // Normalize path by removing trailing slash if present
                let normalizedPath = url.path.hasSuffix("/") ? String(url.path.dropLast()) : url.path
                
                if normalizedPath == "/selflove14days" {
                    print("📱 Self Love program link detected")
                    // Skip onboarding for universal links
                    // Navigate to home tab
                    DispatchQueue.main.async {
                        appState.shouldShowValentrineDayTab = true
                        appState.selectedTab = 3
                        if !onboardingManager.isOnboardingCompleted {
                            print("📱 Skipping onboarding for universal link")
                            onboardingManager.isOnboardingCompleted = true
                        }
                    }
                } else if normalizedPath == "/tab1" {
                    print("📱 Tab 1 link detected")
                    DispatchQueue.main.async {
                        appState.selectedTab = 1
                    }
                } else if normalizedPath == "/tab2" {
                    print("📱 Tab 2 link detected")
                    DispatchQueue.main.async {
                        appState.selectedTab = 2
                    }
                } else {
                    print("❌ Unknown deep link path: \(normalizedPath)")
                }
            }
            .onReceive(progressManager.showRaitnsDialogPublisher) {
                overlayManager.showOverlay(RatingPromptView())
            }
            .overlayContent(overlayManager)
            .sheet(item: $sheetPresenter.presenation) {
                sheetPresenter.dismiss()
            } content: { destination in
                switch destination {
                case .sessionDetials(let session):
                    SessionDetailView(session: session)
                        .environmentObject(progressManager)
                case .subscriptionPaywall:
                    SubscriptionView()
                }
            }
            .onReceive(onboardingManager.$isOnboardingCompleted) { isCompleted in
                guard isCompleted else { return }
                Task {
                    await audioManager.stop(mode: .clearSession)
                }
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
            .environmentObject(appState)
        }
    }
    
    private func beginBackgroundTask() {
        var backgroundTask: UIBackgroundTaskIdentifier = .invalid
        backgroundTask = UIApplication.shared.beginBackgroundTask {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
}
