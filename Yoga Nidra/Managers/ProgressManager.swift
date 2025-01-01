import Foundation

class ProgressManager: ObservableObject {
    @Published var totalMinutesListened: Int = 0
    @Published var sessionsCompleted: Int = 0
    @Published var streakDays: Int = 0
    @Published var lastCompletedDate: Date?
    @Published var sessionProgress: [UUID: SessionProgress] = [:]
    
    static let shared = ProgressManager()
    
    private init() {
        // Load saved progress data here when we implement persistence
    }
    
    func updateProgress(for session: YogaNidraSession, timeListened: TimeInterval) {
        // Create new progress instance with updated values
        var currentProgress = sessionProgress[session.id] ?? SessionProgress()
        currentProgress.totalTimeListened += timeListened
        
        if timeListened >= (session.duration * 0.9) { // Consider session complete if 90% listened
            currentProgress.completionCount += 1
            currentProgress.lastCompleted = Date()
            sessionsCompleted += 1
            lastCompletedDate = Date()
        }
        
        // Assign the new progress instance
        sessionProgress[session.id] = currentProgress
        
        // Update total minutes
        totalMinutesListened += Int(timeListened / 60)
        
        // Update streak
        updateStreak()
    }
    
    func getProgress(for session: YogaNidraSession) -> SessionProgress {
        sessionProgress[session.id] ?? SessionProgress()
    }
    
    private func updateStreak() {
        guard let lastCompleted = lastCompletedDate else {
            streakDays = 1
            return
        }
        
        let calendar = Calendar.current
        if calendar.isDateInToday(lastCompleted) {
            // Already completed today, no change needed
            return
        }
        
        if calendar.isDateInYesterday(lastCompleted) {
            // Completed yesterday, increment streak
            streakDays += 1
        } else {
            // Break in streak, reset to 1
            streakDays = 1
        }
    }
} 