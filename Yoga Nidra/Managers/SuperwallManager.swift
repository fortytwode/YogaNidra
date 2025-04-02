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
import FirebaseAnalytics

// Import the Entitlement type
typealias Entitlement = SuperwallKit.Entitlement

class SuperwallManager {
    // Singleton
    static let shared = SuperwallManager()
    
    // Notification name for paywall presentation failures
    static let presentationFailedNotification = Notification.Name("SuperwallPresentationFailed")
    
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
    
    // Enhanced method to show a paywall with error handling
    func showPaywallWithErrorHandling() {
        let handler = PaywallPresentationHandler()
        
        // Handle presentation errors - using the method (not property assignment)
        handler.onError { error in
            print("Superwall presentation error: \(error.localizedDescription)")
            
            // Log to Firebase Analytics directly
            Analytics.logEvent("superwall_presentation_error", parameters: [
                "error": error.localizedDescription
            ])
            
            // Notify observers about the failure
            NotificationCenter.default.post(
                name: SuperwallManager.presentationFailedNotification,
                object: nil
            )
        }
        
        // Register the placement with the handler
        Superwall.shared.register(
            placement: "show_paywall",
            params: nil,
            handler: handler
        )
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
    
    // Update subscription status in Superwall
    func updateSubscriptionStatus(isSubscribed: Bool) {
        if isSubscribed {
            // Create an empty Set of Entitlement
            let entitlements: Set<Entitlement> = [Entitlement(id: "premium")]
            Superwall.shared.subscriptionStatus = .active(entitlements)
        } else {
            Superwall.shared.subscriptionStatus = .inactive
        }
    }
    
    // Set user attributes for better targeting
    func setUserAttributes(_ attributes: [String: Any]) {
        Superwall.shared.setUserAttributes(attributes)
    }
    
    // Convenience method for updating common user attributes
    func updateUserProfile(
        userLevel: Int,
        meditationCount: Int,
        favoriteCategory: String?,
        lastActiveDate: Date
    ) {
        let daysSinceActive = Calendar.current.dateComponents([.day], from: lastActiveDate, to: Date()).day ?? 0
        
        let attributes: [String: Any] = [
            "user_level": userLevel,
            "meditation_count": meditationCount,
            "favorite_category": favoriteCategory ?? "",
            "days_since_last_active": daysSinceActive
        ]
        
        setUserAttributes(attributes)
    }
}
