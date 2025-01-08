import SwiftUI

struct SubscriptionView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("Unlock Premium")
                .font(.title)
                .bold()
            
            // Features
            VStack(alignment: .leading, spacing: 12) {
                FeatureRow("Access all meditation sessions")
                FeatureRow("New content added monthly")
                FeatureRow("Background playback")
                FeatureRow("Download for offline use")
            }
            .padding(.vertical)
            
            Spacer()
            
            // Subscription Button
            Button {
                Task {
                    await subscriptionManager.purchase()
                }
            } label: {
                VStack(spacing: 4) {
                    Text(subscriptionManager.trialText)
                        .font(.subheadline)
                    Text("\(subscriptionManager.subscriptionPrice) / year")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(subscriptionManager.isLoading)
            
            Button("Restore Purchases") {
                Task {
                    await subscriptionManager.restorePurchases()
                }
            }
            .font(.caption)
            
            // Terms
            Text("Cancel anytime. Terms apply.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .overlay(
            subscriptionManager.isLoading ? ProgressView() : nil
        )
        .alert("Error", isPresented: $subscriptionManager.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(subscriptionManager.errorMessage ?? "Unknown error occurred")
        }
        .onChange(of: subscriptionManager.isSubscribed) { subscribed in
            if subscribed {
                dismiss()
            }
        }
    }
}

private struct FeatureRow: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text(text)
        }
    }
} 