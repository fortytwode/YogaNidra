import Foundation

struct SessionProgress: Codable {
    var startTime: Date
    var duration: TimeInterval
    var completed: Bool
    var lastCompleted: Date?
    var completionCount: Int
    var totalTimeListened: TimeInterval
    
    init(
        startTime: Date = Date(),
        duration: TimeInterval = 0,
        completed: Bool = false,
        lastCompleted: Date? = nil,
        completionCount: Int = 0,
        totalTimeListened: TimeInterval = 0
    ) {
        self.startTime = startTime
        self.duration = duration
        self.completed = completed
        self.lastCompleted = lastCompleted
        self.completionCount = completionCount
        self.totalTimeListened = totalTimeListened
    }
}