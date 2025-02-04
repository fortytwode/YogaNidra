import SwiftUI
import AVFoundation

struct SessionDetailView: View {
    let session: YogaNidraSession
    
    @StateObject private var audioManager = AudioManager.shared
    @StateObject private var storeManager = StoreManager.shared
    @StateObject private var favoritesManager = FavoritesManager.shared
    @EnvironmentObject private var playerState: PlayerState
    @EnvironmentObject private var sheetPresenter: Presenter
    @State private var showingShareSheet = false
    @Environment(\.dismiss) private var dismiss
    
    private var durationInMinutes: Int {
        Int(ceil(Double(session.duration) / 60.0))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Top Bar with dismiss button
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.down")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    // Main Content
                    VStack(spacing: 16) {
                        // Session Image
                        Image(session.thumbnailUrl)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .cornerRadius(20)
                        
                        // Session Info
                        VStack(spacing: 8) {
                            Text(session.title)
                                .font(.title)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            Text(session.description)
                                .font(.callout)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal)
                            
                            HStack {
                                Text(session.instructor)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Text("•")
                                    .foregroundColor(.white.opacity(0.6))
                                
                                Text("\(durationInMinutes) minutes")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            .padding(.top, 4)
                        }
                        
                        // Action Buttons
                        HStack(spacing: 40) {
                            Button(action: {
                                favoritesManager.toggleFavorite(session)
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: favoritesManager.isFavorite(session) ? "heart.fill" : "heart")
                                        .font(.title2)
                                        .foregroundColor(favoritesManager.isFavorite(session) ? .red : .white)
                                        .frame(width: 44, height: 44)
                                        .background(Color.white.opacity(0.2))
                                        .clipShape(Circle())
                                    
                                    Text("Favorite")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Button(action: {
                                showingShareSheet = true
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .frame(width: 44, height: 44)
                                        .background(Color.white.opacity(0.2))
                                        .clipShape(Circle())
                                    
                                    Text("Share")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.top, 20)
                        
                        Spacer(minLength: geometry.size.height * 0.1)
                        
                        // Player Controls
                        VStack(spacing: 30) {
                            // Progress Slider and Time
                            VStack(spacing: 8) {
                                Slider(value: Binding(get: {
                                    audioManager.srubPostion
                                }, set: { value in
                                    audioManager.onScrub(fraction: value)
                                }),
                                       in: 0...1)
                                    .tint(.white)
                                
                                HStack {
                                    Text(formatTime(audioManager.currentTime))
                                    Spacer()
                                    Text(formatTime(TimeInterval(session.duration)))
                                }
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                                .transaction { transaction in
                                    transaction.animation = nil
                                }
                            }
                            .padding(.horizontal)
                            
                            // Control Buttons
                            HStack(spacing: 60) {
                                Button {
                                    audioManager.skip(.backward, by: 15)
                                } label: {
                                    Image(systemName: "gobackward.15")
                                        .font(.title)
                                        .foregroundColor(.white)
                                }
                                
                                Button {
                                    Task {
                                        if audioManager.isPlaying {
                                            try await audioManager.onPauseSession()
                                        } else {
                                            try await startPlaying()
                                        }
                                    }
                                } label: {
                                    Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(.white)
                                        .frame(width: 60, height: 60)
                                        .background(Circle().fill(Color.white.opacity(0.2)))
                                }
                                
                                Button {
                                    audioManager.skip(.forward, by: 15)
                                } label: {
                                    Image(systemName: "goforward.15")
                                        .font(.title)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
        .ignoresSafeArea()
        .background(Color.black)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [
                "Check out this meditation: \(session.title)",
                "Duration: \(durationInMinutes) minutes",
                "Instructor: \(session.instructor)",
                session.description
            ])
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func startPlaying() async throws {
        try await audioManager.onPlaySession(session: session)
    }
}

// ShareSheet UIViewControllerRepresentable
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// Preview Provider
#Preview {
    SessionDetailView(session: .preview)
        .environmentObject(PlayerState())
        .environmentObject(Presenter())
}
