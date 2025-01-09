import Foundation

struct YogaNidraSession: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let duration: Int
    let category: SessionCategory
    let audioFileName: String
    let thumbnailUrl: String
    let isPremium: Bool
    let instructor: String
    let audioUrl: String
    var isDownloaded: Bool = false
    var localUrl: URL?
    
    // Add Equatable conformance
    static func == (lhs: YogaNidraSession, rhs: YogaNidraSession) -> Bool {
        lhs.id == rhs.id
    }
    
    // Update initializer to include audioUrl
    init(title: String, duration: Int, category: SessionCategory, 
         audioFileName: String, thumbnailUrl: String, isPremium: Bool, 
         instructor: String, audioUrl: String = "") {  // Default empty string for existing code
        self.title = title
        self.duration = duration
        self.category = category
        self.audioFileName = audioFileName
        self.thumbnailUrl = thumbnailUrl
        self.isPremium = isPremium
        self.instructor = instructor
        self.audioUrl = audioUrl
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
