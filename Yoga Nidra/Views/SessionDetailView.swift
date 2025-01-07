import SwiftUI

struct SessionDetailView: View {
    let session: YogaNidraSession
    @EnvironmentObject private var playerState: PlayerState
    @State private var showingShareSheet = false
    
    var body: some View {
        ZStack {
            // Background Image
            Image(session.thumbnailUrl)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .black.opacity(0.7)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            // Content
            VStack(spacing: 20) {
                Spacer()
                
                // Title
                Text(session.title)
                    .font(.system(size: 34, weight: .bold))
                    .multilineTextAlignment(.center)
                
                // Duration
                Text("\(Int(session.duration / 60)) minutes")
                    .font(.system(size: 20))
                    .foregroundColor(.gray)
                
                // Action buttons
                HStack(spacing: 40) {
                    Button(action: {}) {
                        Image(systemName: "heart")
                            .font(.title2)
                    }
                    Button(action: {
                        showingShareSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title2)
                    }
                }
                .foregroundColor(.white)
                .padding(.bottom, 40)
                
                // Audio player controls
                AudioPlayerView(session: session)
                    .padding(.bottom, 30)
            }
            .foregroundColor(.white)
            .padding()
        }
        .preferredColorScheme(.dark)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [
                "Check out this meditation: \(session.title)",
                URL(string: "https://yoganidra.app/session/\(session.id)")!
            ])
        }
        .onAppear {
            print("📱 SessionDetailView appeared for session: \(session.title)")
            print("📱 Audio filename: \(session.audioFileName)")
            playerState.play(session)
        }
    }
}

// Add ShareSheet view
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
} 
