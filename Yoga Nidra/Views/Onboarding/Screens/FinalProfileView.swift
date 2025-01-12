import SwiftUI

struct FinalProfileView: View {
    @AppStorage("shouldShowOnboarding") var shouldShowOnboarding = true
    @StateObject private var storeManager = StoreManager.shared
    @StateObject private var preferencesManager = PreferencesManager.shared
    @State private var isLoading = true
    @State private var showingSubscriptionSheet = false
    
    // Analysis metrics based on user answers
    var sleepMetrics: [SleepMetric] {
        [
            SleepMetric(name: "Sleep Quality", value: calculateSleepQuality()),
            SleepMetric(name: "Relaxation", value: calculateRelaxation()),
            SleepMetric(name: "Energy", value: calculateEnergy()),
            SleepMetric(name: "Mental Clarity", value: calculateMentalClarity()),
            SleepMetric(name: "Stress Level", value: calculateStressLevel())
        ]
    }
    
    var body: some View {
        VStack(spacing: 32) {
            if isLoading {
                analysisLoadingView
            } else {
                ScrollView {
                    VStack(spacing: 32) {
                        Text("Your Sleep Profile")
                            .font(.title)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        // Radar Chart
                        RadarChart(metrics: sleepMetrics)
                            .frame(height: 300)
                            .padding()
                            .background(Color(uiColor: .systemGray6))
                            .cornerRadius(16)
                        
                        // Highlights
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Here are your highlights:")
                                .font(.title3)
                                .bold()
                                .padding(.horizontal)
                            
                            ForEach(getHighlights(), id: \.self) { highlight in
                                HStack(spacing: 16) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                    Text(highlight)
                                        .font(.body)
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                        .frame(maxWidth: .infinity)
                        .background(Color(uiColor: .systemGray6))
                        .cornerRadius(16)
                        
                        // Subscription CTA
                        VStack(spacing: 16) {
                            Button {
                                showingSubscriptionSheet = true
                            } label: {
                                Text("Start your personalized journey")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.purple)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            
                            Button {
                                shouldShowOnboarding = false
                            } label: {
                                Text("Skip for now")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.top)
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            // Simulate analysis
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isLoading = false
            }
        }
        .sheet(isPresented: $showingSubscriptionSheet) {
            SubscriptionView()
        }
    }
    
    private var analysisLoadingView: some View {
        VStack(spacing: 24) {
            // Simple sleeping character emoji with animation
            Text("😴")
                .font(.system(size: 80))
                .scaleEffect(isLoading ? 1.1 : 0.9)
                .animation(
                    Animation.easeInOut(duration: 1.0)
                        .repeatForever(autoreverses: true),
                    value: isLoading
                )
            
            Text("Analyzing your answers...")
                .font(.title2)
                .bold()
            
            VStack(spacing: 16) {
                analysisProgressRow("Profile", progress: 0.8)
                analysisProgressRow("Personalization", progress: 0.5)
                analysisProgressRow("Recommendations", progress: 0.3)
            }
            .padding(24)
        }
    }
    
    private func analysisProgressRow(_ label: String, progress: Double) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .foregroundColor(.gray)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                    
                    Rectangle()
                        .fill(Color.purple)
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 4)
            .cornerRadius(2)
        }
    }
    
    private func highlightRow(_ highlight: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
            
            Text(highlight)
                .font(.body)
        }
    }
    
    // Helper functions to calculate metrics based on user answers
    private func calculateSleepQuality() -> Double {
        let quality: Double
        switch preferencesManager.preferences.fallAsleepTime {
            case "Less than 15 minutes": quality = 0.9
            case "15-30 minutes": quality = 0.7
            case "30-60 minutes": quality = 0.5
            case "Over an hour": quality = 0.3
            default: quality = 0.5
        }
        
        // Adjust for night wakeups
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
    
    private func calculateRelaxation() -> Double {
        switch preferencesManager.preferences.relaxationObstacle {
            case "Racing thoughts": return 0.4
            case "Physical tension": return 0.5
            case "Environmental noise": return 0.6
            case "Time management": return 0.7
            default: return 0.5
        }
    }
    
    private func calculateEnergy() -> Double {
        switch preferencesManager.preferences.morningTiredness {
            case "Very refreshed": return 0.9
            case "Somewhat tired": return 0.6
            case "Very tired": return 0.3
            case "Exhausted": return 0.2
            default: return 0.5
        }
    }
    
    private func calculateMentalClarity() -> Double {
        switch preferencesManager.preferences.sleepFeelings {
            case "Can't focus": return 0.3
            case "Irritable": return 0.4
            case "Low energy": return 0.5
            case "Completely drained": return 0.2
            default: return 0.5
        }
    }
    
    private func calculateStressLevel() -> Double {
        let baseStress: Double
        switch preferencesManager.preferences.sleepImpact {
            case "Significantly": baseStress = 0.8
            case "Moderately": baseStress = 0.6
            case "Slightly": baseStress = 0.4
            case "Not at all": baseStress = 0.2
            default: baseStress = 0.5
        }
        
        // Invert the stress level so higher is better (less stress)
        return 1.0 - baseStress
    }
    
    private func getHighlights() -> [String] {
        var highlights: [String] = []
        
        // Add goal-based highlight
        switch preferencesManager.preferences.mainGoal {
            case "Inner peace":
                highlights.append("You're on a journey to find inner calm and balance")
            case "Better sleep quality":
                highlights.append("Your path to restorative sleep begins here")
            case "Stress reduction":
                highlights.append("We'll help you manage stress effectively")
            case "Mental clarity":
                highlights.append("Focus and clarity are within reach")
            default:
                break
        }
        
        // Add sleep-quality based highlight
        if calculateSleepQuality() < 0.5 {
            highlights.append("We'll help you improve your sleep quality significantly")
        }
        
        // Add stress-based highlight
        if calculateStressLevel() < 0.4 {
            highlights.append("Our techniques will help reduce your stress levels")
        }
        
        return highlights
    }
}

struct SleepMetric {
    let name: String
    let value: Double // 0.0 to 1.0
} 