//
//  FacebookEventTracker.swift
//  Yoga Nidra
//
//  Created on 02/04/25.
//

import Foundation
import FBSDKCoreKit

/// Service class for tracking Facebook events throughout the app
class FacebookEventTracker {
    static let shared = FacebookEventTracker()
    
    private init() {}
    
    // MARK: - Core Events
    
    /// Track when user completes onboarding
    func trackOnboardingCompleted() {
        // Use a custom event name with no parameters for simplicity
        AppEvents.shared.logEvent(AppEvents.Name("onboarding_completed"))
        print("FB Event: Onboarding completed")
    }
    
    /// Track when user starts a free trial
    func trackTrialStarted(planName: String? = nil) {
        // Use the standard start trial event
        AppEvents.shared.logEvent(AppEvents.Name("fb_mobile_start_trial"))
        print("FB Event: Trial started with plan: \(planName ?? "default")")
    }
    
    /// Track when user completes their first meditation
    func trackFirstMeditationCompleted(meditationId: String, durationMinutes: Int) {
        // Use a custom event name with no parameters for simplicity
        AppEvents.shared.logEvent(AppEvents.Name("first_meditation_completed"))
        print("FB Event: First meditation completed - ID: \(meditationId), Duration: \(durationMinutes) minutes")
    }
    
    // MARK: - Helper Methods
    
    /// Check if this is the first time calling an event
    private func isFirstOccurrence(for eventKey: String) -> Bool {
        let defaults = UserDefaults.standard
        let hasOccurred = defaults.bool(forKey: eventKey)
        
        if !hasOccurred {
            defaults.set(true, forKey: eventKey)
            return true
        }
        
        return false
    }
}
