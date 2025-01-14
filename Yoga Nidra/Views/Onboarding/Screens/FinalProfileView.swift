import SwiftUI

struct FinalProfileView: View {
    @StateObject private var preferencesManager = PreferencesManager.shared
    @StateObject private var onboardingManager = OnboardingManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 32) {
            Text("Your Sleep Profile")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.top, 40)
            
            VStack(spacing: 24) {
                metricRow(
                    icon: "moon.stars.fill",
                    title: "Sleep Quality",
                    highlight: "\(Int(calculateSleepQuality() * 100))%"
                )
                
                metricRow(
                    icon: "bed.double.fill",
                    title: "Sleep Duration",
                    highlight: preferencesManager.preferences.sleepDuration
                )
                
                metricRow(
                    icon: "clock.fill",
                    title: "Fall Asleep Time",
                    highlight: preferencesManager.preferences.fallAsleepTime
                )
            }
            .padding(24)
            .background(Color(white: 0.2))
            .cornerRadius(16)
            .padding(.horizontal, 24)
            
            VStack(spacing: 16) {
                Text("Ready to transform your sleep?")
                    .font(.title3)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Start your free trial to access personalized sessions and track your progress.")
                    .font(.body)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            VStack(spacing: 16) {
                Button(action: startFreeTrial) {
                    Text("Start Free Trial")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }
                
                Button {
                    onboardingManager.isOnboardingCompleted = true
                    dismiss()
                } label: {
                    Text("Maybe Later")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(white: 0.2))
                        .cornerRadius(10)
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
                
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.3),
                        Color.black.opacity(0.5)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .ignoresSafeArea()
        )
    }
    
    private func metricRow(icon: String, title: String, highlight: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Text(highlight)
                    .font(.body)
                    .foregroundColor(.white)
            }
        }
    }
    
    private func startFreeTrial() {
        // Show paywall sheet
        let storeManager = StoreManager.shared
        Task {
            do {
                try await storeManager.purchase(duringOnboarinng: true)
                if storeManager.isSubscribed {
                    dismiss()
                }
            } catch {
                // Handle error
                print("Purchase error: \(error.localizedDescription)")
            }
        }
    }
    
    // Existing calculation methods remain unchanged
    private func calculateSleepQuality() -> Double {
        let quality: Double
        switch preferencesManager.preferences.fallAsleepTime {
            case "Less than 15 minutes": quality = 0.9
            case "15-30 minutes": quality = 0.7
            case "30-60 minutes": quality = 0.5
            case "Over an hour": quality = 0.3
            default: quality = 0.5
        }
        
        let wakeupAdjustment: Double
        switch preferencesManager.preferences.nightWakeups {
            case "Never": wakeupAdjustment = 0.2
            case "Sometimes": wakeupAdjustment = 0.1
            case "Often": wakeupAdjustment = -0.1
            case "Every night": wakeupAdjustment = -0.2
            default: wakeupAdjustment = 0
        }
        
        return min(max(quality + wakeupAdjustment, 0), 1)
    }
} 