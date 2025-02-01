
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
    private var totalSessionListenTime: TimeInterval = 0
    
    private var appLaunchCount: Int = 0
    private var lastRatingDialogDate: Date?
    
    private let appLaunchCountKey = "appLaunchCount"
    private let lastRatingDialogDateKey = "lastRatingDialogDate"
    
    private init() {
        loadDataOnAppLaunch()
        checkRatingDialog()
        incrementAppLaunchCount()
    }
    
    func audioSessionStarted() {
        audioStartTime = Date()
    }
    
    func audioSessionEnded() {
        guard let startTime = audioStartTime else {
            return
        }
        let endTime = Date()
        totalSessionListenTime = endTime.timeIntervalSince(startTime) + totalSessionListenTime
        audioStartTime = nil
        checkRatingDialog()
    }
    
    private func checkRatingDialog() {
//        let isEngoughListenTime = totalSessionListenTime >= 10 * 60
        let isEngoughListenTime = true
//        let isAppLaunchCountSufficient = appLaunchCount >= 3
        let isAppLaunchCountSufficient = true
        if let lastRatingDate = lastRatingDialogDate, lastRatingDate < .now, isAppLaunchCountSufficient {
            setRatingDialogShown()
        } else if isEngoughListenTime, isAppLaunchCountSufficient {
            setRatingDialogShown()
        }
    }
    
    private func incrementAppLaunchCount() {
        appLaunchCount += 1
        UserDefaults.standard.set(appLaunchCount, forKey: appLaunchCountKey)
    }
    
    private func loadDataOnAppLaunch() {
        appLaunchCount = UserDefaults.standard.integer(forKey: appLaunchCountKey)
        if let date = UserDefaults.standard.object(forKey: lastRatingDialogDateKey) as? Date {
            lastRatingDialogDate = date
        }
    }
    
    private func setRatingDialogShown() {
        showRaitnsDialog.send()
        lastRatingDialogDate = Date()
        UserDefaults.standard.set(lastRatingDialogDate, forKey: lastRatingDialogDateKey)
    }
}
