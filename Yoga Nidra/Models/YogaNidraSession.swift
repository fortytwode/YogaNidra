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
    
    // Add Equatable conformance
    static func == (lhs: YogaNidraSession, rhs: YogaNidraSession) -> Bool {
        lhs.id == rhs.id
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
