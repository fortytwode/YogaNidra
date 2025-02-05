import Foundation
import Combine

final class ProgressManager: ObservableObject {
    static let shared = ProgressManager()
    
    #if DEBUG
    static var preview: ProgressManager {
        let manager = ProgressManager()
        manager.streakDays = 5
        manager.totalMinutesListened = 120
        manager.sessionsCompleted = 8
        manager.progress = 0.75
        return manager
    }
    #endif
    
    @Published var streakDays: Int = 0
    @Published var totalMinutesListened: Int = 0
    @Published var sessionsCompleted: Int = 0 {
        didSet {
            checkRatingDialog()
        }
    }
    @Published var progress: Double = 0
    @Published var sessionProgress: [UUID: SessionProgress] = [:]
    
    @Published private(set) var currentStreak: Int = 0
    @Published private(set) var totalTimeListened: TimeInterval = 0
    @Published private(set) var recentSessions: [(YogaNidraSession, SessionProgress)] = []
    
    // Rating Dialog
    @Published var showRaitnsDialog = PassthroughSubject<Void, Never>()
    var showRaitnsDialogPublisher: AnyPublisher<Void, Never> {
        showRaitnsDialog.eraseToAnyPublisher()
    }
    
    @Published var audioStartTime: Date?
    @Published var totalSessionListenTime: TimeInterval = 0
    @Published var lastRatingDialogDate: Date?
    
    private let lastRatingDialogDateKey = "lastRatingDialogDate"
    private let totalSessionListenTimeKey = "totalSessionListenTime"
    private let ratingPromptsInYearKey = "ratingPromptsInYear"
    private let ratingYearStartDateKey = "ratingYearStartDate"
    
    // Made public for debug view
    public private(set) var ratingPromptsInYear: Int = 0
    public private(set) var ratingYearStartDate: Date?
    
    private init() {
        loadDataOnAppLaunch()
        checkRatingDialog()
        loadProgressFromFirebase()
    }
    
    @MainActor
    func audioSessionStarted() {
        guard let currentSession = AudioManager.shared.currentPlayingSession else { return }
        
        // Log analytics
        FirebaseManager.shared.logMeditationStarted(
            sessionId: currentSession.id.uuidString,
            duration: TimeInterval(currentSession.duration),
            category: String(describing: currentSession.category)
        )
        
        // Update local progress
        sessionProgress[currentSession.id] = SessionProgress(
            startTime: Date(),
            duration: 0,
            completed: false
        )
        syncProgress()
    }
    
    @MainActor
    func audioSessionEnded() {
        guard let currentSession = AudioManager.shared.currentPlayingSession,
              var progress = sessionProgress[currentSession.id] else { return }
        
        let duration = Date().timeIntervalSince(progress.startTime)
        let progressPercent = duration / TimeInterval(currentSession.duration)
        
        // Log analytics
        if progressPercent >= 0.9 { // Consider it completed if 90% done
            FirebaseManager.shared.logMeditationCompleted(
                sessionId: currentSession.id.uuidString,
                duration: duration,
                category: String(describing: currentSession.category)
            )
            
            progress.completed = true
            progress.lastCompleted = Date()
            progress.completionCount += 1
        }
        
        FirebaseManager.shared.logMeditationProgress(
            sessionId: currentSession.id.uuidString,
            progressPercent: progressPercent
        )
        
        // Update local progress
        progress.duration = duration
        sessionProgress[currentSession.id] = progress
        
        // Update metrics
        updateTotalTimeListened()
        updateStreak()
        syncProgress()
    }
    
    @MainActor
    func audioSessionCompleted() {
        guard let currentSession = AudioManager.shared.currentPlayingSession,
              let progress = sessionProgress[currentSession.id] else { return }
        
        let duration = progress.duration
        totalTimeListened += duration
        
        if duration >= Double(currentSession.duration) * 0.9 {
            sessionsCompleted += 1
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "lastCompletedDate")
            updateStreak()
        }
        
        updateRecentSessions()
        
        // Sync with Firebase
        Task { @MainActor in
            if let userId = await AuthManager.shared.currentUserId {
                do {
                    try await FirebaseManager.shared.syncProgress(for: userId, progress: progressDictionary())
                } catch {
                    print("❌ Failed to sync progress: \(error)")
                }
            }
        }
    }
    
    private func progressDictionary() -> [String: Any] {
        [
//            "sessions": sessionProgress.mapValues { progress in
//                [
//                    "startTime": progress.startTime.timeIntervalSince1970,
//                    "duration": progress.duration,
//                    "completed": progress.completed
//                ]
//            },
            "metrics": [
                "totalTimeListened": totalTimeListened,
                "sessionsCompleted": sessionsCompleted,
                "currentStreak": currentStreak,
                "lastCompletedDate": UserDefaults.standard.double(forKey: "lastCompletedDate")
            ]
        ]
    }
    
    private func loadProgressFromFirebase() {
        Task { @MainActor in
            if let userId = await AuthManager.shared.currentUserId {
                do {
                    let progress = try await FirebaseManager.shared.fetchProgress(for: userId)
                    await MainActor.run {
                        // Load session progress
                        if let sessions = progress["sessions"] as? [String: [String: Any]] {
                            sessionProgress.removeAll()
                            for (sessionId, data) in sessions {
                                if let startTimeInterval = data["startTime"] as? TimeInterval,
                                   let duration = data["duration"] as? TimeInterval,
                                   let completed = data["completed"] as? Bool {
                                    let startTime = Date(timeIntervalSince1970: startTimeInterval)
                                    sessionProgress[UUID(uuidString: sessionId)!] = SessionProgress(startTime: startTime, duration: duration, completed: completed)
                                }
                            }
                        }
                        
                        // Load metrics
                        if let metrics = progress["metrics"] as? [String: Any] {
                            totalTimeListened = metrics["totalTimeListened"] as? TimeInterval ?? 0
                            sessionsCompleted = metrics["sessionsCompleted"] as? Int ?? 0
                            currentStreak = metrics["currentStreak"] as? Int ?? 0
                            if let lastCompletedDate = metrics["lastCompletedDate"] as? TimeInterval {
                                UserDefaults.standard.set(lastCompletedDate, forKey: "lastCompletedDate")
                            }
                        }
                        
                        updateRecentSessions()
                        updateStreak()
                        updateTotalTimeListened()
                    }
                } catch {
                    print("❌ Failed to load progress: \(error)")
                }
            }
        }
    }
    
    private func updateStreak() {
        let calendar = Calendar.current
        let lastCompletedDate = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: "lastCompletedDate"))
        let today = Date()
        
        guard let daysBetween = calendar.dateComponents([.day], from: lastCompletedDate, to: today).day else {
            currentStreak = 0
            return
        }
        
        if daysBetween > 1 {
            currentStreak = 0
        }
    }
    
    private func updateRecentSessions() {
        // First, filter and map sessions
        let sessionsWithProgress = sessionProgress.compactMap { id, progress -> (YogaNidraSession, SessionProgress)? in
            guard let session = YogaNidraSession.previewData.first(where: { $0.id == id }) else {
                return nil
            }
            return (session, progress)
        }
        
        // Then sort by completion date
        let sortedSessions = sessionsWithProgress.sorted { 
            $0.1.lastCompleted ?? .distantPast > $1.1.lastCompleted ?? .distantPast 
        }
        
        // Finally, take the first 5 sessions
        recentSessions = sortedSessions.prefix(5).map { ($0.0, $0.1) }
    }
    
    private func updateTotalTimeListened() {
        totalTimeListened = sessionProgress.values
            .filter { $0.completed }
            .reduce(0) { $0 + $1.duration }
        
        totalMinutesListened = Int(totalTimeListened / 60.0)
    }
    
    private func getCooldownDays() -> Int {
        switch ratingPromptsInYear {
            case 0: return 14  // First prompt: 2 weeks
            case 1: return 30  // Second prompt: 30 days
            default: return 365 // Third prompt: 1 year
        }
    }
    
    private func checkRatingDialog() {
        // Reset year counter if needed
        if let yearStart = ratingYearStartDate {
            if !Calendar.current.isDate(yearStart, equalTo: .now, toGranularity: .year) {
                ratingPromptsInYear = 0
                ratingYearStartDate = .now
                UserDefaults.standard.set(0, forKey: ratingPromptsInYearKey)
                UserDefaults.standard.set(Date(), forKey: ratingYearStartDateKey)
            }
        } else {
            ratingYearStartDate = .now
            UserDefaults.standard.set(Date(), forKey: ratingYearStartDateKey)
        }
        
        // Only proceed if we haven't hit the yearly limit
        guard ratingPromptsInYear < 3 else { return }
        
        let hasCompletedSession = sessionsCompleted > 0
        let cooldownDays = getCooldownDays()
        let isRatingDialogCoolDownPassed = lastRatingDialogDate?.isAtLeastDaysApart(from: .now, days: cooldownDays) ?? true
        
        if hasCompletedSession, isRatingDialogCoolDownPassed {
            setRatingDialogShown()
        }
    }
    
    private func setRatingDialogShown() {
        lastRatingDialogDate = .now
        UserDefaults.standard.set(Date(), forKey: lastRatingDialogDateKey)
        
        ratingPromptsInYear += 1
        UserDefaults.standard.set(ratingPromptsInYear, forKey: ratingPromptsInYearKey)
    }
    
    public func setTotalSessionListenTime(_ time: TimeInterval) {
        totalSessionListenTime = time
        UserDefaults.standard.set(time, forKey: totalSessionListenTimeKey)
    }
    
    public func setLastRatingDialogDate(_ date: Date) {
        lastRatingDialogDate = date
        UserDefaults.standard.set(date, forKey: lastRatingDialogDateKey)
    }
    
    public func resetRatingState() {
        setTotalSessionListenTime(0)
        lastRatingDialogDate = nil
        ratingPromptsInYear = 0
        ratingYearStartDate = nil
        UserDefaults.standard.removeObject(forKey: lastRatingDialogDateKey)
        UserDefaults.standard.removeObject(forKey: ratingPromptsInYearKey)
        UserDefaults.standard.removeObject(forKey: ratingYearStartDateKey)
    }
    
    private func loadDataOnAppLaunch() {
        lastRatingDialogDate = UserDefaults.standard.object(forKey: lastRatingDialogDateKey) as? Date
        totalSessionListenTime = UserDefaults.standard.double(forKey: totalSessionListenTimeKey)
        ratingPromptsInYear = UserDefaults.standard.integer(forKey: ratingPromptsInYearKey)
        ratingYearStartDate = UserDefaults.standard.object(forKey: ratingYearStartDateKey) as? Date
        checkRatingDialog()
    }
    
    @MainActor
    private func syncProgress() {
        Task { @MainActor in
            if let userId = await AuthManager.shared.currentUserId {
                do {
                    try await FirebaseManager.shared.syncProgress(for: userId, progress: progressDictionary())
                } catch {
                    print("❌ Failed to sync progress: \(error)")
                }
            }
        }
    }
    
    // MARK: - Debug Methods
    
    // Removed debug methods
}
