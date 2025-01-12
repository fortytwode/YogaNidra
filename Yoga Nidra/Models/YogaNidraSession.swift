import Foundation

struct YogaNidraSession: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let duration: Int
    let thumbnailUrl: String
    let audioFileName: String
    let isPremium: Bool
    let category: SessionCategory
    let instructor: String
    
    // Add Equatable conformance
    static func == (lhs: YogaNidraSession, rhs: YogaNidraSession) -> Bool {
        lhs.id == rhs.id
    }
    
    // Add computed property for local URL
    var localUrl: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("\(id.uuidString).m4a")
    }
    
    var isDownloaded: Bool {
        FileManager.default.fileExists(atPath: localUrl.path)
    }
    
    // Load all sessions from CSV
    static var allSessions: [YogaNidraSession] {
        SessionDataParser.loadSessions()
    }
    
    // Keep minimal preview data for SwiftUI previews only
    static let preview = YogaNidraSession(
        id: UUID(),
        title: "Preview Session",
        description: "This is a preview session for development",
        duration: 10,
        thumbnailUrl: "preview-thumbnail",
        audioFileName: "preview-audio.m4a",
        isPremium: false,
        category: .quickSleep,
        instructor: "Preview Instructor"
    )
    
    // For preview purposes only
    static let previewData = [preview]
} 
