import SwiftUI

struct ContentView: View {
    @StateObject private var onboardingManager = OnboardingManager.shared
    @EnvironmentObject private var playerState: PlayerState
    @StateObject private var audioManager = AudioManager.shared
    @StateObject private var storeManager = StoreManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Base layer: Tab View
                TabView(selection: $selectedTab) {
                    HomeView(selectedTab: $selectedTab)
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }
                        .tag(0)
                    
                    SessionListView_v2()
                        .tabItem {
                            Image(systemName: "book.fill")
                            Text("Library")
                        }
                        .tag(1)
                    
                    ProgressTabView()
                        .tabItem {
                            Image(systemName: "chart.bar.fill")
                            Text("Progress")
                        }
                        .tag(2)
                }
                
                // Middle layer: Mini Player - now tied to audio playback
                if audioManager.isPlaying && !playerState.showFullPlayer,
                   let session = audioManager.currentPlayingSession {
                    VStack(spacing: 0) {
                        MiniPlayerView(
                            session: session,
                            showFullPlayer: $playerState.showFullPlayer
                        )
                        .onTapGesture {
                            playerState.showFullPlayer = true
                        }
                        Spacer().frame(height: 49)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $playerState.showFullPlayer) {
            if let session = audioManager.currentPlayingSession {
                SessionDetailView(session: session)
            }
        }
        .fullScreenCover(isPresented: $onboardingManager.shouldShowOnboarding) {
            OnboardingContainerView()
        }
        .preferredColorScheme(.dark)
        .task {
            // Load products when view appears
            do {
                try await storeManager.loadProducts()
            } catch {
                storeManager.errorMessage = error.localizedDescription
                storeManager.showError = true
            }
        }
    }
}
