import SwiftUI

struct MiniPlayerView: View {
    @StateObject private var audioManager = AudioManager.shared
    @Binding var currentSession: YogaNidraSession?
    @Binding var showFullPlayer: Bool
    
    var body: some View {
        if let session = currentSession {
            VStack(spacing: 0) {
                Divider()
                
                HStack(spacing: 16) {
                    // Thumbnail
                    Image(session.thumbnailUrl)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .cornerRadius(6)
                    
                    // Title
                    VStack(alignment: .leading, spacing: 2) {
                        Text(session.title)
                            .font(.subheadline)
                            .lineLimit(1)
                        Text(formatTime(audioManager.currentTime))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Play/Pause Button
                    Button(action: {
                        if audioManager.isPlaying {
                            audioManager.pause()
                        } else {
                            audioManager.play()
                        }
                    }) {
                        Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(UIColor.systemBackground))
                .onTapGesture {
                    showFullPlayer = true
                }
            }
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
} 