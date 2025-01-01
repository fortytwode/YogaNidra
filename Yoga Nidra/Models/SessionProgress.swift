import Foundation

struct SessionProgress: Codable {
    var completionCount: Int = 0
    var totalTimeListened: TimeInterval = 0
    var lastCompleted: Date?
    
    init(completionCount: Int = 0, totalTimeListened: TimeInterval = 0, lastCompleted: Date? = nil) {
        self.completionCount = completionCount
        self.totalTimeListened = totalTimeListened
        self.lastCompleted = lastCompleted
    }
} 