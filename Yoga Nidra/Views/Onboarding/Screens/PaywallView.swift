import SwiftUI

struct PaywallView: View {
    @EnvironmentObject private var storeManager: StoreManager
    @EnvironmentObject private var onboardingManager: OnboardingManager
    @Environment(\.openURL) private var openURL
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 32) {
            // Main Content
            VStack(spacing: 32) {
                // Headline
                Text("Transform Your Sleep. NOW.")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
                    .padding(.top, 48)
                
                // Benefits
                VStack(alignment: .leading, spacing: 16) {
                    BenefitRow(icon: "moon.stars", 
                              title: "Reduce time to fall asleep with guided Yoga Nidra")
                    
                    BenefitRow(icon: "waveform.path", 
                              title: "Increase deep sleep through proven relaxation techniques")
                    
                    BenefitRow(icon: "heart.fill", 
                              title: "Lower stress and anxiety with regular practice")
                }
                .padding(.horizontal)
                
                // Research Stats
                VStack(spacing: 16) {
                    Text("Scientifically Proven Results")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        StatRow(emoji: "🌙", text: "84% reduction in insomnia symptoms")
                        StatRow(emoji: "✨", text: "Significant increase in deep sleep phases")
                        StatRow(emoji: "⏰", text: "30-minute average decrease in sleep onset time")
                    }
                }
                .padding(20)
                .background(Color.white.opacity(0.1))
                .cornerRadius(16)
                .padding(.horizontal)
            }
            
            Spacer()
            
            // Bottom Section
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("7-Day Free Trial")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Then $59.99/year")
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Button {
                    Task {
                        do {
                            try await storeManager.purchase(duringOnboarinng: true)
                            withAnimation {
                                onboardingManager.isOnboardingCompleted = true
                            }
                        } catch {
                            showError = true
                            errorMessage = error.localizedDescription
                        }
                    }
                } label: {
                    Text("Start Free Trial")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(.white)
                        .cornerRadius(28)
                }
                .padding(.horizontal)
                
                Button {
                    Task {
                        do {
                            try await storeManager.restorePurchases()
                            withAnimation {
                                onboardingManager.isOnboardingCompleted = true
                            }
                        } catch {
                            showError = true
                            errorMessage = error.localizedDescription
                        }
                    }
                } label: {
                    Text("Restore Purchases")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 12)
                
                if let date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) {
                    Text("Cancel anytime before \(date.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
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
                .padding(.top, 8)
            }
            .padding(.bottom, 16)
        }
        .alert("Purchase Failed", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .background(
            ZStack {
                Image("mountain-lake-twilight")
                    .resizable()
                    .scaledToFill()
                    .overlay(Color.black.opacity(0.4))
                    .edgesIgnoringSafeArea(.all)
                
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.3)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
            }
        )
    }
}

struct BenefitRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .frame(width: 32, alignment: .center)
                .foregroundColor(.white)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(nil)
        }
    }
}

struct StatRow: View {
    let emoji: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(emoji)
                .font(.title2)
                .frame(width: 32, alignment: .center)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(nil)
            
            Spacer()
        }
    }
}

#if DEBUG
struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PaywallView()
                .environmentObject(StoreManager.preview)
                .environmentObject(OnboardingManager.preview)
            
            PaywallView()
                .environmentObject(StoreManager.preview)
                .environmentObject(OnboardingManager.preview)
                .previewDevice("iPhone SE (3rd generation)")
                .previewDisplayName("iPhone SE")
        }
    }
}
#endif
