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
    
    // MARK: - Debug Methods
    
    // Removed debug methods
}
