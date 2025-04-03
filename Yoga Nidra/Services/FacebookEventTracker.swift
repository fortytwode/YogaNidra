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
    // Singleton with preview support
    static let shared: FacebookEventTracker = {
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return FacebookEventTracker(isPreview: true)
        }
        #endif
        return FacebookEventTracker()
    }()
    
    // Preview support for SwiftUI
    static var preview: FacebookEventTracker {
        return FacebookEventTracker(isPreview: true)
    }
    
    // Preview mode flag
    private let isPreview: Bool
    
    private init(isPreview: Bool = false) {
        self.isPreview = isPreview
    }
    
    // MARK: - Core Events
    
    /// Track when user completes onboarding
    func trackOnboardingCompleted() {
        // Skip SDK calls in preview mode
        guard !isPreview else {
            print("📱 [PREVIEW] FB Event: Onboarding completed")
            return
        }
        
        // Use a custom event name with no parameters for simplicity
        AppEvents.shared.logEvent(AppEvents.Name("onboarding_completed"))
        print("FB Event: Onboarding completed")
    }
    
    /// Track when user starts a free trial
    func trackTrialStarted(planName: String? = nil) {
        // Skip SDK calls in preview mode
        guard !isPreview else {
            print("📱 [PREVIEW] FB Event: Trial started with plan: \(planName ?? "default")")
            return
        }
        
        // Use the standard start trial event
        AppEvents.shared.logEvent(AppEvents.Name("fb_mobile_start_trial"))
        print("FB Event: Trial started with plan: \(planName ?? "default")")
    }
    
    /// Track when user completes their first meditation
    func trackFirstMeditationCompleted(meditationId: String, durationMinutes: Int) {
        // Skip SDK calls in preview mode
        guard !isPreview else {
            print("📱 [PREVIEW] FB Event: First meditation completed - ID: \(meditationId), Duration: \(durationMinutes) minutes")
            return
        }
        
        // Use a custom event name with no parameters for simplicity
        AppEvents.shared.logEvent(AppEvents.Name("first_meditation_completed"))
        print("FB Event: First meditation completed - ID: \(meditationId), Duration: \(durationMinutes) minutes")
    }
    
    /// Track custom event with optional parameters
    func trackCustomEvent(name: String, parameters: [String: Any]? = nil) {
        // Skip SDK calls in preview mode
        guard !isPreview else {
            print("📱 [PREVIEW] FB Event: \(name) with parameters: \(parameters ?? [:])")
            return
        }
        
        // Convert parameters to AppEvents.ParameterName dictionary
        var eventParams: [AppEvents.ParameterName: Any] = [:]
        
        if let params = parameters {
            for (key, value) in params {
                eventParams[AppEvents.ParameterName(key)] = value
            }
        }
        
        // Log the event
        if !eventParams.isEmpty {
            AppEvents.shared.logEvent(AppEvents.Name(name), parameters: eventParams)
        } else {
            AppEvents.shared.logEvent(AppEvents.Name(name))
        }
        
        print("FB Event: \(name) with parameters: \(parameters ?? [:])")
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
