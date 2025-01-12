import Foundation

class SessionDataParser {
    static func loadSessions() -> [YogaNidraSession] {
        guard let path = Bundle.main.path(forResource: "sessions", ofType: "csv") else {
            print("❌ Could not find sessions.csv in path: \(Bundle.main.bundlePath)")
            return []
        }
        
        do {
            let data = try String(contentsOfFile: path, encoding: .utf8)
            let rows = data.components(separatedBy: "\n").dropFirst() // Skip header
            print("📝 Found \(rows.count) rows in sessions.csv")
            
            let sessions = rows.compactMap { (row: String) -> YogaNidraSession? in
                guard !row.isEmpty else { return nil }
                let columns = row.components(separatedBy: ",")
                print("📊 Processing row with \(columns.count) columns: \(row)")
                
                guard columns.count >= 8 else { 
                    print("❌ Invalid column count: \(columns.count)")
                    return nil 
                }
                
                // CSV columns:
                // 0: title
                // 1: duration
                // 2: category
                // 3: audioFileName
                // 4: thumbnailUrl
                // 5: instructor
                // 6: premium (y/n)
                // 7: txt_file_name (internal)
                // 8: Eleven Labs name (internal)
                
                let categoryString = columns[2].trimmingCharacters(in: .whitespacesAndNewlines)
                let category = SessionCategory(rawValue: categoryString) ?? .quickSleep
                
                let isPremium = columns[6].trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "y"
                
                return YogaNidraSession(
                    id: UUID(),
                    title: columns[0].trimmingCharacters(in: .whitespacesAndNewlines),
                    description: "A guided meditation session with \(columns[5].trimmingCharacters(in: .whitespacesAndNewlines))",
                    duration: Int(columns[1]) ?? 0,
                    thumbnailUrl: columns[4].trimmingCharacters(in: .whitespacesAndNewlines),
                    audioFileName: columns[3].trimmingCharacters(in: .whitespacesAndNewlines),
                    isPremium: isPremium,
                    category: category,
                    instructor: columns[5].trimmingCharacters(in: .whitespacesAndNewlines)
                )
            }
            
            print("✅ Successfully loaded \(sessions.count) sessions")
            return sessions
            
        } catch {
            print("❌ Error reading sessions.csv:", error)
            return []
        }
    }
} 