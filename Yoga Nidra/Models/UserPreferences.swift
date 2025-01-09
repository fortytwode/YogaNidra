import Foundation

struct UserPreferences: Codable {
    var sleepQuality: String?
    var fallAsleepTime: String?
    var nightWakeups: String?
    var morningTiredness: String?
    var sleepImpact: String?
    var onboardingCompleted: Date?
    
    static let `default` = UserPreferences(
        sleepQuality: nil,
        fallAsleepTime: nil,
        nightWakeups: nil,
        morningTiredness: nil,
        sleepImpact: nil,
        onboardingCompleted: nil
    )
} 