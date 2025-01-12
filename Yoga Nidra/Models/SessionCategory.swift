import SwiftUI

enum SessionCategory: String, Codable {
    case quickSleep = "Quick Sleep"
    case deepSleep = "Deep Sleep"
    case powerNap = "Power Nap"
    case sleepAnxiety = "Sleep Anxiety"
    case travelJetLag = "Travel & Jet Lag"
    case sleepEnvironment = "Sleep Environment"
    case all = "All"  // For filtering purposes
    
    static var allCases: [SessionCategory] {
        [.quickSleep, .deepSleep, .powerNap, .sleepAnxiety, 
         .travelJetLag, .sleepEnvironment]
    }
    
    // UI Properties
    var icon: String {
        switch self {
        case .quickSleep: return "moon.stars.fill"
        case .deepSleep: return "moon.zzz.fill"
        case .powerNap: return "powersleep"
        case .sleepAnxiety: return "heart.circle.fill"
        case .travelJetLag: return "airplane.circle.fill"
        case .sleepEnvironment: return "bed.double.fill"
        case .all: return "list.bullet"
        }
    }
    
    var color: Color {
        switch self {
        case .quickSleep: return .blue
        case .deepSleep: return .purple
        case .powerNap: return .orange
        case .sleepAnxiety: return .pink
        case .travelJetLag: return .green
        case .sleepEnvironment: return .mint
        case .all: return .gray
        }
    }
    
    var description: String {
        switch self {
        case .quickSleep: return "Short sessions for quick relaxation"
        case .deepSleep: return "Deep relaxation for better sleep"
        case .powerNap: return "Refresh and recharge"
        case .sleepAnxiety: return "Calm your mind before sleep"
        case .travelJetLag: return "Adjust to new time zones"
        case .sleepEnvironment: return "Optimize your sleep space"
        case .all: return "All sessions"
        }
    }
    
    var duration: ClosedRange<TimeInterval> {
        switch self {
        case .quickSleep: return 300...900     // 5-15 minutes
        case .deepSleep: return 1200...2700    // 20-45 minutes
        case .powerNap: return 600...1200      // 10-20 minutes
        case .sleepAnxiety: return 900...1800  // 15-30 minutes
        case .travelJetLag: return 900...1800  // 15-30 minutes
        case .sleepEnvironment: return 600...1200 // 10-20 minutes
        case .all: return 300...2700           // 5-45 minutes
        }
    }
}

