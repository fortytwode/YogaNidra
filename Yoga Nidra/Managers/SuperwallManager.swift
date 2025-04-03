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
    // Singleton with preview support
    static let shared: SuperwallManager = {
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return SuperwallManager(isPreview: true)
        }
        #endif
        return SuperwallManager()
    }()
    
    // Notification name for paywall presentation failures
    static let presentationFailedNotification = Notification.Name("SuperwallPresentationFailed")
    
    // Preview mode flag
    private let isPreview: Bool
    
    // Preview support for SwiftUI
    static var preview: SuperwallManager {
        return SuperwallManager(isPreview: true)
    }
    
    private init(isPreview: Bool = false) {
        self.isPreview = isPreview
        // Nothing complex needed here
    }
    
    // Simple method to show a paywall
    func showPaywall() {
        // Skip SDK calls in preview mode
        guard !isPreview else {
            // Simulate success in preview mode
            print("📱 [PREVIEW] Showing paywall")
            return
        }
        
        // Just register the placement without any complex handlers
        Superwall.shared.register(placement: "show_paywall")
        
        // Track paywall view with Facebook
        AppEvents.shared.logEvent(AppEvents.Name("paywall_viewed"))
    }
    
    // Enhanced method to show a paywall with error handling
    func showPaywallWithErrorHandling() {
        // Skip SDK calls in preview mode
        guard !isPreview else {
            // Simulate success in preview mode
            print("📱 [PREVIEW] Showing paywall with error handling")
            return
        }
        
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
        // Skip SDK calls in preview mode
        guard !isPreview else {
            print("📱 [PREVIEW] Tracking event: \(eventName)")
            return
        }
        
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
        // Skip SDK calls in preview mode
        guard !isPreview else {
            print("📱 [PREVIEW] Trial started")
            return
        }
        
        // Track in Facebook using the standard event name
        AppEvents.shared.logEvent(AppEvents.Name("fb_mobile_start_trial"))
    }
    
    // Identify user to both Superwall and RevenueCat
    func identifyUser(userId: String) {
        // Skip SDK calls in preview mode
        guard !isPreview else {
            print("📱 [PREVIEW] Identifying user: \(userId)")
            return
        }
        
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
        // Skip SDK calls in preview mode
        guard !isPreview else {
            print("📱 [PREVIEW] Updating subscription status: \(isSubscribed)")
            return
        }
        
        if isSubscribed {
            // Create a Set of Entitlement with proper namespace
            let entitlements: Set<SuperwallKit.Entitlement> = [SuperwallKit.Entitlement(id: "premium")]
            Superwall.shared.subscriptionStatus = .active(entitlements)
        } else {
            Superwall.shared.subscriptionStatus = .inactive
        }
    }
    
    // Set user attributes for better targeting
    func setUserAttributes(_ attributes: [String: Any]) {
        // Skip SDK calls in preview mode
        guard !isPreview else {
            print("📱 [PREVIEW] Setting user attributes: \(attributes)")
            return
        }
        
        Superwall.shared.setUserAttributes(attributes)
    }
    
    // Convenience method for updating common user attributes
    func updateUserProfile(
        userLevel: Int,
        meditationCount: Int,
        favoriteCategory: String?,
        lastActiveDate: Date
    ) {
        // Skip SDK calls in preview mode
        guard !isPreview else {
            print("📱 [PREVIEW] Updating user profile")
            return
        }
        
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
