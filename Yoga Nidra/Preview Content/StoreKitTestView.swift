import SwiftUI

struct StoreKitTestView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    var body: some View {
        VStack(spacing: 20) {
            // Status
            Text("Trial Active: \(subscriptionManager.isInTrialPeriod ? "Yes" : "No")")
            Text("Subscribed: \(subscriptionManager.isSubscribed ? "Yes" : "No")")
            
            // Test button
            Button("Start Trial") {
                Task {
                    await subscriptionManager.purchase()
                }
            }
        }
        .padding()
    }
} 