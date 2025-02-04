import Foundation

class SessionDataParser {
    
    static func loadSessions() -> [YogaNidraSession] {
        guard let path = Bundle.main.path(forResource: "sessions", ofType: "json") else {
            print("❌ Could not find sessions.json in path: \(Bundle.main.bundlePath)")
            return []
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let decoder = JSONDecoder()
            let sessions = try decoder.decode([Session].self, from: data)
            
            print("✅ Successfully loaded \(sessions.count) sessions")
            return sessions.sorted {
                $0.order < $1.order
            }.compactMap { item in
                YogaNidraSession(
                    id: UUID(),
                    title: item.title,
                    description: item.description,
                    duration: item.duration,
                    thumbnailUrl: item.thumbnailUrl,
                    audioFileName: item.audioFileName,
                    isPremium: item.premium != "n",
                    category: SessionCategory(id: item.category),
                    instructor: item.instructor
                )
            }
        } catch {
            print("❌ Error reading sessions.json:", error)
            return []
        }
    }
    
    struct Session: Codable {
        let title: String
        let duration: Int
        let category: String
        let audioFileName: String
        let thumbnailUrl: String
        let instructor: String
        let premium: String
        let elevenLabsName: String
        let description: String
        let principles: String
        let words: Int
        let textFileName: String
        let gender: String
        let order: Int

        enum CodingKeys: String, CodingKey {
            case title
            case duration
            case category
            case audioFileName
            case thumbnailUrl
            case instructor
            case premium
            case elevenLabsName = "ElevenLabs_name"
            case description
            case principles
            case words
            case textFileName = "text_file_name"
            case gender
            case order
        }
    }
}
