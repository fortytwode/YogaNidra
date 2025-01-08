import SwiftUI

struct SessionDetailView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    let session: YogaNidraSession
    @EnvironmentObject private var playerState: PlayerState
    @State private var showingShareSheet = false
    @State private var showingPremiumSheet = false
    
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
                
                // Title and Premium Badge
                HStack {
                    Text(session.title)
                        .font(.system(size: 34, weight: .bold))
                        .multilineTextAlignment(.center)
                    
                    if session.isPremium {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                            .font(.title2)
                    }
                }
                
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
                if session.isPremium && !subscriptionManager.isSubscribed {
                    Button {
                        showingPremiumSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                            Text("Unlock Premium")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                } else {
                    AudioPlayerView(session: session)
                }
                
                Spacer().frame(height: 30)
            }
            .padding()
        }
        .sheet(isPresented: $showingPremiumSheet) {
            PremiumContentSheet()
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [session.title])
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
