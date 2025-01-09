import SwiftUI

struct PremiumContentSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 24) {
            // Premium Icon
            Image(systemName: "crown.fill")
                .font(.system(size: 44))
                .foregroundColor(.yellow)
            
            Text("Premium Content")
                .font(.title)
                .bold()
            
            Text("Subscribe to access all premium meditations")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            // Feature List
            VStack(alignment: .leading, spacing: 12) {
                FeatureRow("Access all premium sessions")
                FeatureRow("New content monthly")
                FeatureRow("Background playback")
                FeatureRow("Download for offline use")
            }
            
            Spacer()
            
            // Subscribe Button
            Button {
                Task {
                    do {
                        try await subscriptionManager.purchase()
                        if subscriptionManager.isSubscribed {
                            dismiss()
                        }
                    } catch {
                        errorMessage = error.localizedDescription
                        showError = true
                    }
                }
            } label: {
                if subscriptionManager.isLoading {
                    ProgressView()
                } else {
                    Text("\(subscriptionManager.trialText) • \(subscriptionManager.subscriptionPrice)/year")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .disabled(subscriptionManager.isLoading)
            
            Button("Restore Purchases") {
                Task {
                    await subscriptionManager.restorePurchases()
                }
            }
            .font(.caption)
        }
        .padding()
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
} 