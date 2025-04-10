import SwiftUI
import AVFoundation
import StoreKit

struct SessionDetailView: View {
    let session: YogaNidraSession
    
    @StateObject private var storeManager = StoreManager.shared
    @StateObject private var favoritesManager = FavoritesManager.shared
    @StateObject private var progressManager = ProgressManager.shared
    @EnvironmentObject private var playerState: PlayerState
    @EnvironmentObject private var sheetPresenter: Presenter
    @EnvironmentObject private var audioManager: AudioManager
    @State private var showingShareSheet = false
    
    private var durationInMinutes: Int {
        Int(ceil(Double(session.duration) / 60.0))
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            ZStack(alignment: .topLeading) {
                mainContent
                Button(action: {
                    sheetPresenter.dismiss()
                }) {
                    Circle()
                        .fill(.black)
                        .stroke(Color.white, lineWidth: 1)
                        .frame(width: 44, height: 44)
                        .overlay {
                            Image(systemName: "chevron.down")
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                        }
                }
                .padding([.top, .leading], 20)
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .ignoresSafeArea()
        .background(Color.black)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [session.title])
        }
        .alert("Playback Error", isPresented: .init(
            get: { audioManager.errorMessage != nil },
            set: { if !$0 { audioManager.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            if let error = audioManager.errorMessage {
                Text(error)
            }
        }
    }
    
    // MARK: - View Components
    private var mainContent: some View {
        VStack(spacing: 16) {
            sessionImage
            sessionInfo
            if !ReachabilityManager.shared.isNetworkReachable {
                Text("You are currently offline, please connect to internet")
                    .font(.subheadline)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            actionButtons
            playerControls
        }
        .padding(.top, 20)
    }
    
    private var sessionImage: some View {
        SessionThumbnailImage(session: session)
            .scaledToFill()
            .frame(maxHeight: 200)
            .cornerRadius(20)
            .padding(.horizontal)
    }
    
    private var sessionInfo: some View {
        VStack(spacing: 8) {
            ZStack {
                Text(session.title)
                    .font(.title)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                
                HStack {
                    Spacer()
                    DownloadButton(session: session)
                        .padding(.trailing)
                }
            }
            
            Text(session.description)
                .font(.callout)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal)
            
            sessionMetadata
        }
    }
    
    private var sessionMetadata: some View {
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
    
    private var actionButtons: some View {
        HStack(spacing: 40) {
            favoriteButton
            shareButton
        }
        .padding(.vertical)
    }
    
    private var favoriteButton: some View {
        Button(action: {
            Task {
                await favoritesManager.toggleFavorite(session)
            }
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
    }
    
    private var shareButton: some View {
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
    
    private var playerControls: some View {
        VStack(spacing: 30) {
            progressSlider
            timeControls
        }
        .padding(.horizontal)
    }
    
    private var progressSlider: some View {
        VStack(spacing: 8) {
            AudioSeeker()
                .disabled(audioManager.isLoading)
                .opacity(audioManager.isLoading ? 0.3 : 1.0)
            HStack {
                Text(formatTime(audioManager.currentTime))
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text(formatTime(audioManager.duration))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var timeControls: some View {
        HStack(spacing: 40) {
            // Skip Backward
            Button(action: {
                Task {
                    await audioManager.skipBackward()
                }
            }) {
                Image(systemName: "gobackward.15")
                    .font(.title)
                    .foregroundColor(.white)
            }
            .disabled(audioManager.isLoading)
            .opacity(audioManager.isLoading ? 0.3 : 1.0)
            
            // Play/Pause
            if audioManager.isLoading {
                SwiftUI.ProgressView()
            } else {
                Button(action: {
                    Task {
                        if audioManager.isPlaying {
                            await audioManager.pause()
                        } else {
                            await audioManager.play(session)
                        }
                    }
                }) {
                    Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title)
                        .foregroundColor(.white)
                }
            }
            
            // Skip Forward
            Button(action: {
                Task {
                    await audioManager.skipForward()
                }
            }) {
                Image(systemName: "goforward.15")
                    .font(.title)
                    .foregroundColor(.white)
            }
            .disabled(audioManager.isLoading)
            .opacity(audioManager.isLoading ? 0.3 : 1.0)
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Supporting Views

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
