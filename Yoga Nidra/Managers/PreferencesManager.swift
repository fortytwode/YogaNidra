import Foundation
import SwiftUI

class PreferencesManager: ObservableObject {
    @Published var preferences: UserPreferences {
        didSet {
            save()
        }
    }
    
    static let shared = PreferencesManager()
    
    @AppStorage("sleepDuration") private var sleepDuration: String = ""
    
    private init() {
        if let data = UserDefaults.standard.data(forKey: "preferences"),
           let preferences = try? JSONDecoder().decode(UserPreferences.self, from: data) {
            self.preferences = preferences
        } else {
            self.preferences = UserPreferences()
        }
    }
    
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
    
    func updateMainGoal(_ goal: String) {
        preferences.mainGoal = goal
        save()
    }
    
    func updateSleepFeelings(_ feeling: String) {
        preferences.sleepFeelings = feeling
        save()
    }
    
    func updateRelaxationObstacle(_ obstacle: String) {
        preferences.relaxationObstacle = obstacle
        save()
    }
    
    func updateSleepQuality(_ quality: String) {
        preferences.sleepQuality = quality
        save()
    }
    
    func updateFallAsleepTime(_ time: String) {
        preferences.fallAsleepTime = time
        save()
    }
    
    func updateSleepDuration(_ duration: String) {
        sleepDuration = duration
        preferences.sleepDuration = duration
        save()
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(encoded, forKey: "preferences")
        }
    }
} 