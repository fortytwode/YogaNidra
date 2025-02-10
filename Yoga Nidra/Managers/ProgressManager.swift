import Foundation
import Combine

final class ProgressManager: ObservableObject {
    static let shared = ProgressManager()
    
    #if DEBUG
    static var preview: ProgressManager {
        let manager = ProgressManager()
        manager.sessionsCompleted = 5
        manager.streakDays = 3
        manager.totalTimeListened = 3600 // 1 hour
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
    @Published var lastRatingPrompt: Date?
    
    private let lastRatingDialogDateKey = "lastRatingDialogDate"
    private let totalSessionListenTimeKey = "totalSessionListenTime"
    private let ratingPromptsInYearKey = "ratingPromptsInYear"
    private let ratingYearStartDateKey = "ratingYearStartDate"
    private let lastRatingPromptKey = "lastRatingPrompt"
    private let lastCompletedDateKey = "lastCompletedDate"
    
    // Made public for debug view
    public private(set) var ratingPromptsInYear: Int = 0
    private var ratingYearStartDate: Date?
    
    private let userDefaults = UserDefaults.standard
    
    private init() {
        // Load last rating prompt date and yearly counts
        if let date = userDefaults.object(forKey: lastRatingPromptKey) as? Date {
            lastRatingPrompt = date
        }
        
        ratingPromptsInYear = userDefaults.integer(forKey: ratingPromptsInYearKey)
        if let date = userDefaults.object(forKey: ratingYearStartDateKey) as? Date {
            ratingYearStartDate = date
        }
        
        // Reset yearly count if it's been more than a year
        if let startDate = ratingYearStartDate {
            let daysSinceStart = Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0
            if daysSinceStart >= 365 {
                ratingPromptsInYear = 0
                ratingYearStartDate = Date()
                userDefaults.set(0, forKey: ratingPromptsInYearKey)
                userDefaults.set(Date(), forKey: ratingYearStartDateKey)
            }
        } else {
            ratingYearStartDate = Date()
            userDefaults.set(Date(), forKey: ratingYearStartDateKey)
        }
        
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
    
    func audioSessionEnded() {
        Task { @MainActor in
            await handleAudioSessionEnded()
        }
    }
    
    @MainActor
    private func handleAudioSessionEnded() async {
        guard let currentSession = AudioManager.shared.currentPlayingSession,
              var progress = sessionProgress[currentSession.id] else { return }
        
        let duration = Date().timeIntervalSince(progress.startTime)
        let progressPercent = duration / TimeInterval(currentSession.duration)
        
        // Mark as completed if 90% done
        if progressPercent >= 0.9 {
            await FirebaseManager.shared.logMeditationCompleted(
                sessionId: currentSession.id.uuidString,
                duration: duration,
                category: String(describing: currentSession.category)
            )
            
            progress.completed = true
            progress.lastCompleted = Date()
            progress.completionCount += 1
            
            // Only update streak for completed sessions
            updateStreak()
        }
        
        await FirebaseManager.shared.logMeditationProgress(
            sessionId: currentSession.id.uuidString,
            progressPercent: progressPercent
        )
        
        // Update local progress
        progress.duration = duration
        sessionProgress[currentSession.id] = progress
        
        // Update metrics
        updateTotalTimeListened()
        updateRecentSessions()
        await syncProgress()
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
            "sessions": Dictionary(uniqueKeysWithValues: sessionProgress.map { (key, value) in
                (key.uuidString, [
                    "startTime": value.startTime.timeIntervalSince1970,
                    "duration": value.duration,
                    "completed": value.completed,
                    "lastCompleted": value.lastCompleted?.timeIntervalSince1970 ?? 0,
                    "completionCount": value.completionCount
                ])
            }),
            "metrics": [
                "totalTimeListened": totalTimeListened,
                "sessionsCompleted": sessionsCompleted,
                "currentStreak": currentStreak,
                "streakDays": streakDays,
                "totalMinutesListened": totalMinutesListened
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
    
    @MainActor
    private func updateStreak() {
        let calendar = Calendar.current
        let lastCompletedDate = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: "lastCompletedDate"))
        let today = Date()
        
        // If this is the first completion (lastCompletedDate will be 1970)
        if lastCompletedDate.timeIntervalSince1970 == 0 {
            streakDays = 1
            return
        }
        
        guard let daysBetween = calendar.dateComponents([.day], from: lastCompletedDate, to: today).day else {
            streakDays = 0
            return
        }
        
        if daysBetween == 1 {
            // Yesterday - increment streak
            streakDays += 1
        } else if daysBetween > 1 {
            // Missed a day - reset streak
            streakDays = 1
        }
        // Same day - keep current streak
    }
    
    private func updateRecentSessions() {
        // First, filter and map sessions
        let sessionsWithProgress = sessionProgress.compactMap { id, progress -> (YogaNidraSession, SessionProgress)? in
            guard let session = YogaNidraSession.allSessions.first(where: { $0.id == id }) else {
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
        // Count all session time, not just completed sessions
        // Prevent negative durations from corrupted data
        totalTimeListened = sessionProgress.values
            .reduce(0) { $0 + max(0, $1.duration) }
        
        totalMinutesListened = Int(totalTimeListened / 60.0)
    }
    
    private func getCooldownDays() -> Int {
        switch ratingPromptsInYear {
            case 0: return 0     // First prompt: immediately after first session
            case 1: return 30    // Second prompt: 30 days
            default: return 365  // Third prompt: 1 year
        }
    }
    
    private func checkRatingDialog() {
        // Only proceed if we haven't hit the yearly limit
        guard ratingPromptsInYear < 3 else { return }
        
        let hasCompletedSession = sessionsCompleted > 0
        let cooldownDays = getCooldownDays()
        let isRatingDialogCoolDownPassed = cooldownDays == 0 ? true : 
            lastRatingDialogDate?.isAtLeastDaysApart(from: .now, days: cooldownDays) ?? true
        
        if hasCompletedSession, isRatingDialogCoolDownPassed {
            showRaitnsDialog.send()  // Trigger the rating dialog
            setRatingDialogShown()
        }
        
        if shouldShowRatingPrompt() {
            recordRatingPrompt()
        }
    }
    
    private func setRatingDialogShown() {
        lastRatingDialogDate = .now
        UserDefaults.standard.set(Date(), forKey: lastRatingDialogDateKey)
    }
    
    func shouldShowRatingPrompt() -> Bool {
        // Don't show more than 3 times in a year
        if ratingPromptsInYear >= 3 {
            return false
        }
        
        // Don't show more than once every 30 days
        if let lastPrompt = lastRatingPrompt {
            let daysSinceLastPrompt = Calendar.current.dateComponents([.day], from: lastPrompt, to: Date()).day ?? 0
            if daysSinceLastPrompt < 30 {
                return false
            }
        }
        
        // First rating prompt after completing first session
        if lastRatingPrompt == nil && sessionsCompleted == 1 {
            return true
        }
        
        // Subsequent prompts when user:
        // 1. Has completed 5 or more sessions
        // 2. Hasn't been prompted in the last 30 days
        // 3. Hasn't exceeded 3 prompts in the last 365 days
        return sessionsCompleted >= 5
    }
    
    func recordRatingPrompt() {
        lastRatingPrompt = Date()
        userDefaults.set(lastRatingPrompt, forKey: lastRatingPromptKey)
        
        // Update yearly count
        ratingPromptsInYear += 1
        userDefaults.set(ratingPromptsInYear, forKey: ratingPromptsInYearKey)
        
        // Set start date for yearly tracking if not set
        if ratingYearStartDate == nil {
            ratingYearStartDate = Date()
            userDefaults.set(Date(), forKey: ratingYearStartDateKey)
        }
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
        Task { @MainActor in
            lastRatingDialogDate = UserDefaults.standard.object(forKey: lastRatingDialogDateKey) as? Date
            totalSessionListenTime = UserDefaults.standard.double(forKey: totalSessionListenTimeKey)
            ratingPromptsInYear = UserDefaults.standard.integer(forKey: ratingPromptsInYearKey)
            ratingYearStartDate = UserDefaults.standard.object(forKey: ratingYearStartDateKey) as? Date
            await updateStreak()
        }
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
