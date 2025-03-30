import Foundation
import Combine

@MainActor
final class ProgressManager: ObservableObject {
    static let shared = ProgressManager()
    
    @Published var recentSessions: [RecentSessionItem] = []
    
    // Rating Dialog
    private var showRaitnsDialog = PassthroughSubject<Void, Never>()
    var showRaitnsDialogPublisher: AnyPublisher<Void, Never> {
        showRaitnsDialog.eraseToAnyPublisher()
    }
    
    private var audioSessionStartTime: Date?
    private var appLaunchCount: Int {
        Defaults.integer(forKey: StroageKeys.appLaunchCountKey)
    }
    private var totalSessionListenTime: TimeInterval {
        Defaults.object(forKey: StroageKeys.totalSessionListenTimeKey) as? TimeInterval ?? 0
    }
    private var lastRatingDialogDate: Date? {
        Defaults.object(forKey: StroageKeys.lastRatingDialogDateKey) as? Date
    }
    
    private init() {
        Task {
            await FirebaseManager.shared.syncProgress()
            recentSessions = await FirebaseManager.shared.getRecentSessions()
        }
        setAppLaunchCount()
        checkRatingDialog()
        
        // Add observer for playback completion
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePlaybackFinished),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func handlePlaybackFinished() {
        guard OnboardingManager.shared.isOnboardingCompleted else { return }
        audioSessionEnded()
        let totalSessionsCompleted = Defaults.integer(forKey: StroageKeys.totalSessionsCompletedKey) + 1
        Defaults.set(totalSessionsCompleted, forKey: StroageKeys.totalSessionsCompletedKey)
        Task {
            await FirebaseManager.shared.setCompletedSessionsCount(count: totalSessionsCompleted)
        }
        
        let today = Calendar.current.startOfDay(for: Date()) // Normalize to 00:00
        let lastSessionDate = Defaults.object(forKey: StroageKeys.lastSessionDateKey) as? Date
        
        if let lastSessionDate = lastSessionDate {
            let difference = Calendar.current.dateComponents([.day], from: lastSessionDate, to: today).day ?? 0
            if difference == 0 {
                // Already recorded today, do nothing
                return
            } else if difference == 1 {
                // Continue streak
                incrementStreak()
            } else {
                // Streak broken, reset
                resetStreak()
            }
        } else {
            // First session ever
            resetStreak()
        }
        
        // Save today's date as last session date
        Defaults.set(today, forKey: StroageKeys.lastSessionDateKey)
    }
    
    private func incrementStreak() {
        let newStreak = Defaults.integer(forKey: StroageKeys.streakCountKey) + 1
        Defaults.set(newStreak, forKey: StroageKeys.streakCountKey)
        Task {
            await FirebaseManager.shared.setUserStreaks(count: newStreak)
        }
    }
    
    private func resetStreak() {
        Defaults.set(1, forKey: StroageKeys.streakCountKey) // Start fresh from 1
        Task {
            await FirebaseManager.shared.setUserStreaks(count: 1)
        }
    }
    
    func audioSessionStarted(session: YogaNidraSession?) {
        guard OnboardingManager.shared.isOnboardingCompleted, let session else { return }
        addRecentSession(session: session)
        audioSessionStartTime = Date()
    }
    
    func audioSessionEnded() {
        guard OnboardingManager.shared.isOnboardingCompleted,
              let startTime = audioSessionStartTime else { return }
        audioSessionStartTime = nil
        let endTime = Date()
        let totalListenTime = endTime.timeIntervalSince(startTime) + totalSessionListenTime
        setTotalSessionListenTime(totalListenTime)
        checkRatingDialog()
    }
    
    private func checkRatingDialog() {
        let isEngoughListenTime = totalSessionListenTime >= 10 * 60
        let isAppLaunchCountSufficient = appLaunchCount >= 1
        let isRatingDialogCoolDownPassed = lastRatingDialogDate?.isAtLeastDaysApart(from: .now, days: 3) ?? true
        if isEngoughListenTime, isAppLaunchCountSufficient, isRatingDialogCoolDownPassed {
            setRatingDialogShown()
        }
    }
    
    private func setTotalSessionListenTime(_ time: TimeInterval) {
        Defaults.set(time, forKey: StroageKeys.totalSessionListenTimeKey)
        Task {
            await FirebaseManager.shared.setTotalListenedTime(time: time)
        }
    }
    
    private func setAppLaunchCount() {
        Defaults.set(appLaunchCount + 1, forKey: StroageKeys.appLaunchCountKey)
    }
    
    private func setRatingDialogShown() {
        guard !Defaults.bool(forKey: StroageKeys.isAppRated) else { return }
        FirebaseManager.shared.logAppRatingPromtShown()
        showRaitnsDialog.send()
        Defaults.set(Date(), forKey: StroageKeys.lastRatingDialogDateKey)
    }
    
    private func addRecentSession(session: YogaNidraSession) {
        Task {
            recentSessions = await FirebaseManager.shared.setRecentSessions(
                withNew: session,
                recentSessions: recentSessions
            )
        }
    }
}
