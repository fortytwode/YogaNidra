
import Foundation

extension Date {
    
    func isAtLeastDaysApart(from date: Date, days: Int) -> Bool {
        let calendar = Calendar.current
        
        // Ensure both dates are at the start of the day to not consider the time
        let startOfDay1 = calendar.startOfDay(for: self)
        let startOfDay2 = calendar.startOfDay(for: date)
        
        // Calculate the difference in days
        let components = calendar.dateComponents([.day], from: startOfDay1, to: startOfDay2)
        
        if let dayDifference = components.day {
            // Check if the absolute difference is at least the specified number of days
            return abs(dayDifference) >= days
        } else {
            // Unable to calculate difference
            return false
        }
    }
    
    static func todayAt10PM() -> Date {
        let calendar = Calendar.current
        let now = Date()

        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = 22 // 10 PM in 24-hour format
        components.minute = 0
        components.second = 0

        return calendar.date(from: components) ?? .now
    }
}
