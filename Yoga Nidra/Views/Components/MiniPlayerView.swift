import SwiftUI

struct MiniPlayerView: View {
    let session: YogaNidraSession
    @StateObject private var audioManager = AudioManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 16) {
                // Thumbnail
                Image(session.thumbnailUrl)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .cornerRadius(6)
                
                // Title and Time
                VStack(alignment: .leading, spacing: 2) {
                    Text(session.title)
                        .font(.subheadline)
                        .lineLimit(1)
                    Text(formatTime(audioManager.currentTime))
                        .font(.caption)
                        .foregroundColor(.gray)
                        .transaction { transaction in
                            transaction.animation = nil
                        }
                }
                
                Spacer()
                
                // Play/Pause Button
                Button {
                    audioManager.onStopSession()
                } label: {
                    Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.title)
                        .foregroundColor(.primary)
                }
            }
            .padding()
            .background(Color(uiColor: .systemBackground))
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// Preview
struct MiniPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        MiniPlayerView(session: .preview)
    }
} 
