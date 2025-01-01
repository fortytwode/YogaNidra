import SwiftUI

struct SessionDetailView: View {
    let session: YogaNidraSession
    @StateObject private var audioManager = AudioPlayerManager()
    @EnvironmentObject var progressManager: ProgressManager
    @State private var sessionStartTime: Date?
    @State private var timeListened: TimeInterval = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(session.title)
                    .font(.title)
                    .padding(.bottom, 4)
                
                Text(session.category.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(session.description)
                    .padding(.vertical)
                
                // Player controls
                VStack(spacing: 20) {
                    // Progress bar
                    ProgressView(value: audioManager.currentTime, total: audioManager.duration)
                        .padding(.horizontal)
                    
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
                            endSession()
                        } else {
                            audioManager.play()
                            startSession()
                        }
                    }) {
                        Label(audioManager.isPlaying ? "Pause" : "Play", 
                              systemImage: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.title)
                    }
                    .buttonStyle(.bordered)
                    .tint(.primary)
                }
                .padding()
                
                // Session Progress
                if let progress = progressManager.sessionProgress[session.id] {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Session Progress")
                            .font(.headline)
                        
                        Text("Completed \(progress.completionCount) times")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if let lastCompleted = progress.lastCompleted {
                            Text("Last completed: \(lastCompleted.formatted())")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(uiColor: .systemGray6))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .onAppear {
            audioManager.loadAudio(named: session.audioFileName)
        }
        .onDisappear {
            if audioManager.isPlaying {
                endSession()
            }
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func startSession() {
        sessionStartTime = Date()
    }
    
    private func endSession() {
        guard let startTime = sessionStartTime else { return }
        timeListened = Date().timeIntervalSince(startTime)
        progressManager.updateProgress(for: session, timeListened: timeListened)
        sessionStartTime = nil
    }
} 