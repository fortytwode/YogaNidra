import Foundation

struct Session: Identifiable {
    let id = UUID()
    let title: String
    let duration: TimeInterval  // in seconds
    let description: String
    let thumbnailUrl: String
    let audioUrl: String
    let isPremium: Bool
    let category: SessionCategory
    let tags: [SessionTag]
    
    enum SessionCategory: String {
        case deepSleep = "Deep Sleep"
        case powerNap = "Power Nap"
        case stressRelief = "Stress Relief"
        case morningEnergy = "Morning Energy"
    }
    
    enum SessionTag: String {
        case beginnerFriendly = "Beginner Friendly"
        case fallAsleep = "Fall Asleep Fast"
        case stayAsleep = "Stay Asleep"
        case morningFresh = "Morning Freshness"
    }
} 