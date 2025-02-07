import SwiftUI

struct MiniPlayerView: View {
    @StateObject private var audioManager = AudioManager.shared
    @State private var showPlayer = false
    
    var body: some View {
        Group {
            if let session = audioManager.currentPlayingSession {
                Button {
                    showPlayer = true
                } label: {
                    HStack(spacing: 12) {
                        // Thumbnail
                        Image(session.thumbnailUrl)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 40, height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        // Title
                        Text(session.title)
                            .lineLimit(1)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
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
                        GeometryReader { geometry in
                            Rectangle()
                                .fill(Color.accentColor)
                                .frame(width: geometry.size.width * audioManager.progress, height: 2)
                                .animation(.linear, value: audioManager.progress)
                        }
                        .frame(height: 2)
                        , alignment: .top
                    )
                }
                .buttonStyle(.plain)
                .sheet(isPresented: $showPlayer) {
                    PlayerView(session: session)
                        .presentationDragIndicator(.visible)
                }
            }
        }
    }
}
