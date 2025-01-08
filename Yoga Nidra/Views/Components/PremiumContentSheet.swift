import SwiftUI

struct PremiumContentSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
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
                    try? await subscriptionManager.purchase()
                }
            } label: {
                Text("\(subscriptionManager.trialText) \(subscriptionManager.subscriptionPrice)/year")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            
            Button("Restore Purchases") {
                // Add restore functionality
            }
            .font(.caption)
        }
        .padding()
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