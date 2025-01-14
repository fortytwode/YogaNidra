import SwiftUI

struct PaywallView: View {
    @EnvironmentObject private var storeManager: StoreManager
    @EnvironmentObject private var onboardingManager: OnboardingManager
    @Environment(\.dismiss) private var dismiss
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Spacer()
                Button {
                    onboardingManager.isOnboardingCompleted = true
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            
            VStack(spacing: 8) {
                Text("Start Your Journey")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Transform your sleep with Yoga Nidra")
                    .font(.title3)
            }
            .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 20) {
                BenefitRow(icon: "infinity", 
                          title: "Unlimited Access to All Sessions",
                          description: "Access our complete meditation library")
                
                BenefitRow(icon: "square.grid.2x2", 
                          title: "Sessions for Every Situation",
                          description: "For your sleep needs around nighttimes, naps, stress, travel, anxiety, and more")
                
                BenefitRow(icon: "arrow.down.circle", 
                          title: "Download & Listen Offline",
                          description: "Take your practice anywhere, no connection needed")
                
                BenefitRow(icon: "person.2", 
                          title: "Multiple Instructor Options",
                          description: "Choose from different expert guides for your practice")
            }
            .padding(.vertical, 24)
            
            Spacer()
            
            VStack(spacing: 16) {
                Button {
                    Task {
                        do {
                            try await storeManager.purchase()
                        } catch {
                            errorMessage = error.localizedDescription
                            showError = true
                        }
                    }
                } label: {
                    Text("Start free trial")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(.white)
                        .foregroundColor(.black)
                        .cornerRadius(16)
                }
                
                Button {
                    Task {
                        do {
                            try await storeManager.restorePurchases()
                        } catch {
                            errorMessage = error.localizedDescription
                            showError = true
                        }
                    }
                } label: {
                    Text("Restore purchases")
                        .font(.title3)
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(
            ZStack {
                Image("mountain-lake-twilight")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.3),
                        Color.black.opacity(0.7)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
        )
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onChange(of: storeManager.isSubscribed) { _, newValue in
            if newValue {
                onboardingManager.isOnboardingCompleted = true
                dismiss()
            }
        }
    }
}

struct BenefitRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .frame(width: 32, height: 32)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    PaywallView()
        .environmentObject(StoreManager.shared)
        .environmentObject(OnboardingManager.shared)
}
