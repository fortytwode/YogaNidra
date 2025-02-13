import SwiftUI

struct PremiumContentSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var storeManager = StoreManager.shared
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 24) {
            // Premium Icon
            Image(systemName: "lock.fill")
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
                FeatureRowView(text: "Access all premium sessions")
                FeatureRowView(text: "New content monthly")
                FeatureRowView(text: "Background playback")
                FeatureRowView(text: "Download for offline use")
            }
            
            Spacer()
            
            // Subscribe Button
            Button {
                Task {
                    do {
                        try await storeManager.purchase()
                        if storeManager.isSubscribed {
                            dismiss()
                        }
                    } catch {
                        errorMessage = error.localizedDescription
                        showError = true
                    }
                }
            } label: {
                if storeManager.isLoading {
                    ProgressView()
                } else {
                    Text("Start 7-day free trial • $59.99/year")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
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
        }
        .padding()
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
}

struct PremiumContentSheet_Previews: PreviewProvider {
    static var previews: some View {
        PremiumContentSheet()
            .environmentObject(StoreManager.shared)
    }
}