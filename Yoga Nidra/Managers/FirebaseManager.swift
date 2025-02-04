import Foundation
import FirebaseStorage
import FirebaseFirestore
import FirebaseAnalytics
import FirebaseCore
import FirebaseAuth

/// Custom errors for Firebase operations
enum FirebaseError: LocalizedError {
    case invalidFileURL
    case uploadFailed(Error)
    case downloadFailed(Error)
    case metadataError
    case progressTrackingFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidFileURL:
            return "The file URL is invalid or inaccessible"
        case .uploadFailed(let error):
            return "Upload failed: \(error.localizedDescription)"
        case .downloadFailed(let error):
            return "Download failed: \(error.localizedDescription)"
        case .metadataError:
            return "Failed to create or update file metadata"
        case .progressTrackingFailed:
            return "Failed to track upload/download progress"
        }
    }
}

/// Progress update for file transfers
struct TransferProgress {
    let bytesTransferred: Int64
    let totalBytes: Int64
    let progress: Double
    
    init?(from progress: Progress?) {
        guard let progress = progress else { return nil }
        self.bytesTransferred = progress.completedUnitCount
        self.totalBytes = progress.totalUnitCount
        self.progress = Double(bytesTransferred) / Double(totalBytes)
    }
}

/// Manages all Firebase operations including Storage, Firestore, and Analytics
@MainActor
final class FirebaseManager {
    // MARK: - Singleton
    static let shared = FirebaseManager()
    
    // MARK: - Properties
    private let storage = Storage.storage()
    private let firestore = Firestore.firestore()
    private let maxRetries = 3
    
    // Storage references
    private var meditationsRef: StorageReference {
        storage.reference().child("meditations")
    }
    
    // Firestore references
    private var userProgressRef: CollectionReference {
        firestore.collection("user_progress")
    }
    
    private init() {
        configureFirestore()
    }
    
    private func configureFirestore() {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        firestore.settings = settings
    }
    
    // MARK: - Storage Methods
    
    /// Downloads the URL for a meditation file
    /// - Parameter fileName: Name of the meditation file in Firebase Storage
    /// - Returns: A downloadable URL for the meditation file
    func getMeditationURL(fileName: String) async throws -> URL {
        guard !fileName.isEmpty else {
            throw FirebaseError.invalidFileURL
        }
        
        let fileRef = meditationsRef.child(fileName)
        
        // Implement retry logic
        var lastError: Error?
        for attempt in 1...maxRetries {
            do {
                return try await fileRef.downloadURL()
            } catch {
                lastError = error
                if attempt == maxRetries { break }
                try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(attempt)) * 1_000_000_000))
            }
        }
        throw FirebaseError.downloadFailed(lastError ?? NSError(domain: "Unknown", code: -1))
    }
    
    /// Uploads a meditation file to Firebase Storage with retry logic and robust progress tracking
    /// - Parameters:
    ///   - fileURL: Local URL of the meditation file
    ///   - fileName: Name to give the file in Firebase Storage
    ///   - progressHandler: Optional closure to handle upload progress updates
    /// - Returns: The download URL for the uploaded file
    func uploadMeditation(
        fileURL: URL,
        fileName: String,
        progressHandler: ((TransferProgress) -> Void)? = nil
    ) async throws -> URL {
        // First ensure we're authenticated
        if Auth.auth().currentUser == nil {
            print("📱 Signing in anonymously...")
            try await Auth.auth().signInAnonymously()
            print("✅ Anonymous auth successful")
        }
        
        // Validate input
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw FirebaseError.invalidFileURL
        }
        
        let fileRef = meditationsRef.child(fileName)
        
        // Create metadata
        let metadata = StorageMetadata()
        metadata.contentType = "audio/mpeg"
        metadata.cacheControl = "public,max-age=31536000" // Cache for 1 year
        
        // Implement retry logic for upload
        var lastError: Error?
        for attempt in 1...maxRetries {
            do {
                let _ = try await fileRef.putFileAsync(from: fileURL, metadata: metadata) { progress in
                    if let transferProgress = TransferProgress(from: progress) {
                        progressHandler?(transferProgress)
                    }
                }
                return try await fileRef.downloadURL()
            } catch {
                lastError = error
                if attempt == maxRetries { break }
                try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(attempt)) * 1_000_000_000))
            }
        }
        throw FirebaseError.uploadFailed(lastError ?? NSError(domain: "Unknown", code: -1))
    }
    
    // MARK: - Analytics Methods
    
    /// Logs when a meditation session starts
    /// - Parameters:
    ///   - sessionTitle: Title of the meditation session
    ///   - duration: Duration of the session in seconds
    func logSessionStart(sessionTitle: String, duration: TimeInterval) {
        Analytics.logEvent("meditation_session_start", parameters: [
            "session_title": sessionTitle,
            "duration": duration,
            "timestamp": Date().timeIntervalSince1970
        ])
    }
    
    /// Logs when a meditation session completes
    /// - Parameters:
    ///   - sessionTitle: Title of the meditation session
    ///   - duration: Duration of the session in seconds
    ///   - completedDuration: How long the user actually meditated
    func logSessionComplete(sessionTitle: String, duration: TimeInterval, completedDuration: TimeInterval) {
        Analytics.logEvent("meditation_session_complete", parameters: [
            "session_title": sessionTitle,
            "total_duration": duration,
            "completed_duration": completedDuration,
            "completion_rate": completedDuration / duration,
            "timestamp": Date().timeIntervalSince1970
        ])
    }
}
