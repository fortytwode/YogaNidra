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
            Slider(value: $audioManager.progress, in: 0...1)
                .tint(.white)
                .onChange(of: audioManager.progress) { newValue in
                    Task {
                        await audioManager.seek(to: newValue * audioManager.duration)
                    }
                }
            
            // Time labels
            HStack {
                Text(formatTime(audioManager.currentTime))
                    .foregroundColor(.white)
                Spacer()
                Text(formatTime(audioManager.duration))
                    .foregroundColor(.white)
            }
            .font(.caption)
            
            // Playback controls
            HStack(spacing: 40) {
                Button {
                    Task {
                        await audioManager.seek(to: max(0, audioManager.currentTime - 15))
                    }
                } label: {
                    Image(systemName: "gobackward.15")
                        .font(.title)
                        .foregroundColor(.white)
                }
                
                Button {
                    Task {
                        if audioManager.isPlaying {
                            await audioManager.pause()
                        } else {
                            await audioManager.resume()
                        }
                    }
                } label: {
                    Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.white)
                }
                
                Button {
                    Task {
                        await audioManager.seek(to: min(audioManager.duration, audioManager.currentTime + 15))
                    }
                } label: {
                    Image(systemName: "goforward.15")
                        .font(.title)
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
    }
}
