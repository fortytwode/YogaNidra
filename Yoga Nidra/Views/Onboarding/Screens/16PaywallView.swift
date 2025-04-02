import SwiftUI
import FBSDKCoreKit
import RevenueCat
import SuperwallKit

struct PaywallView: View {
    @EnvironmentObject private var storeManager: StoreManager
    @EnvironmentObject private var onboardingManager: OnboardingManager
    @Environment(\.openURL) private var openURL
    @Environment(\.presentationMode) private var presentationMode
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var superwallPresentationFailed = false
    @State private var notificationToken: NSObjectProtocol?
    
    // RevenueCat manager reference
    @StateObject private var revenueCatManager = RevenueCatManager.shared
    
    var body: some View {
        // Your existing beautiful UI as a fallback
        ZStack {
            // Background
            Image("mountain-lake-twilight")
                .resizable()
                .scaledToFill()
                .overlay(Color.black.opacity(0.4))
                .edgesIgnoringSafeArea(.all)
            
            // Content
            VStack(spacing: 24) {
                // Headline
                Text("Sweet Dreams Start Here ✨")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
                    .padding(.top, 20)
                
                Spacer()
                
                // Loading indicator - hide if Superwall presentation failed
                if !superwallPresentationFailed {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
                
                Spacer()
                
                // Fallback button in case Superwall doesn't load
                // Show with full opacity if Superwall presentation failed
                Button {
                    Task {
                        do {
                            try await storeManager.purchase()
                            onboardingManager.isOnboardingCompleted = true
                            
                            // Track trial started event with Facebook
                            FacebookEventTracker.shared.trackTrialStarted(planName: "premium_yearly")
                            
                        } catch {
                            showError = true
                            errorMessage = error.localizedDescription
                        }
                    }
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(.white)
                        .cornerRadius(28)
                        .padding(.horizontal)
                }
                .opacity(superwallPresentationFailed ? 1.0 : 0.7) // Full opacity if Superwall failed
            }
            .padding(.bottom, 30)
        }
        .onAppear {
            // Log impression in Firebase
            FirebaseManager.shared.logPaywallImpression(source: "onboarding")
            
            // Add notification observer for Superwall presentation failures
            // Use a closure capture instead of weak self since struct doesn't support weak
            notificationToken = NotificationCenter.default.addObserver(
                forName: SuperwallManager.presentationFailedNotification,
                object: nil,
                queue: .main
            ) { [self] _ in
                self.superwallPresentationFailed = true
            }
            
            // Show Superwall after a brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                presentSuperwallPaywall()
            }
        }
        .onDisappear {
            // Remove notification observer
            if let token = notificationToken {
                NotificationCenter.default.removeObserver(token)
                notificationToken = nil
            }
        }
        .alert(errorMessage, isPresented: $showError) {
            Button("OK", role: .cancel) { }
        }
    }
    
    private func presentSuperwallPaywall() {
        // Use the enhanced error handling method
        SuperwallManager.shared.showPaywallWithErrorHandling()
    }
}

struct BenefitRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .frame(width: 32, alignment: .center)
                .foregroundColor(.white)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(nil)
        }
    }
}

struct StatRow: View {
    let emoji: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(emoji)
                .font(.title2)
                .frame(width: 32, alignment: .center)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(nil)
            
            Spacer()
        }
    }
}

#if DEBUG
struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardingQuestionWrapper(currentStep: 16) {
                PaywallView()
                    .environmentObject(StoreManager.preview)
                    .environmentObject(OnboardingManager.preview)
            }
            
            OnboardingQuestionWrapper(currentStep: 16) {
                PaywallView()
                    .environmentObject(StoreManager.preview)
                    .environmentObject(OnboardingManager.preview)
            }
            .previewDevice("iPhone SE (3rd generation)")
            .previewDisplayName("iPhone SE")
        }
    }
}
#endif
