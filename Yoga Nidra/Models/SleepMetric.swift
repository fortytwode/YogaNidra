import Foundation

struct SleepMetric: Identifiable {
    let id: UUID = UUID()
    let name: String
    let value: Double
    
    static let indices = Array(0..<5)
} 