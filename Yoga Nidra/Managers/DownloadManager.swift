import Foundation

@MainActor
class DownloadManager: ObservableObject {
    static let shared = DownloadManager()
    @Published var downloads: [String: Download] = [:]
    private let storeManager = StoreManager.shared
    
    struct Download {
        var progress: Float
        var task: URLSessionDownloadTask
        var isDownloading: Bool
    }
    
    private let defaults = UserDefaults.standard
    private let downloadedSessionsKey = "downloadedSessions"
    
    func downloadSession(_ yogaNidraSession: YogaNidraSession) async throws {
        // Check subscription status asynchronously
        guard await storeManager.isSubscribed else { return }
        
        // Construct audio URL from fileName
        let baseUrl = "https://your-base-url.com/audio/"
        let audioUrl = baseUrl + yogaNidraSession.audioFileName
        
        guard let url = URL(string: audioUrl) else {
            throw DownloadError.invalidURL
        }
        
        // Create URLSession with delegate for progress tracking
        let urlSession = URLSession(configuration: .default)
        
        // Track download state
        let task = urlSession.downloadTask(with: url)
        DispatchQueue.main.async {
            self.downloads[yogaNidraSession.id.uuidString] = Download(
                progress: 0,
                task: task,
                isDownloading: true
            )
        }
        
        // Use async/await API for download
        let (tempUrl, _) = try await urlSession.download(from: url)
        
        // Move downloaded file to documents directory
        try FileManager.default.moveItem(at: tempUrl, to: yogaNidraSession.localUrl)
        
        // Clear download state
        DispatchQueue.main.async {
            self.downloads.removeValue(forKey: yogaNidraSession.id.uuidString)
        }
    }
    
    func cancelDownload(_ yogaNidraSession: YogaNidraSession) {
        downloads[yogaNidraSession.id.uuidString]?.task.cancel()
        downloads.removeValue(forKey: yogaNidraSession.id.uuidString)
    }
    
    func removeDownload(_ yogaNidraSession: YogaNidraSession) async throws {
        guard await storeManager.isSubscribed else { return }
        
        if FileManager.default.fileExists(atPath: yogaNidraSession.localUrl.path) {
            try FileManager.default.removeItem(at: yogaNidraSession.localUrl)
        }
    }
}

enum DownloadError: LocalizedError {
    case invalidURL
    case fileMoveError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid download URL"
        case .fileMoveError(let error):
            return "Failed to save download: \(error.localizedDescription)"
        }
    }
} 