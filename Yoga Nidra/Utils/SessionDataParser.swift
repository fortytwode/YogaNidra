import Foundation

class SessionDataParser {
    
    static func loadSessions() -> [YogaNidraSession] {
        return loadSessionsFromJSON(fileName: "sessions")
    }
    
    static func loadSessionsFromJSON(fileName: String) -> [YogaNidraSession] {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "json") else {
            print("❌ Could not find \(fileName).json in path: \(Bundle.main.bundlePath)")
            return []
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let decoder = JSONDecoder()
            let sessions = try decoder.decode([Session].self, from: data)
            
            print("✅ Successfully loaded \(sessions.count) sessions from \(fileName).json")
            return sessions.sorted {
                $0.order < $1.order
            }.compactMap { item in
                YogaNidraSession(
                    id: String(item.order),
                    title: item.title,
                    description: item.description,
                    duration: item.duration,
                    thumbnailUrl: item.thumbnailUrl,
                    audioFileName: item.audioFileName,
                    audioFileFolder: item.audioFileFolder,
                    isPremium: item.premium != "n",
                    category: SessionCategory(id: item.category),
                    instructor: item.instructor
                )
            }
        } catch {
            print("❌ Error reading \(fileName).json:", error)
            return []
        }
    }
    
    static func loadEarthMonthSessions() -> [YogaNidraSession] {
        return loadSessionsFromJSON(fileName: "earth_month")
    }
    
    static func loadSpringResetSessions() -> [YogaNidraSession] {
        return loadSessionsFromJSON(fileName: "spring_reset")
    }
    
    struct Session: Codable {
        let title: String
        let duration: Int
        let category: String
        let audioFileName: String
        let audioFileFolder: String?
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
            case audioFileFolder
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
