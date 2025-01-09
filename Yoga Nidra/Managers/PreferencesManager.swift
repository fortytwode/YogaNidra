import Foundation

class PreferencesManager: ObservableObject {
    static let shared = PreferencesManager()
    
    @Published var preferences: UserPreferences {
        didSet {
            save()
        }
    }
    
    private init() {
        // Load saved preferences or use default
        if let data = UserDefaults.standard.data(forKey: "userPreferences"),
           let decoded = try? JSONDecoder().decode(UserPreferences.self, from: data) {
            self.preferences = decoded
        } else {
            self.preferences = .default
        }
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(encoded, forKey: "userPreferences")
        }
    }
    
    // Helper methods for updating preferences
    func updateSleepQuality(_ quality: String) {
        preferences.sleepQuality = quality
    }
    
    func updateFallAsleepTime(_ time: String) {
        preferences.fallAsleepTime = time
    }
    
    func updateNightWakeups(_ frequency: String) {
        preferences.nightWakeups = frequency
    }
    
    func updateMorningTiredness(_ frequency: String) {
        preferences.morningTiredness = frequency
    }
    
    func updateSleepImpact(_ impact: String) {
        preferences.sleepImpact = impact
    }
    
    func completeOnboarding() {
        preferences.onboardingCompleted = Date()
    }
    
    // Helper method to get personalized recommendations
    func getPersonalizedRecommendations() -> (session: String, time: String, frequency: String) {
        // Logic to determine recommendations based on answers
        let session = preferences.fallAsleepTime == "Over an hour" ? 
            "Deep Sleep Yoga Nidra • 30 min" : "Deep Sleep Yoga Nidra • 20 min"
            
        let time = preferences.nightWakeups == "Often" || preferences.nightWakeups == "Every night" ?
            "45-60 minutes before bed" : "30-45 minutes before bed"
            
        let frequency = preferences.sleepImpact == "Significantly" ?
            "4-5 sessions" : "3-4 sessions"
            
        return (session, time, frequency)
    }
} 