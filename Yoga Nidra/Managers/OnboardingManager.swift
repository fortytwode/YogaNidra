import Foundation

class OnboardingManager: ObservableObject {
    static let shared = OnboardingManager()
    
    @Published var shouldShowOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(!shouldShowOnboarding, forKey: "hasCompletedOnboarding")
        }
    }
    
    init() {
        self.shouldShowOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
} 