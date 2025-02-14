import SwiftUI

struct HomeView: View {
    @StateObject var router = Router<HomeTabDestination>()
    @EnvironmentObject var sheetPresenter: Presenter
    @EnvironmentObject var overlayManager: OverlayManager
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject private var audioManager: AudioManager
    let sessions = YogaNidraSession.allSessions
    @Binding var selectedTab: Int
    
    var freeSessions: [YogaNidraSession] {
        sessions.filter { !$0.isPremium }
    }
    
    var popularSessions: [YogaNidraSession] {
        // Get 2 random free sessions for popular section
        Array(freeSessions.shuffled().prefix(2))
    }
    
    var recommendedSessions: [YogaNidraSession] {
        // Get 4 sessions total, sorted alphabetically
        return Array(sessions.sorted { $0.title < $1.title }.prefix(4))
    }
    
    var body: some View {
        NavigationStack(path: $router.path) {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Banner
                    ZStack(alignment: .bottomLeading) {
                        Image("header")
                            .resizable()
                            .frame(height: 220)
                            .frame(maxWidth: .infinity)
                            .scaledToFit()
                            .clipped()
                        
                        LinearGradient(
                            gradient: Gradient(colors: [.black.opacity(0.7), .clear]),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                        .frame(height: 220)  // Match the image height
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Drift Into Dreams ✨")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Float away into your nightly escape ☁️")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                    }
                    
                    valentinesBanner
                    
                    // Popular section
                    popularSection
                    
                    // Recommended section
                    recommendedSection
                }
                .padding(.vertical)
            }
            .contentMargins(.bottom, audioManager.currentPlayingSession != nil ? 52 : 0, for: .scrollContent)
            .navigationTitle("Yoga Nidra")
            .environmentObject(router)
            .navigationDestination(for: HomeTabDestination.self) { destination in
                switch destination {
                case .none:
                    Text("No view for HomeTabDestination")
                }
            }
            .onAppear {
                AppState.shared.shouldShowValentrineDayTab = true
            }
        }
    }
    
    var valentinesBanner: some View {
        ZStack {
            Image("Unfamiliar_Place")
                .resizable()
                .aspectRatio(1, contentMode: .fill)
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [.pink.opacity(0.5), .purple.opacity(0.7)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            VStack {
                Text("Special Event: 14 Days of Self-Love 💝")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                Spacer()
                VStack(spacing: 4) {
                    Text("A love letter to your wellbeing... tap to unwrap ✨")
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    HeartAnimation()
                }
                .padding()
            }
        }
        .padding()
        .onTapGesture {
            AppState.shared.shouldShowValentrineDayTab = true
            AppState.shared.selectedTab = 3
        }
    }
    
    var popularSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Dreamy Picks ⭐️")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button("See All") {
                    selectedTab = 1
                }
                .foregroundColor(.blue)
            }
            .padding(.horizontal, 24)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(sessions.prefix(2), id: \.id) { session in
                    Button {
                        sheetPresenter.present(.sessionDetials(session))
                    } label: {
                        SessionCard(session: session)
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    var recommendedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Made Just for You 💫")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button("See All") {
                    selectedTab = 1
                }
                .foregroundColor(.blue)
            }
            .padding(.horizontal, 24)
            
            VStack(spacing: 12) {
                ForEach(recommendedSessions) { session in
                    Button {
                        sheetPresenter.present(.sessionDetials(session))
                    } label: {
                        RecommendedSessionCard(session: session)
                    }
                }
            }
            .padding(.horizontal, 24)
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
            
            Button("See All") {
                selectedTab = 1
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white.opacity(0.3))
            .cornerRadius(12)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.top, 8)
        }
    }
}

struct HeartAnimation: View {
    @State private var isAnimating = false
    
    var body: some View {
        Text("❤️")
            .font(.title)
            .scaleEffect(isAnimating ? 1.2 : 1.0)
            .animation(
                Animation.easeInOut(duration: 0.8)
                    .repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

// MARK: - Previews
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(selectedTab: .constant(0))
            .environmentObject(Presenter())
            .environmentObject(OverlayManager())
            .environmentObject(ProgressManager.shared)
            .environmentObject(AudioManager.shared)
    }
}
