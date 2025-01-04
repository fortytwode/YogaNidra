import Foundation

struct YogaNidraSession: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let duration: TimeInterval
    let category: SessionCategory
    let audioFileName: String
    let thumbnailUrl: String
    var isFavorite: Bool
    var lastPlayed: Date?
    var completionCount: Int
    
    init(id: UUID = UUID(), 
         title: String, 
         description: String, 
         duration: TimeInterval, 
         category: SessionCategory, 
         audioFileName: String,
         thumbnailUrl: String,
         isFavorite: Bool = false,
         lastPlayed: Date? = nil,
         completionCount: Int = 0) {
        self.id = id
        self.title = title
        self.description = description
        self.duration = duration
        self.category = category
        self.audioFileName = audioFileName
        self.thumbnailUrl = thumbnailUrl
        self.isFavorite = isFavorite
        self.lastPlayed = lastPlayed
        self.completionCount = completionCount
    }
}

// MARK: - Preview Data
extension YogaNidraSession {
    static let previewData = [
        YogaNidraSession(
            title: "Complete Yoga Nidra",
            description: "Deep sleep meditation",
            duration: 1800, // 30 min
            category: .deepSleep,
            audioFileName: "complete_yoga_nidra",
            thumbnailUrl: "complete-yoga-nidra"
        ),
        YogaNidraSession(
            title: "Quick Refresh",
            description: "Quick energizing rest",
            duration: 300, // 5 min
            category: .powerNap,
            audioFileName: "quick_refresh",
            thumbnailUrl: "quick-refresh"
        ),
        YogaNidraSession(
            title: "Calm Mind",
            description: "Relaxation practice",
            duration: 900, // 15 min
            category: .quickSleep,
            audioFileName: "calm_mind",
            thumbnailUrl: "calm_mind"
        ),
        YogaNidraSession(
            title: "Stress Relief",
            description: "Reduce anxiety",
            duration: 600, // 10 min
            category: .sleepAnxiety,
            audioFileName: "stress_relief",
            thumbnailUrl: "stress_relief"
        ),
        YogaNidraSession(
            title: "Power Focus",
            description: "Enhance concentration",
            duration: 1500, // 25 min
            category: .powerNap,
            audioFileName: "power_focus",
            thumbnailUrl: "power_focus"
        ),
        YogaNidraSession(
            title: "Travel Rest",
            description: "Jet lag recovery",
            duration: 1200, // 20 min
            category: .travelJetLag,
            audioFileName: "travel_rest",
            thumbnailUrl: "travel_rest"
        ),
        YogaNidraSession(
            title: "Beginner's Guide",
            description: "Introduction to sleep meditation",
            duration: 900, // 15 min
            category: .beginnersPath,
            audioFileName: "beginners_guide",
            thumbnailUrl: "beginners_guide"
        )
    ]
} 