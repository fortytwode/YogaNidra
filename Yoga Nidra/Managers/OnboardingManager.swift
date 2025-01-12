//
//  OnboardingManager.swift
//  Yoga Nidra
//
//  Created by Nishchal Visavadiya on 12/01/25.
//

import Foundation

@MainActor
final class OnboardingManager: ObservableObject {
    
    static let shared = OnboardingManager()
    
    @Published
    var shouldShowOnboarding: Bool
    
    var isOnboardingCompleted: Bool {
        didSet {
            UserDefaults.standard.set(isOnboardingCompleted, forKey: "isOnboardingCompleted")
            shouldShowOnboarding = !isOnboardingCompleted
        }
    }
    
    private init() {
        isOnboardingCompleted = UserDefaults.standard.bool(forKey: "isOnboardingCompleted")
        shouldShowOnboarding = !isOnboardingCompleted
    }
}
