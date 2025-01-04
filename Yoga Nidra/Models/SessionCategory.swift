import SwiftUI

enum SessionCategory: String, CaseIterable, Identifiable {
    case all = "All"
    case quickSleep = "Quick Sleep"
    case deepSleep = "Deep Sleep"
    case powerNap = "Power Nap"
    case sleepAnxiety = "Sleep Anxiety"
    case travelJetLag = "Travel & Jet Lag"
    case sleepEnvironment = "Sleep Environment"
    case beginnersPath = "Beginner's Path"
    
    var id: SessionCategory { self }
    
    var description: String {
        switch self {
        case .all: return "All meditation sessions"
        case .quickSleep: return "10-15 minute sleep sessions"
        case .deepSleep: return "30-45 minute deep sleep practices"
        case .powerNap: return "5-20 minute power naps"
        case .sleepAnxiety: return "Relief from sleep anxiety"
        case .travelJetLag: return "Travel and jet lag assistance"
        case .sleepEnvironment: return "Adapt to sleep environments"
        case .beginnersPath: return "Introduction to sleep practices"
        }
    }
    
    var duration: ClosedRange<TimeInterval> {
        switch self {
        case .all: return 300...3600 // 5-60 minutes
        case .quickSleep: return 600...900 // 10-15 minutes
        case .deepSleep: return 1800...2700 // 30-45 minutes
        case .powerNap: return 300...1200 // 5-20 minutes
        case .sleepAnxiety: return 900...1200 // 15-20 minutes
        case .travelJetLag: return 900...1800 // 15-30 minutes
        case .sleepEnvironment: return 900...1200 // 15-20 minutes
        case .beginnersPath: return 600...1200 // 10-20 minutes
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "list.bullet"
        case .quickSleep: return "moon.zzz.fill"
        case .deepSleep: return "moon.stars.fill"
        case .powerNap: return "powersleep"
        case .sleepAnxiety: return "heart.fill"
        case .travelJetLag: return "airplane"
        case .sleepEnvironment: return "bed.double.fill"
        case .beginnersPath: return "leaf.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .all: return .blue
        case .quickSleep: return .purple
        case .deepSleep: return .indigo
        case .powerNap: return .orange
        case .sleepAnxiety: return .red
        case .travelJetLag: return .green
        case .sleepEnvironment: return .blue
        case .beginnersPath: return .mint
        }
    }
}

// MARK: - Preview Data
extension SessionCategory {
    static let previewSessions = [
        YogaNidraSession(
            title: "Deep Sleep",
            description: "Deep sleep meditation",
            duration: 1200, // 20 min
            category: .deepSleep,
            audioFileName: "deep_sleep",
            thumbnailUrl: "deep-relaxation-journey"
        ),
        YogaNidraSession(
            title: "Calm Mind",
            description: "Relaxation practice",
            duration: 900, // 15 min
            category: .quickSleep,
            audioFileName: "calm_mind",
            thumbnailUrl: "quick-refresh"
        ),
        YogaNidraSession(
            title: "Stress Relief",
            description: "Reduce anxiety",
            duration: 600, // 10 min
            category: .sleepAnxiety,
            audioFileName: "stress_relief",
            thumbnailUrl: "racing-mind-relief"
        ),
        YogaNidraSession(
            title: "Power Focus",
            description: "Enhance concentration",
            duration: 1500, // 25 min
            category: .powerNap,
            audioFileName: "power_focus",
            thumbnailUrl: "afternoon-reset"
        ),
        YogaNidraSession(
            title: "Travel Rest",
            description: "Jet lag recovery",
            duration: 1200, // 20 min
            category: .travelJetLag,
            audioFileName: "travel_rest",
            thumbnailUrl: "sleep-restoration"
        ),
        YogaNidraSession(
            title: "Beginner's Guide",
            description: "Introduction to sleep meditation",
            duration: 900, // 15 min
            category: .beginnersPath,
            audioFileName: "beginners_guide",
            thumbnailUrl: "complete-yoga-nidra"
        )
    ]
} 