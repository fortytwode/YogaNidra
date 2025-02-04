import Foundation
import FirebaseAuth

@MainActor
final class AuthManager {
    static let shared = AuthManager()
    
    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }
    
    private init() {
        // Create anonymous user if not already signed in
        if Auth.auth().currentUser == nil {
            Task {
                do {
                    try await Auth.auth().signInAnonymously()
                    print("✅ Created anonymous user")
                } catch {
                    print("❌ Failed to create anonymous user: \(error)")
                }
            }
        }
    }
    
    func signInAnonymously() async throws {
        try await Auth.auth().signInAnonymously()
    }
}
