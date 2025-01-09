import SwiftUI

struct FinalProfileView: View {
    @EnvironmentObject var onboardingManager: OnboardingManager
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @StateObject private var preferencesManager = PreferencesManager.shared
    @State private var isLoading = true
    @State private var showingSubscriptionSheet = false
    
    var body: some View {
        VStack(spacing: 32) {
            if isLoading {
                VStack(spacing: 24) {
                    ProgressView()
                        .scaleEffect(1.5)
                    
                    Text("Creating your personalized meditation plan")
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)
                }
            } else {
                // Personalized recommendations
                let recommendations = preferencesManager.getPersonalizedRecommendations()
                
                VStack(spacing: 24) {
                    recommendationRow(
                        title: "Suggested Session",
                        detail: recommendations.session
                    )
                    
                    recommendationRow(
                        title: "Optimal Time",
                        detail: recommendations.time
                    )
                    
                    recommendationRow(
                        title: "Weekly Goal",
                        detail: recommendations.frequency
                    )
                }
                .padding(24)
                .background(Color(uiColor: .systemGray6))
                .cornerRadius(16)
                
                // Additional personalized message based on their biggest challenge
                personalizedMessage
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button {
                        showingSubscriptionSheet = true
                    } label: {
                        VStack(spacing: 8) {
                            Text("Start 7 days for free")
                                .font(.headline)
                            Text("Then \(subscriptionManager.subscriptionPrice)/year")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    Button {
                        onboardingManager.shouldShowOnboarding = false
                    } label: {
                        Text("Skip for now")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .onAppear {
            // Simulate loading time
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isLoading = false
            }
        }
        .sheet(isPresented: $showingSubscriptionSheet) {
            SubscriptionView()
        }
        .onChange(of: subscriptionManager.isSubscribed) { subscribed in
            if subscribed {
                onboardingManager.shouldShowOnboarding = false
            }
        }
    }
    
    private var personalizedMessage: some View {
        let message = getPersonalizedMessage()
        return Text(message)
            .font(.headline)
            .multilineTextAlignment(.center)
            .foregroundColor(.gray)
            .padding(.top)
    }
    
    private func getPersonalizedMessage() -> String {
        if preferencesManager.preferences.fallAsleepTime == "Over an hour" {
            return "We'll help you fall asleep faster with specialized techniques"
        } else if preferencesManager.preferences.nightWakeups == "Every night" {
            return "Our sessions are designed to help you stay asleep through the night"
        } else if preferencesManager.preferences.sleepImpact == "Significantly" {
            return "Transform your sleep and reclaim your days with Yoga Nidra"
        } else {
            return "Your personalized path to better sleep starts here"
        }
    }
    
    private func recommendationRow(title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Text(detail)
                .font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
} 