import SwiftUI

struct PlayerView: View {
    @StateObject private var audioManager = AudioManager.shared
    let session: YogaNidraSession
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text(session.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text(session.instructor)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Progress Bar
            VStack(spacing: 8) {
                Slider(
                    value: $audioManager.progress,
                    in: 0...1
                )
                .disabled(audioManager.isLoading)
                
                // Time labels
                HStack {
                    Text(formatTime(audioManager.currentTime))
                    Spacer()
                    Text(formatTime(audioManager.duration))
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            // Controls
            HStack(spacing: 40) {
                // Skip Backward
                Button {
                    Task {
                        await audioManager.skipBackward()
                    }
                } label: {
                    Image(systemName: "gobackward.15")
                        .font(.title)
                }
                .disabled(audioManager.isLoading)
                
                // Play/Pause
                Button {
                    Task {
                        if audioManager.isPlaying {
                            await audioManager.pause()
                        } else {
                            await audioManager.play(session)
                        }
                    }
                } label: {
                    Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 64, height: 64)
                }
                .disabled(audioManager.isLoading)
                
                // Skip Forward
                Button {
                    Task {
                        await audioManager.skipForward()
                    }
                } label: {
                    Image(systemName: "goforward.15")
                        .font(.title)
                }
                .disabled(audioManager.isLoading)
            }
            .padding(.bottom, 30)
            
            // Loading indicator
            if audioManager.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
        .padding(.vertical)
    }
}

#Preview {
    PlayerView(session: YogaNidraSession(
        id: UUID(),
        title: "Deep Sleep Meditation",
        description: "A calming journey to help you sleep better",
        duration: 1800,
        thumbnailUrl: "preview_thumbnail",
        audioFileName: "deep_sleep.mp3",
        isPremium: false,
        category: SessionCategory(id: "Sleep"),
        instructor: "John Doe"
    ))
}
