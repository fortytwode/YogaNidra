import SwiftUI
import FBSDKCoreKit
import RevenueCat

struct PaywallView: View {
    @EnvironmentObject private var storeManager: StoreManager
    @EnvironmentObject private var onboardingManager: OnboardingManager
    @Environment(\.openURL) private var openURL
    @State private var showError = false
    @State private var errorMessage = ""
    
    // RevenueCat manager reference
    @StateObject private var revenueCatManager = RevenueCatManager.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Main Content
                VStack(spacing: 24) {
                    // Headline
                    Text("Sweet Dreams Start Here ✨")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal)
                        .padding(.top, 20)
                    
                    ScrollView {
                        // Benefits
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Snuggle up with better sleep 🛏️")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.bottom, 4)
                            
                            BenefitRow(icon: "bed.double.fill",
                                      title: "Find deep sleep faster with guided rest")
                            
                            BenefitRow(icon: "leaf.fill",
                                      title: "Enhance your sleep quality naturally")
                            
                            BenefitRow(icon: "theatermasks.fill",
                                      title: "Melt away stress, night after night")
                        }
                        .padding(.horizontal)
                        
                        // Research Stats
                        VStack(spacing: 16) {
                            Text("Snooze Report 🌙")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                StatRow(emoji: "🌛", text: "84% fewer sleepless nights")
                                StatRow(emoji: "🌠", text: "More time in deep, restorative sleep")
                                StatRow(emoji: "⏰", text: "Fall asleep 30 minutes faster")
                            }
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                    .scrollIndicators(.hidden)
                }
                
                // Bottom Section
                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        Text("7 nights of sweet dreams on us 🎁")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        // Use price from RevenueCat if available
                        Text("Then just \(storeManager.formattedPrice) (that's $5/month for better sleep) 💎")
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                    }
                    
                    Button {
                        Task {
                            do {
                                // Use StoreManager which delegates to RevenueCat
                                try await storeManager.purchase()
                                onboardingManager.isOnboardingCompleted = true
                                
                                // Track trial started event with Facebook
                                // Note: RevenueCatManager also tracks this event internally
                                FacebookEventTracker.shared.trackTrialStarted(planName: "premium_yearly")
                                
                            } catch {
                                showError = true
                                errorMessage = error.localizedDescription
                            }
                        }
                    } label: {
                        if storeManager.isLoading || revenueCatManager.isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                        } else {
                            HStack {
                                Text("Start your free trial")
                                Text("→")
                                Text("🌜")
                            }
                            .font(.headline)
                            .foregroundColor(.accentColor)
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(height: 56)
                    .background(.white)
                    .cornerRadius(28)
                    .padding(.horizontal)
                    
                    Button {
                        Task {
                            do {
                                try await storeManager.restore()
                                onboardingManager.isOnboardingCompleted = true
                                
                                // Track restore purchase with Facebook (optional)
                                FacebookEventTracker.shared.trackTrialStarted(planName: "restored_purchase")
                                
                            } catch {
                                showError = true
                                errorMessage = error.localizedDescription
                            }
                        }
                    } label: {
                        Text("Restore Purchases")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 12)
                    
                    if let date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) {
                        Text("Cancel anytime before \(date.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    HStack(spacing: 24) {
                        Button {
                            openURL(URL(string: "https://rocketshiphq.com/yoga-nidra-terms")!)
                        } label: {
                            Text("Terms")
                                .font(.footnote)
                                .foregroundColor(.white.opacity(0.8))
                                .underline()
                        }
                        
                        Button {
                            openURL(URL(string: "https://rocketshiphq.com/yoga-nidra-privacy")!)
                        } label: {
                            Text("Privacy Policy")
                                .font(.footnote)
                                .foregroundColor(.white.opacity(0.8))
                                .underline()
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(.bottom, 16)
            }
        }
        .onAppear {
            FirebaseManager.shared.logPaywallImpression(source: "onboarding")
            
            // Refresh offerings when view appears
            Task {
                await revenueCatManager.loadOfferings()
            }
        }
        .alert(revenueCatManager.errorMessage ?? "Purchase Failed", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .background(
            ZStack {
                Image("mountain-lake-twilight")
                    .resizable()
                    .scaledToFill()
                    .overlay(Color.black.opacity(0.4))
                    .edgesIgnoringSafeArea(.all)
                
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.3)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
            }
        )
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
