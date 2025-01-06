import SwiftUI
import AVFoundation

struct AudioPlayerView: View {
    private let audioManager = AudioManager.shared
    let session: YogaNidraSession
    
    var body: some View {
        VStack(spacing: 20) {
            // Progress bar
            ProgressView(value: audioManager.currentTime, total: session.duration)
                .tint(.white)
            
            // Time labels
            HStack {
                Text(formatTime(audioManager.currentTime))
                Spacer()
                Text(formatTime(session.duration))
            }
            .font(.subheadline)
            .foregroundColor(.gray)
        }
        .onAppear {
            print("📱 AudioPlayerView appeared, loading audio: \(session.audioFileName)")
            audioManager.loadAudio(
                named: session.audioFileName,
                title: session.title
            )
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
} 