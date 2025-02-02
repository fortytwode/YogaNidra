
import Foundation
import Combine

final class ProgressManager: ObservableObject {
    static let shared = ProgressManager()
    
    @Published var streakDays: Int = 0
    @Published var totalMinutesListened: Int = 0
    @Published var sessionsCompleted: Int = 0
    @Published var progress: Double = 0
    @Published var sessionProgress: [UUID: SessionProgress] = [:]
    
    // Rating Dialog
    private var showRaitnsDialog = PassthroughSubject<Void, Never>()
    var showRaitnsDialogPublisher: AnyPublisher<Void, Never> {
        showRaitnsDialog.eraseToAnyPublisher()
    }
    
    private var audioStartTime: Date?
    private var appLaunchCount: Int = 0
    private var totalSessionListenTime: TimeInterval = 0
    private var lastRatingDialogDate: Date?
    
    private let appLaunchCountKey = "appLaunchCount"
    private let lastRatingDialogDateKey = "lastRatingDialogDate"
    private let totalSessionListenTimeKey = "totalSessionListenTimeKey"
    
    private init() {
        loadDataOnAppLaunch()
        setAppLaunchCount()
        checkRatingDialog()
    }
    
    func audioSessionStarted() {
        audioStartTime = Date()
    }
    
    func audioSessionEnded() {
        guard let startTime = audioStartTime else { return }
        audioStartTime = nil
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
