import Foundation
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

class GoogleAuthManager {
    static let shared = GoogleAuthManager()
    
    private init() {}
    
    func configure() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
    }
    
    func signIn() async -> (success: Bool, error: Error?) {
        return await withCheckedContinuation { continuation in
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController else {
                continuation.resume(returning: (false, NSError(domain: "GoogleAuthManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "No root view controller found"])))
                return
            }
            
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
                if let error = error {
                    continuation.resume(returning: (false, error))
                    return
                }
                
                guard let user = result?.user,
                      let idToken = user.idToken?.tokenString else {
                    continuation.resume(returning: (false, NSError(domain: "GoogleAuthManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to get ID token"])))
                    return
                }
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
                
                if let anonymousUser = Auth.auth().currentUser, anonymousUser.isAnonymous {
                    anonymousUser.link(with: credential) { authResult, error in
                        if let error = error {
                            continuation.resume(returning: (false, error))
                            return
                        }
                        continuation.resume(returning: (true, nil))
                    }
                } else {
                    Auth.auth().signIn(with: credential) { authResult, error in
                        if let error = error {
                            continuation.resume(returning: (false, error))
                            return
                        }
                        continuation.resume(returning: (true, nil))
                    }
                }
            }
        }
    }
}
