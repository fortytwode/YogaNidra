import Foundation

struct YogaNidraSession: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let duration: TimeInterval
    let category: SessionCategory
    let audioFileName: String
    let thumbnailUrl: String
    let instructor: String
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
         instructor: String,
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
        self.instructor = instructor
        self.isFavorite = isFavorite
        self.lastPlayed = lastPlayed
        self.completionCount = completionCount
    }
}

// MARK: - Preview Data
extension YogaNidraSession {
    static let previewData: [YogaNidraSession] = {
        let sessions = SessionDataParser.loadSessions()
        print("🔄 Loaded \(sessions.count) sessions for preview data")
        return sessions
    }()
} 
