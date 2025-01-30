import SwiftUI
import AVFoundation

struct AudioPlayerView: View {
    @ObservedObject private var audioManager: AudioManager
    let session: YogaNidraSession
    
    init(session: YogaNidraSession) {
        self.session = session
        self._audioManager = ObservedObject(wrappedValue: AudioManager.shared)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Progress bar
            Slider(value: Binding(get: {
                audioManager.srubPostion
            }, set: { value in
                audioManager.onScrub(fraction: value)
            }), in: 0...1)
            .tint(.white)
            
            // Time labels
            HStack {
                Text(formatTime(audioManager.currentTime))
                Spacer()
                Text(formatTime(TimeInterval(session.duration)))
            }
            .font(.subheadline)
            .foregroundColor(.gray)
        }
    }
}
