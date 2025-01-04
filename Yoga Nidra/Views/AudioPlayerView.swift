import SwiftUI

struct AudioPlayerView: View {
    @StateObject private var audioManager = AudioManager.shared
    let session: YogaNidraSession
    
    var body: some View {
        VStack(spacing: 20) {
            // Progress bar
            ProgressSlider(value: $audioManager.currentTime, 
                         maxValue: audioManager.duration) { isDragging in
                if isDragging {
                    audioManager.pause()
                } else {
                    audioManager.seek(to: audioManager.currentTime)
                    if audioManager.isPlaying {
                        audioManager.play()
                    }
                }
            }
            
            // Time labels
            HStack {
                Text(formatTime(audioManager.currentTime))
                Spacer()
                Text(formatTime(audioManager.duration))
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            // Play/Pause button
            Button(action: {
                if audioManager.isPlaying {
                    audioManager.pause()
                } else {
                    audioManager.play()
                }
            }) {
                Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .onAppear {
            audioManager.loadAudio(named: session.audioFileName)
        }
        .onDisappear {
            audioManager.stop()
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct ProgressSlider: View {
    @Binding var value: TimeInterval
    let maxValue: TimeInterval
    let onEditingChanged: (Bool) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 6)
                    .cornerRadius(3)
                
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: geometry.size.width * CGFloat(value / maxValue), height: 6)
                    .cornerRadius(3)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        onEditingChanged(true)
                        let percentage = gesture.location.x / geometry.size.width
                        value = min(max(0, Double(percentage) * maxValue), maxValue)
                    }
                    .onEnded { _ in
                        onEditingChanged(false)
                    }
            )
        }
        .frame(height: 6)
    }
} 