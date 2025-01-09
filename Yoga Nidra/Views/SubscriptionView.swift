import SwiftUI

struct SubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    
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
                Text("\(subscriptionManager.trialText) • \(subscriptionManager.subscriptionPrice)/year")
                    .font(.headline)
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
        .onAppear {
            Task {
                // Force a product refresh when view appears
                await subscriptionManager.setupProducts()
                subscriptionManager.verifySetup()
            }
        }
    }
} 