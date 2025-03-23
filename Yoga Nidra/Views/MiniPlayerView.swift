import SwiftUI

struct MiniPlayerView: View {
    @EnvironmentObject private var audioManager: AudioManager
    @EnvironmentObject private var sheetPresenter: Presenter
    
    private var remainingTime: String {
        let duration = audioManager.duration
        let currentTime = audioManager.currentTime
        let remaining = duration - currentTime
        let minutes = Int(remaining / 60)
        let seconds = Int(remaining.truncatingRemainder(dividingBy: 60))
        return String(format: "-%d:%02d", minutes, seconds)
    }
    
    var body: some View {
        Group {
            if let session = audioManager.currentPlayingSession {
                Button {
                    sheetPresenter.present(.sessionDetials(session))
                } label: {
                    HStack(spacing: 12) {
                        // Thumbnail
                        SessionThumbnailImage(session: session)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        // Title and Duration
                        VStack(alignment: .leading, spacing: 2) {
                            Text(session.title)
                                .lineLimit(1)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            
                            Text(remainingTime)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Play/Pause Button
                        Button {
                            Task {
                                if audioManager.isPlaying {
                                    await audioManager.pause()
                                } else {
                                    await audioManager.resume()
                                }
                            }
                        } label: {
                            ZStack {
                                if audioManager.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                } else {
                                    Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                                        .font(.title3)
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .frame(width: 32, height: 32)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(.systemBackground))
                    .overlay(
                        HStack {
                            Rectangle()
                                .fill(Color.accentColor)
                                .frame(width: UIScreen.main.bounds.width * audioManager.progress, height: 2)
                                .animation(.linear, value: audioManager.progress)
                                .frame(height: 2)
                            Spacer()
                        },
                        alignment: .top
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
