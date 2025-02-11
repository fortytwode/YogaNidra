import SwiftUI
import StoreKit
import FirebaseCore
import FirebaseAnalytics
import FirebaseAuth
import FirebaseCrashlytics

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
        Analytics.setAnalyticsCollectionEnabled(true)
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
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
            .onReceive(progressManager.showRaitnsDialogPublisher) {
                overlayManager.showOverlay(RatingPromptView())
            }
            .overlayContent(overlayManager)
            .sheet(item: $sheetPresenter.presenation) { destination in
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
