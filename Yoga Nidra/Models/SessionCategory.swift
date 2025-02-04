import SwiftUI

struct SessionCategory: Hashable, Codable, Identifiable {
    let id: String  // This will be the category name
    
    private var config: CategoryConfig {
        CategoryMetadata.configFor(id: id.lowercased())
    }
    
    var icon: String { config.icon }
    var color: Color { config.color }
    var description: String { config.description }
    var recommendedDurationRange: ClosedRange<TimeInterval> { config.durationRange }
    
    // Special case for "All" category
    static let all = SessionCategory(id: "All")
}

// Configuration for category metadata
private struct CategoryConfig {
    let icon: String
    let color: Color
    let description: String
    let durationRange: ClosedRange<TimeInterval>
    
    static let defaultConfig = CategoryConfig(
        icon: "questionmark.circle.fill",
        color: .gray,
        description: "Meditation session",
        durationRange: 300...2700  // 5-45 minutes
    )
}

// Metadata store for all categories
private enum CategoryMetadata {
    private static let metadata: [String: CategoryConfig] = [
        "deep sleep": CategoryConfig(
            icon: "moon.zzz.fill",
            color: .purple,
            description: "Achieve deep, restful sleep",
            durationRange: 1800...2700  // 30-45 minutes
        ),
        "stress & anxiety relief": CategoryConfig(
            icon: "heart.circle.fill",
            color: .pink,
            description: "Release stress and anxiety",
            durationRange: 900...1800  // 15-30 minutes
        ),
        "night time anxiety": CategoryConfig(
            icon: "bed.double.circle.fill",
            color: .blue,
            description: "Calm your mind before sleep",
            durationRange: 900...1800  // 15-30 minutes
        ),
        "daily restoration": CategoryConfig(
            icon: "sun.max.circle.fill",
            color: .orange,
            description: "Restore and recharge daily",
            durationRange: 600...1200  // 10-20 minutes
        ),
        "power nap & reset": CategoryConfig(
            icon: "bolt.circle.fill",
            color: .yellow,
            description: "Recharge with a power nap",
            durationRange: 300...900   // 5-15 minutes
        ),
        "all": CategoryConfig(
            icon: "list.bullet",
            color: .gray,
            description: "All sessions",
            durationRange: 300...2700  // 5-45 minutes
        )
    ]
    
    static func configFor(id: String) -> CategoryConfig {
        metadata[id] ?? CategoryConfig.defaultConfig
    }
}

// Category Manager to handle loading and caching categories
class CategoryManager {
    static let shared = CategoryManager()
    
    private(set) var categories: [SessionCategory] = []
    private(set) var categoryMap: [String: SessionCategory] = [:]
    
    private init() {
        loadCategories()
    }
    
    private func loadCategories() {
        guard let path = Bundle.main.path(forResource: "sessions", ofType: "json") else {
            print("❌ Could not find sessions.json")
            return
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            
            // Decode just enough of the session data to get categories
            struct SessionData: Codable {
                let category: String
            }
            
            let sessions = try JSONDecoder().decode([SessionData].self, from: data)
            
            // Get unique categories and create SessionCategory objects
            let uniqueCategories = Set(sessions.map { $0.category })
            categories = uniqueCategories.map { SessionCategory(id: $0) }.sorted { $0.id < $1.id }
            
            // Create a map for quick lookup
            categoryMap = Dictionary(uniqueKeysWithValues: categories.map { ($0.id, $0) })
            print("✅ Loaded \(categories.count) categories from sessions.json")
            
        } catch {
            print("❌ Failed to load categories from sessions.json: \(error)")
        }
    }
    
    func category(for id: String) -> SessionCategory {
        categoryMap[id] ?? .all
    }
}

// Static extensions for previews and testing
extension SessionCategory {
    static var deepSleep: SessionCategory { SessionCategory(id: "Deep Sleep") }
    static var stressAnxietyRelief: SessionCategory { SessionCategory(id: "Stress & Anxiety Relief") }
    static var nightTimeAnxiety: SessionCategory { SessionCategory(id: "Night Time Anxiety") }
    static var dailyRestoration: SessionCategory { SessionCategory(id: "Daily Restoration") }
    static var powerNapReset: SessionCategory { SessionCategory(id: "Power Nap & Reset") }
}
