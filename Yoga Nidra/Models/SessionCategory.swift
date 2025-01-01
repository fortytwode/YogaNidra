import SwiftUI

enum SessionCategory: String, CaseIterable, Identifiable {
    case quickSleep = "Quick Sleep"
    case deepSleep = "Deep Sleep"
    case nightAnxiety = "Night Anxiety Relief"
    case sleepRestoration = "Sleep Restoration"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .quickSleep: return "moon.fill"
        case .deepSleep: return "moon.stars.fill"
        case .nightAnxiety: return "heart.circle.fill"
        case .sleepRestoration: return "bed.double.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .quickSleep: return .indigo
        case .deepSleep: return .purple
        case .nightAnxiety: return .blue
        case .sleepRestoration: return .teal
        }
    }
    
    var duration: ClosedRange<TimeInterval> {
        switch self {
        case .quickSleep: return 600...900        // 10-15 minutes
        case .deepSleep: return 1800...2700       // 30-45 minutes
        case .nightAnxiety: return 1200...1800    // 20-30 minutes
        case .sleepRestoration: return 900...1200 // 15-20 minutes
        }
    }
    
    var description: String {
        switch self {
        case .quickSleep:
            return "Brief but effective practices focused on rapid relaxation"
        case .deepSleep:
            return "Complete Yoga Nidra practice with full body rotation"
        case .nightAnxiety:
            return "Anxiety-specific guidance with calming visualizations"
        case .sleepRestoration:
            return "Help with jet lag, interrupted sleep, and travel recovery"
        }
    }
} 