import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showFullPlayer = false
    @EnvironmentObject var playerState: PlayerState
    
    init() {
        // Adjust tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.backgroundColor = .black
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = .gray
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = .white
        
        // Remove default shadow and adjust padding
        tabBarAppearance.shadowColor = .clear
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                NavigationStack {
                    HomeView(selectedTab: $selectedTab)
                }
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
                
                NavigationStack {
                    SessionListView_v2()
                }
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Library")
                }
                .tag(1)
                
                NavigationStack {
                    ProgressTabView()
                }
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Progress")
                }
                .tag(2)
            }
            .preferredColorScheme(.dark)
            
            if playerState.currentSession != nil {
                MiniPlayerView(
                    currentSession: .constant(playerState.currentSession),
                    showFullPlayer: $showFullPlayer
                )
            }
        }
    }
} 