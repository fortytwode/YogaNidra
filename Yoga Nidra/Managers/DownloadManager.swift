import Foundation

class DownloadManager: ObservableObject {
    static let shared = DownloadManager()
    @Published var downloads: [String: Download] = [:]
    private let subscriptionManager = SubscriptionManager.shared
    
    struct Download {
        var progress: Float
        var task: URLSessionDownloadTask
        var isDownloading: Bool
    }
    
    private let defaults = UserDefaults.standard
    private let downloadedSessionsKey = "downloadedSessions"
    
    func downloadSession(_ session: YogaNidraSession) async {
        // Check subscription status asynchronously
        guard await subscriptionManager.checkIsSubscribed() else { return }
        
        let audioUrl = session.audioUrl.isEmpty ? 
            "https://your-base-url.com/audio/\(session.audioFileName)" : 
            session.audioUrl
            
        guard let url = URL(string: audioUrl) else { return }
        
        let task = URLSession.shared.downloadTask(with: url) { localUrl, _, error in
            guard let localUrl = localUrl, error == nil else { return }
            
            // Move to permanent location
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destinationUrl = documentsPath.appendingPathComponent("\(session.id).m4a")
            
            try? FileManager.default.moveItem(at: localUrl, to: destinationUrl)
            
            DispatchQueue.main.async {
                self.downloads[session.id.uuidString]?.isDownloading = false
                // Update session's local URL
                // You'll need to implement persistence for this
            }
        }
        
        downloads[session.id.uuidString] = Download(progress: 0, task: task, isDownloading: true)
        task.resume()
    }
    
    func cancelDownload(_ session: YogaNidraSession) {
        downloads[session.id.uuidString]?.task.cancel()
        downloads.removeValue(forKey: session.id.uuidString)
    }
    
    func removeDownload(_ session: YogaNidraSession) async {
        // Check subscription status asynchronously
        guard await subscriptionManager.checkIsSubscribed() else { return }
        
        if let localUrl = session.localUrl {
            try? FileManager.default.removeItem(at: localUrl)
        }
        
        // Remove from downloaded sessions
        var downloadedSessions = defaults.stringArray(forKey: downloadedSessionsKey) ?? []
        downloadedSessions.removeAll { $0 == session.id.uuidString }
        defaults.set(downloadedSessions, forKey: downloadedSessionsKey)
        
        objectWillChange.send()
    }
    
    func isDownloaded(_ session: YogaNidraSession) -> Bool {
        let downloadedSessions = defaults.stringArray(forKey: downloadedSessionsKey) ?? []
        return downloadedSessions.contains(session.id.uuidString)
    }
    
    private func saveDownloadedSession(_ session: YogaNidraSession, at url: URL) {
        var downloadedSessions = defaults.stringArray(forKey: downloadedSessionsKey) ?? []
        downloadedSessions.append(session.id.uuidString)
        defaults.set(downloadedSessions, forKey: downloadedSessionsKey)
    }
} 