import Foundation

class SessionDataParser {
    static func loadSessions() -> [YogaNidraSession] {
        guard let url = Bundle.main.url(forResource: "sessions", withExtension: "csv") else {
            print("❌ Could not find sessions.csv")
            return []
        }
        
        do {
            let data = try String(contentsOf: url)
            let rows = data.components(separatedBy: .newlines).filter { !$0.isEmpty }
            let dataRows = Array(rows.dropFirst()) // Drop header row
            print("📚 Found \(dataRows.count) sessions in CSV")
            
            return dataRows.compactMap { (row: String) -> YogaNidraSession? in
                let columns = row.components(separatedBy: ",")
                guard columns.count >= 7 else {
                    print("❌ Invalid row: \(row)")
                    return nil
                }
                
                // Clean the thumbnailUrl string
                let thumbnailUrl = columns[6]
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacingOccurrences(of: " ", with: "_")
                
                print("🔍 Loading image: '\(thumbnailUrl)'")
                
                let session = YogaNidraSession(
                    title: columns[1].trimmingCharacters(in: .whitespacesAndNewlines),
                    description: columns[2].trimmingCharacters(in: .whitespacesAndNewlines),
                    duration: TimeInterval(columns[3]) ?? 0,
                    category: SessionCategory(rawValue: columns[0].trimmingCharacters(in: .whitespacesAndNewlines)) ?? .all,
                    audioFileName: columns[5].trimmingCharacters(in: .whitespacesAndNewlines),
                    thumbnailUrl: thumbnailUrl,
                    instructor: columns[4].trimmingCharacters(in: .whitespacesAndNewlines)
                )
                return session
            }
        } catch {
            print("❌ Error reading sessions.csv: \(error)")
            return []
        }
    }
} 