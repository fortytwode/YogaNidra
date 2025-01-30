import SwiftUI

struct PaywallView: View {
    @EnvironmentObject private var storeManager: StoreManager
    @EnvironmentObject private var onboardingManager: OnboardingManager
    @Environment(\.openURL) private var openURL
    @Environment(\.dismiss) private var dismiss
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 24) {
            // Close button
            HStack {
                Spacer()
                Button {
                    withAnimation {
                        onboardingManager.isOnboardingCompleted = true
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
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
                            try await storeManager.purchase(duringOnboarinng: true)
                        } catch {
                            errorMessage = error.localizedDescription
                            showError = true
                        }
                    }
                } label: {
                    VStack(spacing: 4) {
                        Text("Start free trial")
                            .font(.headline)
                        Text("Then \(storeManager.subscriptionPrice)/year")
                            .font(.subheadline)
                            .foregroundColor(.black.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(.white)
                    .foregroundColor(.black)
                    .cornerRadius(16)
                }
                
                Button {
                    Task {
                        do {
                            try await storeManager.restorePurchases(duringOnboarinng: true)
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
                
                HStack(spacing: 24) {
                    Button {
                        openURL(URL(string: "http://rocketshiphq.com/yoga-nidra-terms")!)
                    } label: {
                        Text("Terms")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.8))
                            .underline()
                    }
                    
                    Button {
                        openURL(URL(string: "http://rocketshiphq.com/yoga-nidra-privacy")!)
                    } label: {
                        Text("Privacy Policy")
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.8))
                            .underline()
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .padding()
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
            Button("OK") {}
        } message: {
            Text(errorMessage)
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
