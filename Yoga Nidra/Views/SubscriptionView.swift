import SwiftUI

struct SubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var storeManager = StoreManager.shared
    @StateObject private var onboardingManager = OnboardingManager.shared
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("Unlock Premium")
                .font(.title)
                .bold()
            
            // Features
            VStack(alignment: .leading, spacing: 12) {
                FeatureRowView(text: "Access all meditation sessions")
                FeatureRowView(text: "New content added monthly")
                FeatureRowView(text: "Background playback")
                FeatureRowView(text: "Download for offline use")
            }
            .padding(.vertical)
            
            Spacer()
            
            // Subscription Button
            Button {
                Task {
                    do {
                        try await storeManager.purchase()
                    } catch {
                        storeManager.errorMessage = error.localizedDescription
                        storeManager.showError = true
                    }
                }
            } label: {
                Text("Start 7-day free trial • $59.99/year")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .opacity(storeManager.isLoading ? 0.5 : 1)
            .allowsHitTesting(!storeManager.isLoading)
            
            // Restore Purchases Button
            Button {
                Task {
                    do {
                        try await storeManager.restore()
                    } catch {
                        print("❌ Failed to restore purchases: \(error)")
                    }
                }
            } label: {
                Text("Restore Purchases")
                    .foregroundColor(.blue)
            }
            .font(.caption)
            
            // Terms
            Text("Cancel anytime. Terms apply.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .alert("Error", isPresented: $storeManager.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(storeManager.errorMessage ?? "Unknown error occurred")
        }
        .onChange(of: storeManager.isSubscribed) { _, newValue in
            if newValue {
                dismiss()
            }
        }
    }
}
