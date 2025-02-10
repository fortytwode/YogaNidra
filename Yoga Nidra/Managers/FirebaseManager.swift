import Foundation
import FirebaseStorage
import FirebaseFirestore
import FirebaseAnalytics
import FirebaseCore

/// Custom errors for Firebase operations
enum FirebaseError: LocalizedError {
    case downloadFailed(Error)
    case fileNotFound
    
    var errorDescription: String? {
        switch self {
        case .downloadFailed(let error):
            return "Download failed: \(error.localizedDescription)"
        case .fileNotFound:
            return "File not found in Firebase Storage"
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
            throw FirebaseError.fileNotFound
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
    
    // MARK: - Meditation Analytics
    
    func logMeditationStarted(sessionId: String, duration: TimeInterval, category: String) {
        Analytics.logEvent("meditation_started", parameters: [
            "session_id": sessionId,
            "duration": duration,
            "category": category,
            "timestamp": Date().timeIntervalSince1970
        ])
    }
    
    func logMeditationCompleted(sessionId: String, duration: TimeInterval, category: String) {
        Analytics.logEvent("meditation_completed", parameters: [
            "session_id": sessionId,
            "duration": duration,
            "category": category,
            "timestamp": Date().timeIntervalSince1970
        ])
    }
    
    func logMeditationProgress(sessionId: String, progressPercent: Double) {
        Analytics.logEvent("meditation_progress", parameters: [
            "session_id": sessionId,
            "progress_percent": progressPercent,
            "timestamp": Date().timeIntervalSince1970
        ])
    }
    
    // MARK: - Progress Sync
    
    func syncProgress(for userId: String, progress: [String: Any]) async throws {
        let db = Firestore.firestore()
        try await db.collection("users").document(userId).setData([
            "progress": progress,
            "lastUpdated": FieldValue.serverTimestamp()
        ], merge: true)
    }
    
    func fetchProgress(for userId: String) async throws -> [String: Any] {
        let db = Firestore.firestore()
        let snapshot = try await db.collection("users").document(userId).getDocument()
        return snapshot.data()?["progress"] as? [String: Any] ?? [:]
    }
    
    // MARK: - User Data
    
    func updateUserData(userId: String, field: String, value: Any) async throws {
        // Use transaction to ensure atomic update
        try await firestore.runTransaction({ (transaction, errorPointer) -> Any? in
            let docRef = self.firestore.collection("users").document(userId)
            let _ = try transaction.getDocument(docRef)
            
            transaction.setData([
                field: value,
                "lastUpdated": FieldValue.serverTimestamp()
            ], forDocument: docRef, merge: true)
            
            return nil
        })
    }
    
    func fetchUserData(userId: String) async throws -> [String: Any] {
        let snapshot = try await firestore.collection("users").document(userId).getDocument()
        return snapshot.data() ?? [:]
    }
    
    // MARK: - Subscription Analytics
    
    func logSubscriptionStarted(productId: String, isTrial: Bool = false) {
        Analytics.logEvent("subscription_started", parameters: [
            "product_id": productId,
            "is_trial": isTrial,
            "timestamp": Date().timeIntervalSince1970
        ])
    }
    
    func logSubscriptionRenewed(productId: String) {
        Analytics.logEvent("subscription_renewed", parameters: [
            AnalyticsParameterItemID: productId,
            AnalyticsParameterItemName: "Premium Subscription"
        ])
    }
    
    func logSubscriptionCancelled(productId: String) {
        Analytics.logEvent("subscription_cancelled", parameters: [
            "product_id": productId,
            "timestamp": Date().timeIntervalSince1970
        ])
    }
    
    func logTrialStarted(productId: String) {
        Analytics.logEvent("trial_started", parameters: [
            "product_id": productId,
            "timestamp": Date().timeIntervalSince1970
        ])
    }
    
    func logTrialConverted(productId: String) {
        Analytics.logEvent("trial_converted", parameters: [
            "product_id": productId,
            "timestamp": Date().timeIntervalSince1970
        ])
    }
    
    func logTrialCancelled(productId: String) {
        Analytics.logEvent("trial_cancelled", parameters: [
            "product_id": productId,
            "timestamp": Date().timeIntervalSince1970
        ])
    }
    
    func logPaywallImpression(source: String) {
        Analytics.logEvent("paywall_viewed", parameters: [
            "source": source,
            "timestamp": Date().timeIntervalSince1970
        ])
    }
}
