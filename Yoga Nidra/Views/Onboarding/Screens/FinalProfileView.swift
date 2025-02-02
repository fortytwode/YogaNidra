import SwiftUI

struct FinalProfileView: View {
    @StateObject private var preferencesManager = PreferencesManager.shared
    @StateObject private var onboardingManager = OnboardingManager.shared
    @Environment(\.dismiss) private var dismiss
    let nextPage: () -> Void
    
    private var sleepMetrics: [SleepMetric] {
        [
            SleepMetric(name: "Sleep Quality", value: calculateSleepQuality()),
            SleepMetric(name: "Relaxation", value: calculateRelaxationScore()),
            SleepMetric(name: "Sleep Pattern", value: calculateSleepPatternScore()),
            SleepMetric(name: "Energy", value: calculateEnergyScore()),
            SleepMetric(name: "Focus", value: calculateFocusScore())
        ]
    }
    
    private var highlights: [(title: String, value: Int, description: String)] {
        let sortedMetrics = sleepMetrics.sorted { $0.value > $1.value }
        let topMetric = sortedMetrics.first!
        let bottomMetric = sortedMetrics.last!
        
        return [
            (
                title: "Strength",
                value: Int(topMetric.value * 100),
                description: getStrengthDescription(for: topMetric.name)
            ),
            (
                title: "Growth area",
                value: Int(bottomMetric.value * 100),
                description: getGrowthDescription(for: bottomMetric.name)
            )
        ]
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                Text("Your Sleep Profile")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                
                // Radar Chart
                RadarChart(metrics: sleepMetrics)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                
                // Highlights Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Here are your highlights:")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                    
                    VStack(spacing: 12) {
                        ForEach(highlights, id: \.title) { highlight in
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(highlight.title)
                                        .font(.title3)
                                        .foregroundColor(.purple)
                                    Text(highlight.description)
                                        .font(.body)
                                        .foregroundColor(.white.opacity(0.7))
                                        .fixedSize(horizontal: false, vertical: true)
                                        .lineLimit(2)
                                }
                                Spacer()
                                Text("\(highlight.value)%")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(Color(red: 0.8, green: 0.2, blue: 0.2).opacity(0.6))
                                    .cornerRadius(8)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }
        }
        .padding()
        .safeAreaInset(edge: .bottom) {
            // Next Step Button
            Button(action: nextPage) {
                HStack {
                    Text("Next step")
                        .font(.headline)
                    Image(systemName: "arrow.right")
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(Color.black.opacity(0.3))
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
    
    private func getStrengthDescription(for metric: String) -> String {
        switch metric {
        case "Sleep Quality": return "You're maintaining good sleep habits!"
        case "Relaxation": return "You have a good foundation for relaxation"
        case "Energy": return "Your energy levels are well maintained"
        case "Focus": return "You're maintaining good mental focus"
        case "Sleep Pattern": return "You have a consistent sleep pattern"
        default: return "You're doing well in this area"
        }
    }
    
    private func getGrowthDescription(for metric: String) -> String {
        switch metric {
        case "Sleep Quality": return "We'll help you improve your sleep quality"
        case "Relaxation": return "Let's work on better relaxation techniques"
        case "Energy": return "We'll help boost your energy levels"
        case "Focus": return "We'll help enhance your mental focus"
        case "Sleep Pattern": return "We'll help stabilize your sleep pattern"
        default: return "We'll help you improve in this area"
        }
    }
    
    private func metricRow(icon: String, title: String, highlight: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white)
            Text(title)
                .foregroundColor(.white)
            Spacer()
            Text(highlight)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color(white: 0.3))
                .cornerRadius(8)
        }
    }
    
    private func calculateSleepQuality() -> Double {
        let quality: Double
        switch preferencesManager.preferences.sleepQuality {
            case "Excellent": quality = 0.9
            case "Good": quality = 0.75
            case "Fair": quality = 0.6
            case "Poor": quality = 0.4
            default: quality = 0.5
        }
        return quality
    }
    
    private func calculateRelaxationScore() -> Double {
        let score: Double
        switch preferencesManager.preferences.relaxationObstacle {
            case "Racing thoughts": score = 0.6
            case "Physical tension": score = 0.65
            case "Environmental noise": score = 0.75
            case "Time management": score = 0.7
            default: score = 0.65
        }
        return score
    }
    
    private func calculateSleepPatternScore() -> Double {
        let score: Double
        switch preferencesManager.preferences.nightWakeups {
            case "Rarely": score = 0.85
            case "Sometimes": score = 0.7
            case "Often": score = 0.5
            case "Every night": score = 0.3
            default: score = 0.5
        }
        return score
    }
    
    private func calculateEnergyScore() -> Double {
        let score: Double
        switch preferencesManager.preferences.sleepFeelings {
            case "Completely drained": score = 0.4
            case "Irritable": score = 0.5
            case "Can't focus": score = 0.6
            case "Low energy": score = 0.55
            default: score = 0.5
        }
        
        // Adjust based on morning tiredness
        if preferencesManager.preferences.morningTiredness == "Very tired" {
            return score * 0.8
        } else if preferencesManager.preferences.morningTiredness == "Somewhat tired" {
            return score * 0.9
        }
        return score
    }
    
    private func calculateFocusScore() -> Double {
        let baseScore: Double
        switch preferencesManager.preferences.sleepFeelings {
            case "Can't focus": baseScore = 0.5
            case "Completely drained": baseScore = 0.6
            case "Irritable": baseScore = 0.7
            case "Low energy": baseScore = 0.75
            default: baseScore = 0.65
        }
        
        // Adjust based on sleep impact
        let impactMultiplier: Double
        switch preferencesManager.preferences.sleepImpact {
            case "Work performance": impactMultiplier = 0.85
            case "Mental clarity": impactMultiplier = 0.9
            case "Physical energy": impactMultiplier = 0.95
            case "Emotional balance": impactMultiplier = 1.0
            default: impactMultiplier = 0.9
        }
        
        return baseScore * impactMultiplier
    }
}

struct FinalProfileView_Previews: PreviewProvider {
    static var previews: some View {
        FinalProfileView(nextPage: {})
    }
}
