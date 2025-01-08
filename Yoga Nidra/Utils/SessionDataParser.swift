import Foundation

class SessionDataParser {
    static func loadSessions() -> [YogaNidraSession] {
        guard let path = Bundle.main.path(forResource: "sessions", ofType: "csv") else {
            print("❌ Could not find sessions.csv")
            return []
        }
        
        do {
            let data = try String(contentsOfFile: path, encoding: .utf8)
            let rows = data.components(separatedBy: "\n").dropFirst() // Skip header
            
            return rows.compactMap { row in
                guard !row.isEmpty else { return nil }
                let columns = row.components(separatedBy: ",")
                guard columns.count >= 6 else { return nil }
                
                let title = columns[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let isPremium = title != "Bedtime Wind-Down" ? Bool.random() : false
                
                return YogaNidraSession(
                    title: title,
                    duration: Int(columns[1]) ?? 0,
                    category: SessionCategory(rawValue: columns[2]) ?? .quickSleep,
                    audioFileName: columns[3].trimmingCharacters(in: .whitespacesAndNewlines),
                    thumbnailUrl: columns[4].trimmingCharacters(in: .whitespacesAndNewlines),
                    isPremium: isPremium,
                    instructor: columns[5].trimmingCharacters(in: .whitespacesAndNewlines)
                )
            }
            
        } catch {
            print("❌ Error reading sessions.csv:", error)
            return []
        }
    }
} 