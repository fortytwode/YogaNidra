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
    
    @Published var isOnboardingCompleted: Bool {
        didSet {
            UserDefaults.standard.set(isOnboardingCompleted, forKey: "isOnboardingCompleted")
            shouldShowOnboarding = !isOnboardingCompleted
        }
    }
    
    private init() {
        let isOnboardingCompleted = UserDefaults.standard.bool(forKey: "isOnboardingCompleted")
        self.isOnboardingCompleted = isOnboardingCompleted
        self.shouldShowOnboarding = !isOnboardingCompleted
    }
}
