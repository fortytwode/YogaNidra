import Foundation

class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    
    @Published var favoriteSessions: [YogaNidraSession] = []
    private let favoritesKey = "favoriteSessions"
    private var pendingSync = false
    
    private init() {
        loadFavorites()
        loadFavoritesFromFirebase()
    }
    
    func toggleFavorite(_ session: YogaNidraSession) {
        if isFavorite(session) {
            favoriteSessions.removeAll { $0.id == session.id }
        } else {
            favoriteSessions.append(session)
        }
        saveFavorites()
        syncFavoritesToFirebase()
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
    
    private func syncFavoritesToFirebase() {
        guard !pendingSync else { return }
        pendingSync = true
        
        Task {
            do {
                if let userId = await AuthManager.shared.currentUserId {
                    let favoriteIds = favoriteSessions.map { $0.id.uuidString }
                    try await FirebaseManager.shared.updateUserData(userId: userId, field: "favorites", value: favoriteIds)
                }
            } catch {
                print("❌ Failed to sync favorites: \(error)")
                // Retry once after 2 seconds
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                if let userId = await AuthManager.shared.currentUserId {
                    let favoriteIds = favoriteSessions.map { $0.id.uuidString }
                    try? await FirebaseManager.shared.updateUserData(userId: userId, field: "favorites", value: favoriteIds)
                }
            }
            pendingSync = false
        }
    }
    
    private func loadFavoritesFromFirebase() {
        Task { @MainActor in
            do {
                if let userId = await AuthManager.shared.currentUserId {
                    let userData = try await FirebaseManager.shared.fetchUserData(userId: userId)
                    if let favoriteIds = userData["favorites"] as? [String] {
                        let firebaseFavorites = YogaNidraSession.allSessions.filter { session in
                            favoriteIds.contains(session.id.uuidString)
                        }
                        // Merge with local favorites
                        let mergedFavorites = Set(favoriteSessions + firebaseFavorites)
                        favoriteSessions = Array(mergedFavorites)
                        saveFavorites() // Update local storage with merged list
                    }
                }
            } catch {
                print("❌ Failed to load favorites from Firebase: \(error)")
                // No retry for initial load - we have local data as backup
            }
        }
    }
}
