import SwiftUI

class PlayerState: ObservableObject {
    @Published var currentSession: YogaNidraSession?
    
    func play(_ session: YogaNidraSession) {
        currentSession = session
    }
} 