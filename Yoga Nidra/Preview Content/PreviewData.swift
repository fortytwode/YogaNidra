import Foundation

class PreviewData {
    static func loadSessions() -> [YogaNidraSession] {
        guard let path = Bundle.main.path(forResource: "sessions", ofType: "csv") else {
            print("❌ Could not find sessions.csv")
            return []
        }
        
        do {
            let data = try String(contentsOfFile: path, encoding: .utf8)
            var sessions: [YogaNidraSession] = []
            
            let rows = data.components(separatedBy: "\n").dropFirst() // Skip header
            for row in rows where !row.isEmpty {
                let columns = row.components(separatedBy: ",")
                if columns.count >= 6 {
                    // Randomly assign premium status for testing
                    let isPremium = Bool.random()
                    
                    // Map category string to enum case
                    let categoryString = columns[2].trimmingCharacters(in: .whitespaces)
                    let category = SessionCategory(rawValue: categoryString) ?? .quickSleep // Default to quickSleep if not found
                    
                    let session = YogaNidraSession(
                        title: columns[0],
                        duration: Int(columns[1]) ?? 0,
                        category: category,
                        audioFileName: columns[3],
                        thumbnailUrl: columns[4],
                        isPremium: isPremium,
                        instructor: columns[5]
                    )
                    sessions.append(session)
                }
            }
            
            print("📚 Found \(sessions.count) sessions in CSV")
            return sessions
            
        } catch {
            print("❌ Error loading sessions:", error)
            return []
        }
    }
} 