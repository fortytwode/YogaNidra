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
    
    private init() {
        configureFirestore()
    }
    
    private func configureFirestore() {
        let settings = FirestoreSettings()
        // Use memory-only cache
        settings.cacheSettings = MemoryCacheSettings(garbageCollectorSettings: MemoryLRUGCSettings())
        // Use persistent disk cache, with 100 MB cache size
        settings.cacheSettings = PersistentCacheSettings(sizeBytes: 100 * 1024 * 1024 as NSNumber)
        firestore.settings = settings
    }
    
    // MARK: - Storage Methods
    
    /// Downloads the URL for a meditation file
    /// - Parameter fileName: Name of the meditation file in Firebase Storage
    /// - Returns: A downloadable URL for the meditation file
    func getMeditationURL(fileFolder: String?, fileName: String) async throws -> URL {
        guard !fileName.isEmpty else {
            throw FirebaseError.fileNotFound
        }
        
        var rootRef = meditationsRef
        if let fileFolder {
            let parts = fileFolder.split(separator: "/")
            parts.forEach { path in
                if !path.isEmpty {
                    rootRef = rootRef.child(String(path))
                }
            }
        }
        let fileRef = rootRef.child(fileName)
        
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
    
    func logRatingPromtShown() {
        Analytics.logEvent("rating_prompt_shown", parameters: [
            "timestamp": Date().timeIntervalSince1970
        ])
    }
}

// MARK: User progress tracking
extension FirebaseManager {
    
    func getUserDocument() async -> DocumentReference? {
        guard let userId = AuthManager.shared.currentUserId else { return nil }
        let userRef = firestore.collection(StroageKeys.usersCollectionKey).document(userId)
        do {
            let document = try await userRef.getDocument()
            if !document.exists {
                try await userRef.setData([:])
                print("User document created.")
            }
        } catch {
            print("Error checking/creating document: \(error.localizedDescription)")
        }
        return userRef
    }
    
    func getUserStreaks() async -> Int {
        let document = try? await getUserDocument()?.getDocument()
        return document?.data()?[StroageKeys.streakCountKey] as? Int ?? 0
    }
    
    func getTotalListenedTime() async -> Double {
        let document = try? await getUserDocument()?.getDocument()
        return document?.data()?[StroageKeys.totalSessionListenTimeKey] as? Double ?? 0
    }
    
    func getCompletedSessionsCount() async -> Int {
        let document = try? await getUserDocument()?.getDocument()
        return document?.data()?[StroageKeys.totalSessionsCompletedKey] as? Int ?? 0
    }
    
    func setTotalListenedTime(time: TimeInterval) async {
        let data = [
            StroageKeys.totalSessionListenTimeKey: time
        ]
        try? await getUserDocument()?.updateData(data)
    }
    
    func setUserStreaks(count: Int) async {
        let data = [
            StroageKeys.streakCountKey: count
        ]
        try? await getUserDocument()?.updateData(data)
    }
    
    func setCompletedSessionsCount(count: Int) async {
        let data = [
            StroageKeys.totalSessionsCompletedKey: count
        ]
        try? await getUserDocument()?.updateData(data)
    }
    
    func getRecentSessions() async -> [RecentSessionItem] {
        guard let userDocument = await getUserDocument() else { return [] }
        let sessions = YogaNidraSession.allSessions + YogaNidraSession.specialEventSessions
        do {
            let sessionsSnapshot = try await userDocument.collection(StroageKeys.recentsSessionsKey).getDocuments()
            let recentSessionsArray: [RecentSessionItem] = sessionsSnapshot.documents.compactMap { document in
                guard let sessionId = document["sessionId"] as? String,
                      let lastCompleted = document["lastCompleted"] as? Timestamp else {
                    return nil
                }
                guard let session = sessions.first(where: { $0.id == sessionId }) else {
                    return nil
                }
                return RecentSessionItem(session: session, lastCompleted: lastCompleted.dateValue())
            }
            return recentSessionsArray.sorted(by: { $0.lastCompleted > $1.lastCompleted })
        } catch {
            print("Error fetching recent sessions: \(error.localizedDescription)")
            return []
        }
    }
    
    func setRecentSessions(withNew session: YogaNidraSession, recentSessions: [RecentSessionItem]) async -> [RecentSessionItem] {
        guard let userDocument = await getUserDocument() else { return [] }
        let sessionCollection = userDocument.collection(StroageKeys.recentsSessionsKey)
        
        var recentSessions = Array(Set(recentSessions))
        do {
            let existingDocuments = try await sessionCollection.getDocuments()
            for document in existingDocuments.documents {
                try await sessionCollection.document(document.documentID).delete()
            }
            
            // Ensure we only store the latest 2 sessions
            recentSessions.insert(RecentSessionItem(session: session, lastCompleted: Date()), at: 0)
            if recentSessions.count > 10 {
                recentSessions.removeLast() // Remove the oldest session
            }
            // Store all recent sessions as separate documents
            for recentSession in recentSessions {
                let sessionData: [String: Any] = [
                    "sessionId": recentSession.session.id,
                    "lastCompleted": Timestamp(date: recentSession.lastCompleted)
                ]
                
                let documentRef = sessionCollection.document(recentSession.session.id)
                try await documentRef.setData(sessionData) // Overwrites if exists
            }
            return recentSessions
        } catch {
            print("Error storing recent sessions: \(error.localizedDescription)")
            return []
        }
    }
    
    func syncProgress() async {
        Task {
            if !Defaults.bool(forKey: StroageKeys.isLaunchedBefore) {
                await setUserStreaks(count: 0)
                UserDefaults.standard.set(true, forKey: StroageKeys.isLaunchedBefore)
            }
            await Defaults.set(getUserStreaks(), forKey: StroageKeys.streakCountKey)
            await Defaults.set(getTotalListenedTime(), forKey: StroageKeys.totalSessionListenTimeKey)
            await Defaults.set(getCompletedSessionsCount(), forKey: StroageKeys.totalSessionsCompletedKey)
        }
    }
}
