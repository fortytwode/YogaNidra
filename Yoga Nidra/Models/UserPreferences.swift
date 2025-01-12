import Foundation

struct UserPreferences: Codable {
    var fallAsleepTime: String = ""
    var nightWakeups: String = ""
    var sleepImpact: String = ""
    var morningTiredness: String = ""
    var sleepDuration: String = ""
    
    // New fields for additional questions
    var mainGoal: String = ""
    var sleepFeelings: String = ""
    var relaxationObstacle: String = ""
    var sleepQuality: String = ""
} 