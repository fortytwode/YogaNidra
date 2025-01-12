import SwiftUI
import MediaPlayer

class PlayerState: ObservableObject {
    @Published var currentSession: YogaNidraSession?
    @Published var showFullPlayer: Bool = false
    
    func play(_ session: YogaNidraSession) {
        currentSession = session
    }
}
