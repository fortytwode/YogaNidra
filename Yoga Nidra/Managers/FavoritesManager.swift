import Foundation

@MainActor
final class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    
    @Published var favoriteSessions: [YogaNidraSession] = []
    
    private init() {
        Task {
            await loadFavoritesFromFirebase()
        }
    }
    
    func toggleFavorite(_ session: YogaNidraSession) async {
        if isFavorite(session) {
            await removeFavorite(session)
        } else {
            await addFavorite(session)
        }
    }
    
    func isFavorite(_ session: YogaNidraSession) -> Bool {
        favoriteSessions.contains { $0.id == session.id }
    }
    
    private func addFavorite(_ session: YogaNidraSession) async {
        guard let userCollection = await FirebaseManager.shared.getUserDocument() else { return }
        
        let favDocument = userCollection.collection(StorageKeys.favoriteSessionsKey).document(session.id)
        do {
            try await favDocument.setData(["isFavoutite": true])
            favoriteSessions.append(session)
        } catch {
            print("Error adding favorite: \(error.localizedDescription)")
        }
    }
    
    private func removeFavorite(_ session: YogaNidraSession) async {
        guard let userCollection = await FirebaseManager.shared.getUserDocument() else { return }
        
        let favDocument = userCollection.collection(StorageKeys.favoriteSessionsKey).document(session.id)
        do {
            try await favDocument.delete()
            favoriteSessions.removeAll { $0.id == session.id }
        } catch {
            print("Error adding favorite: \(error.localizedDescription)")
        }
    }
    
    private func loadFavoritesFromFirebase() async {
        guard let userCollection = await FirebaseManager.shared.getUserDocument() else { return }
        
        let allSessions = YogaNidraSession.allSessionIncldedSpecialEventSessions
        let favCollection = userCollection.collection(StorageKeys.favoriteSessionsKey)
        do {
            let snapshot = try await favCollection.getDocuments()
            let favSessions = snapshot.documents.compactMap {
                let id = $0.documentID
                if let session = allSessions.first(where: { $0.id == id }) {
                    return session
                } else {
                    return nil
                }
            }
            favoriteSessions = favSessions
        } catch {
            print("Error loading favorites: \(error.localizedDescription)")
        }
    }
}
