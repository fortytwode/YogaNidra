import Foundation

enum DownloadError: LocalizedError {
    case subscriptionRequired
    case invalidLocalURL
    case downloadFailed(Error)
    case moveFileFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .subscriptionRequired:
            return "Premium subscription required to download sessions"
        case .invalidLocalURL:
            return "Could not create local file URL"
        case .downloadFailed(let error):
            return "Download failed: \(error.localizedDescription)"
        case .moveFileFailed(let error):
            return "Failed to save downloaded file: \(error.localizedDescription)"
        }
    }
}

@MainActor
class DownloadManager: ObservableObject {
    static let shared = DownloadManager()
    private let storeManager = StoreManager.shared
    private let maxRetries = 3
    
    func downloadSession(_ yogaNidraSession: YogaNidraSession) async throws {
        // Log the start of the download process
        print("📥 Starting download for session: \(yogaNidraSession.fileName).\(yogaNidraSession.fileExtension)")
        
        // Check subscription status
        guard storeManager.isSubscribed else {
            print("❌ User is not subscribed. Download aborted.")
            throw DownloadError.subscriptionRequired
        }
        
        // Get local file URL
        guard let localURL = fileURLForSession(yogaNidraSession) else {
            print("⚠️ Could not create local file URL")
            throw DownloadError.invalidLocalURL
        }
        
        // Implement retry logic for the entire download process
        var lastError: Error?
        for attempt in 1...maxRetries {
            do {
                // Get Firebase download URL
                let downloadURL = try await FirebaseManager.shared.getMeditationURL(
                    fileName: "\(yogaNidraSession.fileName).\(yogaNidraSession.fileExtension)"
                )
                
                print("🔗 Got download URL: \(downloadURL)")
                
                // Download the file using URLSession
                let (tempURL, _) = try await URLSession.shared.download(from: downloadURL)
                
                print("📦 Downloaded to temporary location: \(tempURL.path)")
                
                // Remove any existing file at the destination
                try? FileManager.default.removeItem(at: localURL)
                
                // Move the downloaded file to its final location
                try FileManager.default.moveItem(at: tempURL, to: localURL)
                
                print("✅ Successfully moved file to final location: \(localURL.path)")
                objectWillChange.send()
                return
                
            } catch {
                lastError = error
                print("❌ Attempt \(attempt) failed: \(error.localizedDescription)")
                
                if attempt == maxRetries { break }
                
                // Exponential backoff
                let delay = UInt64(pow(2.0, Double(attempt)) * 1_000_000_000)
                try await Task.sleep(nanoseconds: delay)
            }
        }
        
        // If we get here, all retries failed
        throw DownloadError.downloadFailed(lastError ?? NSError(domain: "Unknown", code: -1))
    }
    
    func fileURLForSession(_ yogaNidraSession: YogaNidraSession) -> URL? {
        guard let storageFolder = storageFolder() else {
            print("⚠️ Unable to locate storage folder.")
            return nil
        }
        let fileURL = storageFolder.appendingPathComponent("\(yogaNidraSession.fileName).\(yogaNidraSession.fileExtension)")
        print("📂 Resolved file URL: \(fileURL.path)")
        return fileURL
    }
    
    private func storageFolder() -> URL? {
        let fileManager = FileManager.default
        guard let documentsFolder = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let storageFolder = documentsFolder.appendingPathComponent("YogaNidraSessions", isDirectory: true)
        
        if !fileManager.fileExists(atPath: storageFolder.path) {
            do {
                try fileManager.createDirectory(at: storageFolder, withIntermediateDirectories: true)
            } catch {
                print("❌ Failed to create storage directory: \(error.localizedDescription)")
                return nil
            }
        }
        
        return storageFolder
    }
    
    func isSessionDownloaded(_ yogaNidraSession: YogaNidraSession) -> Bool {
        guard let fileURL = fileURLForSession(yogaNidraSession) else {
            return false
        }
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
    
    func deleteSession(_ yogaNidraSession: YogaNidraSession) {
        guard let fileURL = fileURLForSession(yogaNidraSession) else { return }
        try? FileManager.default.removeItem(at: fileURL)
        objectWillChange.send()
    }
}
