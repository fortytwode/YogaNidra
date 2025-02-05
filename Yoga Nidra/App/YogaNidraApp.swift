import SwiftUI
import StoreKit
import FirebaseCore
import FirebaseAnalytics

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
