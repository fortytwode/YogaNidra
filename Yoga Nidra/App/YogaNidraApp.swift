import SwiftUI
import SwiftMessages
import StoreKit
import FirebaseCore
import FirebaseAnalytics
import FirebaseAuth
import FirebaseCrashlytics
import GoogleSignIn

enum AppTab {
    case home
    case discover
    case library
    case profile
}

class AppState: ObservableObject {
    static let shared = AppState()
    @Published var selectedTab: AppTab = .home
    @Published var isNewFeature: Bool = true  // Will show highlight on the tab
}

@main
struct YogaNidraApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var rechabilityManager = RechabilityManager.shared
    @StateObject private var progressManager = ProgressManager.shared
    @StateObject private var playerState = PlayerState()
    @StateObject private var storeManager = StoreManager.shared
    @StateObject private var onboardingManager = OnboardingManager.shared
    @StateObject private var audioManager = AudioManager.shared
    @StateObject private var sheetPresenter = Presenter()
    @StateObject private var overlayManager = OverlayManager.shared
    @StateObject private var appState = AppState.shared
    @StateObject private var notificationSettingsManager = NotificationSettingsManager.shared
    
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
                            // Configure Google Sign-In
                            GoogleAuthManager.shared.configure()
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
                            // Configure Google Sign-In
                            GoogleAuthManager.shared.configure()
                        }
                }
            }
            .sheet(isPresented: $onboardingManager.shouldShowGoogleAuth) {
                GoogleAuthView()
            }
            .onOpenURL { url in
                // Handle Google Sign-In callback
                if GIDSignIn.sharedInstance.handle(url) {
                    return
                }
                
                // Handle existing deep links
                print("📱 Universal Link received: \(url.absoluteString)")
                print("📱 URL components: \(url)")
                print("📱 URL scheme: \(url.scheme ?? "none")")
                print("📱 URL host: \(url.host ?? "none")")
                print("📱 URL path: \(url.path)")
                
                // Normalize path by removing trailing slash if present
                let normalizedPath = url.path.hasSuffix("/") ? String(url.path.dropLast()) : url.path
                
                if normalizedPath == "/tab1" {
                    print("📱 Tab 1 link detected")
                    DispatchQueue.main.async {
                        appState.selectedTab = .home
                    }
                } else if normalizedPath == "/tab2" {
                    print("📱 Tab 2 link detected")
                    DispatchQueue.main.async {
                        appState.selectedTab = .discover
                    }
                } else {
                    print("❌ Unknown deep link path: \(normalizedPath)")
                }
            }
            .onReceive(progressManager.showRaitnsDialogPublisher) {
                overlayManager.showOverlay(RatingPromptView())
            }
            .onReceive(rechabilityManager.rechabilityChangedPublisher) {
                if !rechabilityManager.isNetworkRechable {
                    SwiftMessages.hideAll()
                    SwiftMessages.show(
                        view: ToastView(
                            message: "You are currently offline. Please connect to the internet to play this meditation. 📶",
                            backgroundColor: Color.red.opacity(0.9)
                        ).uiView
                    )
                } else {
                    SwiftMessages.hideAll()
                    SwiftMessages.show(
                        view: ToastView(
                            message: "Back online 📶",
                            backgroundColor: Color.green.opacity(0.8)
                        ).uiView
                    )
                }
            }
            .overlayContent(overlayManager)
            .sheet(item: $sheetPresenter.presentation) {
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
                audioManager.stop(mode: .clearSession)
            }
            .onReceive(storeManager.onPurchaseCompletedPublisher) { reason in
                switch reason {
                case .purchased(let whileOnboarding):
                    if whileOnboarding {
                        // Only complete onboarding if we're actually in the PaywallView
                        // This prevents race conditions during navigation
                        if let currentPage = onboardingManager.currentOnboardingPage, currentPage == 16 {
                            withAnimation {
                                onboardingManager.isOnboardingCompleted = true
                            }
                        } else {
                            print("⚠️ Purchase completed with whileOnboarding=true, but not in PaywallView. Ignoring onboarding completion.")
                        }
                    }
                case .restored(let whileOnboarding):
                    if whileOnboarding {
                        // Only complete onboarding if we're actually in the PaywallView
                        // This prevents race conditions during navigation
                        if let currentPage = onboardingManager.currentOnboardingPage, currentPage == 16 {
                            withAnimation {
                                onboardingManager.isOnboardingCompleted = true
                            }
                        } else {
                            print("⚠️ Purchase restored with whileOnboarding=true, but not in PaywallView. Ignoring onboarding completion.")
                        }
                    }
                case .skipped(let whileOnboarding):
                    if whileOnboarding {
                        // Only complete onboarding if we're actually in the PaywallView
                        // This prevents race conditions during navigation
                        if let currentPage = onboardingManager.currentOnboardingPage, currentPage == 16 {
                            withAnimation {
                                onboardingManager.isOnboardingCompleted = true
                            }
                        } else {
                            print("⚠️ Subscription skipped with whileOnboarding=true, but not in PaywallView. Ignoring onboarding completion.")
                        }
                    }
                case .whileTransactionUpdate:
                    // Explicitly do nothing for background transaction updates
                    // This prevents race conditions during navigation
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
            .environmentObject(rechabilityManager)
            .environmentObject(notificationSettingsManager)
            .scalableApp() // Apply the scaling modifier to the entire app
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
