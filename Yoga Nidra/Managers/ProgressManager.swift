
import Foundation
import Combine

@MainActor
final class ProgressManager: ObservableObject {
    static let shared = ProgressManager()
    
    // Progress data keys
    let appLaunchCountKey = "appLaunchCount"
    let lastSessionDateKey = "lastSessionDateKey"
    let streakCountKey = "streakCountKey"
    let lastRatingDialogDateKey = "lastRatingDialogDate"
    let totalSessionListenTimeKey = "totalSessionListenTimeKey"
    let totalSessionsCompletedKey = "totalSessionsCompletedKey"
    
    // Rating Dialog
    private var showRaitnsDialog = PassthroughSubject<Void, Never>()
    var showRaitnsDialogPublisher: AnyPublisher<Void, Never> {
        showRaitnsDialog.eraseToAnyPublisher()
    }
    
    private var audioSessionStartTime: Date?
    private var appLaunchCount: Int = 0
    private var totalSessionListenTime: TimeInterval = 0
    private var lastRatingDialogDate: Date?
    
    private init() {
        loadDataOnAppLaunch()
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
        let totalSessionsCompleted = UserDefaults.standard.integer(forKey: totalSessionsCompletedKey) + 1
        UserDefaults.standard.set(totalSessionsCompleted, forKey: totalSessionsCompletedKey)
        
        let today = Calendar.current.startOfDay(for: Date()) // Normalize to 00:00
        let lastSessionDate = UserDefaults.standard.object(forKey: lastSessionDateKey) as? Date
        
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
        UserDefaults.standard.set(today, forKey: lastSessionDateKey)
    }
    
    private func incrementStreak() {
        let newStreak = UserDefaults.standard.integer(forKey: streakCountKey) + 1
        UserDefaults.standard.set(newStreak, forKey: streakCountKey)
    }
    
    private func resetStreak() {
        UserDefaults.standard.set(1, forKey: streakCountKey) // Start fresh from 1
    }
    
    func audioSessionStarted() {
        audioSessionStartTime = Date()
    }
    
    func audioSessionEnded() {
        guard let startTime = audioSessionStartTime else { return }
        audioSessionStartTime = nil
        let endTime = Date()
        let totalListenTime = endTime.timeIntervalSince(startTime) + totalSessionListenTime
        setTotalSessionListenTime(totalListenTime)
        checkRatingDialog()
    }
    
    private func checkRatingDialog() {
        let isEngoughListenTime = totalSessionListenTime >= 10 * 60
        let isAppLaunchCountSufficient = appLaunchCount >= 3
        let isRatingDialogCoolDownPassed = lastRatingDialogDate?.isAtLeastDaysApart(from: .now, days: 3) ?? true
        if isEngoughListenTime, isAppLaunchCountSufficient, isRatingDialogCoolDownPassed {
            setRatingDialogShown()
        }
    }
    
    private func setTotalSessionListenTime(_ time: TimeInterval) {
        totalSessionListenTime = time
        UserDefaults.standard.set(time, forKey: totalSessionListenTimeKey)
    }
    
    private func setAppLaunchCount() {
        appLaunchCount += 1
        UserDefaults.standard.set(appLaunchCount, forKey: appLaunchCountKey)
    }
    
    private func setRatingDialogShown() {
        showRaitnsDialog.send()
        lastRatingDialogDate = Date()
        UserDefaults.standard.set(lastRatingDialogDate, forKey: lastRatingDialogDateKey)
    }
    
    private func loadDataOnAppLaunch() {
        appLaunchCount = UserDefaults.standard.integer(forKey: appLaunchCountKey)
        if let date = UserDefaults.standard.object(forKey: lastRatingDialogDateKey) as? Date {
            lastRatingDialogDate = date
        }
        if let listeningTime = UserDefaults.standard.object(forKey: totalSessionListenTimeKey) as? TimeInterval {
            totalSessionListenTime = listeningTime
        }
    }
}
