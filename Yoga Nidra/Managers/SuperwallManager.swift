//
//  SuperwallManager.swift
//  Yoga Nidra
//
//  Created on 02/04/25.
//

import Foundation
import SuperwallKit
import UIKit
import RevenueCat
import FBSDKCoreKit

class SuperwallManager {
    // Singleton
    static let shared = SuperwallManager()
    
    private init() {
        // Nothing complex needed here
    }
    
    // Simple method to show a paywall
    func showPaywall() {
        // Just register the placement without any complex handlers
        Superwall.shared.register(placement: "show_paywall")
        
        // Track paywall view with Facebook
        AppEvents.shared.logEvent(AppEvents.Name("paywall_viewed"))
    }
    
    // Track an event that might trigger a paywall
    func trackEvent(_ eventName: String) {
        // Simply register the placement
        Superwall.shared.register(placement: eventName)
        
        // Also track in Facebook for key events
        if eventName == "onboarding_completed" {
            AppEvents.shared.logEvent(AppEvents.Name("onboarding_completed"))
        } else if eventName == "first_meditation_completed" {
            AppEvents.shared.logEvent(AppEvents.Name("first_meditation_completed"))
        }
    }
    
    // Track trial started event
    func trackTrialStarted() {
        // Track in Facebook using the standard event name
        AppEvents.shared.logEvent(AppEvents.Name("fb_mobile_start_trial"))
    }
    
    // Identify user to both Superwall and RevenueCat
    func identifyUser(userId: String) {
        // Identify user in Superwall
        Superwall.shared.identify(userId: userId)
        
        // Identify user in RevenueCat (without trying to access the return value)
        Task {
            do {
                _ = try await Purchases.shared.logIn(userId)
            } catch {
                print("Failed to identify user: \(error.localizedDescription)")
            }
        }
    }
}
