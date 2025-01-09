import SwiftUI

struct ContentView: View {
    @StateObject private var onboardingManager = OnboardingManager.shared
    @State private var selectedTab = 0
    @State private var tabBarHeight: CGFloat = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
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
        .overlay(
            GeometryReader { proxy in
                Color.clear.preference(
                    key: TabBarHeightPreferenceKey.self,
                    value: proxy.safeAreaInsets.bottom + 49
                )
            }
        )
        .onPreferenceChange(TabBarHeightPreferenceKey.self) { height in
            self.tabBarHeight = height
        }
        .environmentObject(TabBarState(height: tabBarHeight))
        .fullScreenCover(isPresented: $onboardingManager.shouldShowOnboarding) {
            OnboardingContainerView()
        }
    }
}

struct TabBarHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

class TabBarState: ObservableObject {
    @Published var height: CGFloat
    
    init(height: CGFloat) {
        self.height = height
    }
}
