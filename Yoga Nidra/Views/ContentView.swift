import SwiftUI

struct ContentView: View {
    @StateObject private var onboardingManager = OnboardingManager.shared
    @EnvironmentObject private var playerState: PlayerState
    @EnvironmentObject private var sheetPresenter: Presenter
    @EnvironmentObject private var audioManager: AudioManager
    @StateObject private var storeManager = StoreManager.shared
    @StateObject private var progressManager = ProgressManager.shared
    @EnvironmentObject private var appState: AppState
    
    // Add this state to force view refresh when needed
    @State private var viewID = UUID()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Force the entire view to rebuild when needed
            if appState.forceRebuild {
                // This is a trick to force SwiftUI to rebuild the entire view
                EmptyView()
                    .onAppear {
                        // Reset the flag immediately
                        DispatchQueue.main.async {
                            appState.forceRebuild = false
                        }
                    }
            }
            
            // Base layer: Tab View
            TabView(selection: $appState.selectedTab) {
                HomeView(selectedTab: $appState.selectedTab)
                    .environmentObject(progressManager)
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    .tag(AppTab.home)
                
                DiscoverTab()
                    .environmentObject(progressManager)
                    .tabItem {
                        Image(systemName: "magnifyingglass.circle.fill")
                        Text("Discover")
                    }
                    .tag(AppTab.discover)
                
                LibraryTab()
                    .tabItem {
                        Image(systemName: "book.fill")
                        Text("Library")
                    }
                    .tag(AppTab.library)
                
                ProfileTabView()
                    .tabItem {
                        ZStack {
                            Image(systemName: "person.crop.circle.fill")
                            Text("Profile")
                        }
                    }
                    .tag(AppTab.profile)
            }
            .id(viewID) // Force view refresh when ID changes
            
            // Middle layer: Mini Player - show when there's a current session
            if let session = audioManager.currentPlayingSession {
                VStack(spacing: 0) {
                    MiniPlayerView()
                        .transition(.move(edge: .bottom))
                        .onTapGesture {
                            sheetPresenter.present(.sessionDetials(session))
                        }
                    Spacer().frame(height: 49)
                }
            }
        }
        .preferredColorScheme(.dark)
        .scrollIndicators(.hidden)
        .task {
            // Load products when view appears
            do {
                try await storeManager.loadProducts()
            } catch {
                storeManager.errorMessage = error.localizedDescription
                storeManager.showError = true
            }
        }
        .onAppear {
            // Force a view refresh when the view appears
            // This ensures the TabView respects the initial tab selection
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                viewID = UUID()
            }
        }
    }
}
