import SwiftUI

struct StoreKitTestView: View {
    @StateObject private var storeManager = StoreManager.shared
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // Status
            Text("Trial Active: \(storeManager.isInTrialPeriod ? "Yes" : "No")")
            Text("Subscribed: \(storeManager.isSubscribed ? "Yes" : "No")")
            
            // Test button
            Button("Start Trial") {
                Task {
                    do {
                        try await storeManager.purchase()
                    } catch {
                        errorMessage = error.localizedDescription
                        showError = true
                    }
                }
            }
        }
        .padding()
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
} 