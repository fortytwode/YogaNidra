import SwiftUI

struct HomeView: View {
    @StateObject private var preferencesManager = PreferencesManager.shared
    @Binding var selectedTab: Int
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Personalized greeting
                    welcomeSection
                    
                    // Recommended session
                    if let recommendedSession = getRecommendedSession() {
                        RecommendedSessionCard(session: recommendedSession)
                    }
                    
                    // Rest of your home view content...
                }
                .padding()
            }
            .navigationTitle("Home")
        }
    }
    
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(getWelcomeMessage())
                .font(.title)
                .bold()
            
            Text(getPersonalizedSubtitle())
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
    
    private func getWelcomeMessage() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }
    
    private func getPersonalizedSubtitle() -> String {
        if let impact = preferencesManager.preferences.sleepImpact {
            switch impact {
            case "Significantly":
                return "Let's work on improving your sleep quality"
            case "Moderately":
                return "Ready for better sleep tonight?"
            default:
                return "Time for your daily practice"
            }
        }
        return "Welcome to Yoga Nidra"
    }
    
    private func getRecommendedSession() -> Session? {
        let recommendations = preferencesManager.getPersonalizedRecommendations()
        
        // Create session based on user preferences
        let session = Session(
            title: recommendations.session,
            duration: 1200, // 20 minutes
            description: "Personalized deep sleep meditation",
            thumbnailUrl: "your_thumbnail_url",
            audioUrl: "your_audio_url",
            isPremium: true,
            category: .deepSleep,
            tags: [
                preferencesManager.preferences.fallAsleepTime == "Over an hour" ? .fallAsleep : .stayAsleep,
                .beginnerFriendly
            ]
        )
        
        return session
    }
}
