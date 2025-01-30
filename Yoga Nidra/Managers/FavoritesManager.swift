import Foundation

class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    
    @Published var favoriteSessions: [YogaNidraSession] = []
    private let favoritesKey = "favoriteSessions"
    
    private init() {
        loadFavorites()
    }
    
    func toggleFavorite(_ session: YogaNidraSession) {
        if isFavorite(session) {
            favoriteSessions.removeAll { $0.id == session.id }
        } else {
            favoriteSessions.append(session)
        }
        saveFavorites()
    }
    
    func isFavorite(_ session: YogaNidraSession) -> Bool {
        favoriteSessions.contains(where: { $0.id == session.id })
    }
    
    private func saveFavorites() {
        let favoriteIds = favoriteSessions.map { $0.id.uuidString }
        UserDefaults.standard.set(favoriteIds, forKey: favoritesKey)
    }
    
    private func loadFavorites() {
        guard let favoriteIds = UserDefaults.standard.stringArray(forKey: favoritesKey) else {
            return
        }
        
        favoriteSessions = YogaNidraSession.allSessions.filter { session in
            favoriteIds.contains(session.id.uuidString)
        }
    }
}
