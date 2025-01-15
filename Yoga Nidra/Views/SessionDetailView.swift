import SwiftUI
import AVFoundation

struct SessionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var playerState: PlayerState
    @StateObject private var audioManager = AudioManager.shared
    let session: YogaNidraSession
    @StateObject private var storeManager = StoreManager.shared
    @State private var showingSubscriptionSheet = false
    
    private var durationInMinutes: Int {
        Int(ceil(Double(session.duration) / 60.0))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    Spacer()
                    
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
                        
                        Text("with \(session.instructor)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text("\(durationInMinutes) minutes")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Player Controls
                    VStack(spacing: 30) {
                        // Progress Slider and Time
                        VStack(spacing: 8) {
                            Slider(value: .constant(audioManager.currentTime),
                                   in: 0...Double(session.duration))
                                .tint(.white)
                            
                            HStack {
                                Text(formatTime(audioManager.currentTime))
                                Spacer()
                                Text(formatTime(TimeInterval(session.duration)))
                            }
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                        }
                        .padding(.horizontal)
                        
                        // Control Buttons
                        HStack(spacing: 60) {
                            Button(action: { /* Skip backward */ }) {
                                Image(systemName: "gobackward.15")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                            
                            Button {
                                Task {
                                    if session.isPremium && !storeManager.isSubscribed {
                                        showingSubscriptionSheet = true
                                    } else {
                                        try await audioManager.onPlaySession(session: session)
                                    }
                                }
                            } label: {
                                Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                                    .frame(width: 60, height: 60)
                                    .background(Circle().fill(Color.white.opacity(0.2)))
                            }
                            
                            Button(action: { /* Skip forward */ }) {
                                Image(systemName: "goforward.15")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.bottom, 50)
                }
                .padding(.top, geometry.safeAreaInsets.top + 20)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: $showingSubscriptionSheet) {
            SubscriptionView()
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// Preview Provider
#Preview {
    SessionDetailView(session: .preview)
        .preferredColorScheme(.dark) // Since app uses dark mode
}
