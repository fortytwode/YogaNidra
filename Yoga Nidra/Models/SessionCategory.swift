import SwiftUI

enum SessionCategory: String, Codable {
    case deepSleep = "Deep Sleep"
    case stressAnxietyRelief = "Stress & Anxiety Relief"
    case nightTimeAnxiety = "Night Time Anxiety"
    case dailyRestoration = "Daily Restoration"
    case all = "All"  // For filtering purposes
    
    static var allCases: [SessionCategory] {
        [.deepSleep, .stressAnxietyRelief, 
         .nightTimeAnxiety, .dailyRestoration]
    }
    
    // UI Properties
    var icon: String {
        switch self {
        case .deepSleep: return "moon.zzz.fill"
        case .stressAnxietyRelief: return "heart.circle.fill"
        case .nightTimeAnxiety: return "bed.double.circle.fill"
        case .dailyRestoration: return "sun.max.circle.fill"
        case .all: return "list.bullet"
        }
    }
    
    var color: Color {
        switch self {
        case .deepSleep: return .purple
        case .stressAnxietyRelief: return .pink
        case .nightTimeAnxiety: return .mint
        case .dailyRestoration: return .orange
        case .all: return .gray
        }
    }
    
    var description: String {
        switch self {
        case .deepSleep: return "Deep relaxation for better sleep"
        case .stressAnxietyRelief: return "Release stress and anxiety"
        case .nightTimeAnxiety: return "Calm your mind before sleep"
        case .dailyRestoration: return "Restore and recharge daily"
        case .all: return "All sessions"
        }
    }
    
    var duration: ClosedRange<TimeInterval> {
        switch self {
        case .deepSleep: return 1200...2700    // 20-45 minutes
        case .stressAnxietyRelief: return 900...1800  // 15-30 minutes
        case .nightTimeAnxiety: return 900...1800  // 15-30 minutes
        case .dailyRestoration: return 600...1200 // 10-20 minutes
        case .all: return 600...2700           // 10-45 minutes
        }
    }
}
