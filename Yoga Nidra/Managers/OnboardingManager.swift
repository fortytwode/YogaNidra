//
//  OnboardingManager.swift
//  Yoga Nidra
//
//  Created by Nishchal Visavadiya on 12/01/25.
//

import Foundation
import Combine
import FBSDKCoreKit

@MainActor
final class OnboardingManager: ObservableObject {
    
    static let shared = OnboardingManager()
    
    @Published
    var shouldShowOnboarding: Bool
    
    // Track current onboarding page to prevent premature completion
    @Published var currentOnboardingPage: Int?
    
    // Add Google Auth presentation flag
    @Published var shouldShowGoogleAuth = false
    
    @Published var isOnboardingCompleted: Bool {
        didSet {
            UserDefaults.standard.set(isOnboardingCompleted, forKey: "isOnboardingCompleted")
            shouldShowOnboarding = !isOnboardingCompleted
            if isOnboardingCompleted {
                // Track onboarding completed event with Facebook
                trackOnboardingCompleted()
                // Explicitly set the tab to home and persist it
                AppState.shared.selectedTab = .home
                // Show Google Auth after onboarding
                self.shouldShowGoogleAuth = true
            }
        }
    }
    
    private init() {
        let isOnboardingCompleted = UserDefaults.standard.bool(forKey: "isOnboardingCompleted")
        self.isOnboardingCompleted = isOnboardingCompleted
        self.shouldShowOnboarding = !isOnboardingCompleted
    }
    
    // Track onboarding completed event
    private func trackOnboardingCompleted() {
        // Use our FacebookEventTracker service to track the event
        Task {
            await MainActor.run {
                FacebookEventTracker.shared.trackOnboardingCompleted()
                SuperwallManager.shared.trackEvent("onboarding_completed")
            }
        }
    }
}

#if DEBUG
extension OnboardingManager {
    static var preview: OnboardingManager {
        let manager = OnboardingManager.shared
        return manager
    }
}
#endif
