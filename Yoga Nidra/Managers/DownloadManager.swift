import Foundation

enum DownloadError: LocalizedError {
    case subscriptionRequired
    case networkError(Error)
    case storageError(Error)
    case invalidURL
    
    var errorDescription: String? {
        switch self {
        case .subscriptionRequired:
            return "Premium subscription required"
        case .networkError(let error):
            return "Download failed: \(error.localizedDescription)"
        case .storageError(let error):
            return "Storage error: \(error.localizedDescription)"
        case .invalidURL:
            return "Invalid audio URL"
        }
    }
}

@MainActor
final class DownloadManager: ObservableObject {
    static let shared = DownloadManager()
    
    private let storeManager = StoreManager.shared
    private let firebaseManager = FirebaseManager.shared
    
    // Active downloads tracking
    @Published private(set) var downloadingSessionIds: Set<UUID> = []
    
    private init() {}
    
    // MARK: - Public Methods
    
    func downloadSession(_ session: YogaNidraSession) async throws {
        guard !session.isPremium || storeManager.isSubscribed else {
            throw DownloadError.subscriptionRequired
        }
        
        guard let localURL = session.localURL else {
            throw DownloadError.invalidURL
        }
        
        // Start download
        downloadingSessionIds.insert(session.id)
        defer { downloadingSessionIds.remove(session.id) }
        
        do {
            // Create directory if needed
            try createDownloadDirectoryIfNeeded()
            
            // Get Firebase download URL
            let downloadURL = try await firebaseManager.getMeditationURL(fileName: session.storageFileName)
            
            // Download file
            let (tempURL, _) = try await URLSession.shared.download(from: downloadURL)
            
            // Move to final location
            if FileManager.default.fileExists(atPath: localURL.path) {
                try FileManager.default.removeItem(at: localURL)
            }
            try FileManager.default.moveItem(at: tempURL, to: localURL)
            
        } catch {
            if let urlError = error as? URLError {
                throw DownloadError.networkError(urlError)
            } else {
                throw DownloadError.storageError(error)
            }
        }
    }
    
    func deleteSession(_ session: YogaNidraSession) {
        guard let localURL = session.localURL else { return }
        try? FileManager.default.removeItem(at: localURL)
        objectWillChange.send()
    }
    
    func isDownloading(_ session: YogaNidraSession) -> Bool {
        downloadingSessionIds.contains(session.id)
    }
    
    // MARK: - Private Methods
    
    private func createDownloadDirectoryIfNeeded() throws {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw DownloadError.storageError(NSError(domain: "DownloadManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not access documents directory"]))
        }
        
        let downloadDirectory = documentsPath.appendingPathComponent("YogaNidraSessions", isDirectory: true)
        
        if !FileManager.default.fileExists(atPath: downloadDirectory.path) {
            try FileManager.default.createDirectory(at: downloadDirectory, withIntermediateDirectories: true)
        }
    }
}
