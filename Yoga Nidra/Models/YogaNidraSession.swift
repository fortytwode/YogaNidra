import Foundation

struct YogaNidraSession: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let duration: TimeInterval
    let category: SessionCategory
    let audioFileName: String
    let thumbnailUrl: URL?
    var isFavorite: Bool
    var lastPlayed: Date?
    var completionCount: Int
    
    init(id: UUID = UUID(), 
         title: String, 
         description: String, 
         duration: TimeInterval, 
         category: SessionCategory, 
         audioFileName: String,
         thumbnailUrl: URL? = nil,
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
            title: "Quick Sleep Relaxation",
            description: "A brief practice to help you fall asleep quickly.",
            duration: 600, // 10 minutes
            category: .quickSleep,
            audioFileName: "quick_sleep_10min"
        ),
        YogaNidraSession(
            title: "Deep Sleep Journey",
            description: "Complete Yoga Nidra practice for deep, restful sleep.",
            duration: 2400, // 40 minutes
            category: .deepSleep,
            audioFileName: "deep_sleep_40min"
        ),
        YogaNidraSession(
            title: "Calm Night Anxiety",
            description: "Release anxiety and prepare for peaceful sleep.",
            duration: 1500, // 25 minutes
            category: .nightAnxiety,
            audioFileName: "night_anxiety_25min"
        ),
        YogaNidraSession(
            title: "Sleep Reset",
            description: "Reset your sleep cycle after travel or disruption.",
            duration: 1200, // 20 minutes
            category: .sleepRestoration,
            audioFileName: "sleep_restoration_20min"
        )
    ]
} 