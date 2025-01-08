import Foundation

class ProgressManager: ObservableObject {
    static let shared = ProgressManager()
    
    @Published var progress: Double = 0
    @Published var sessionProgress: [UUID: SessionProgress] = [:]
    
    // Stats properties
    @Published private(set) var totalMinutesListened: Int = 0
    @Published private(set) var sessionsCompleted: Int = 0
    @Published private(set) var streakDays: Int = 0
    
    private var lastSessionDate: Date?
    
    private init() {
        // Load saved progress data here if needed
        updateStreak()
    }
    
    func updateProgress(currentTime: TimeInterval, duration: Int) {
        let durationInterval = TimeInterval(duration)
        progress = currentTime / durationInterval
    }
    
    func resetProgress() {
        progress = 0
    }
    
    func updateSessionStats(session: YogaNidraSession, timeListened: TimeInterval) {
        // Update total time
        totalMinutesListened = Int(timeListened / 60)
        
        // Update session progress
        var progress = sessionProgress[session.id] ?? SessionProgress()
        progress.totalTimeListened += timeListened
        progress.completionCount += 1
        progress.lastCompleted = Date()
        sessionProgress[session.id] = progress
        
        // Update total sessions completed
        sessionsCompleted = sessionProgress.values.reduce(0) { $0 + $1.completionCount }
        
        // Update streak
        lastSessionDate = Date()
        updateStreak()
    }
    
    private func updateStreak() {
        guard let lastDate = lastSessionDate else {
            streakDays = 0
            return
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastSessionDay = calendar.startOfDay(for: lastDate)
        
        if calendar.isDateInToday(lastSessionDay) {
            // Session completed today, increment or maintain streak
            if streakDays == 0 {
                streakDays = 1
            }
        } else if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
                  calendar.isDate(lastSessionDay, inSameDayAs: yesterday) {
            // Session was yesterday, maintain streak
            if streakDays == 0 {
                streakDays = 2
            }
        } else if calendar.dateComponents([.day], from: lastSessionDay, to: today).day ?? 0 > 1 {
            // Streak broken
            streakDays = 0
        }
    }
} 