import SwiftUI

struct ContentView: View {
    @StateObject private var onboardingManager = OnboardingManager.shared
    @EnvironmentObject private var playerState: PlayerState
    @EnvironmentObject private var sheetPresenter: Presenter
    @EnvironmentObject private var audioManager: AudioManager
    @StateObject private var storeManager = StoreManager.shared
    @StateObject private var progressManager = ProgressManager.shared
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Base layer: Tab View
            TabView(selection: $appState.selectedTab) {
                HomeView(selectedTab: $appState.selectedTab)
                    .environmentObject(progressManager)
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
                
                if appState.shouldAddValantineDaysTab {
                    Text("14 day's of self love")
                        .tabItem {
                            Image(systemName: "heart.fill")
                            Text("Love")
                        }
                        .tag(3)
                }
            }
            
            // Middle layer: Mini Player - show when there's a current session
            if let _ = audioManager.currentPlayingSession,
               !audioManager.isDetailViewPresented {
                VStack(spacing: 0) {
                    MiniPlayerView()
                        .transition(.move(edge: .bottom))
                        .onTapGesture {
                            if let session = audioManager.currentPlayingSession {
                                sheetPresenter.present(.sessionDetials(session))
                            }
                        }
                    Spacer().frame(height: 49)
                }
            }
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
