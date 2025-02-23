import Foundation

struct YogaNidraSession: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let title: String
    let description: String
    let duration: Int
    let thumbnailUrl: String
    let audioFileName: String
    let isPremium: Bool
    let category: SessionCategory
    let instructor: String
    
    // MARK: - Equatable
    static func == (lhs: YogaNidraSession, rhs: YogaNidraSession) -> Bool {
        lhs.id == rhs.id
    }
    
    // MARK: - File Management
    var fileName: String {
        audioFileName.split(separator: ".").first?.description ?? ""
    }
    
    var fileExtension: String {
        audioFileName.split(separator: ".").last?.description ?? ""
    }
    
    var storageFileName: String {
        "\(fileName).\(fileExtension)"
    }
    
    // MARK: - Download Status
    @MainActor
    var isDownloaded: Bool {
        guard let localURL = localURL else { return false }
        return FileManager.default.fileExists(atPath: localURL.path)
    }
    
    var localURL: URL? {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documentsPath
            .appendingPathComponent("YogaNidraSessions", isDirectory: true)
            .appendingPathComponent(storageFileName)
    }
    
    // MARK: - Static Properties
    static var allSessions: [YogaNidraSession] = {
        SessionDataParser.loadSessions().filter { 
            $0.category.id.lowercased() != "14 days of self love"
        }
    }()
    
    // MARK: - Specifc event sessions Properties
    static var specialEventSessions: [YogaNidraSession] = {
        SessionDataParser.loadSessions().filter { 
            $0.category.id.lowercased() == "14 days of self love"
        }
    }()
    
    static let preview = YogaNidraSession(
        id: "0",
        title: "Preview Session",
        description: "This is a preview session for development",
        duration: 10,
        thumbnailUrl: "preview-thumbnail",
        audioFileName: "preview-audio.m4a",
        isPremium: false,
        category: SessionCategory(id: "Deep Sleep"),
        instructor: "Preview Instructor"
    )
    
    // For preview purposes only
    static let previewData = [preview]
}
