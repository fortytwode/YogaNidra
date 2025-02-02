
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
}
