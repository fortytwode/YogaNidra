import SwiftUI

struct TabItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    
    static let dashboard = TabItem(title: "Dashboard")
    static let favouritesTab = TabItem(title: "Favourites")
    static let recnentlyPlayed = TabItem(title: "Recently Played")
    static let special = TabItem(title: "Specials")
    
    static var allDefinedTabs: [TabItem] {
        [special, .dashboard, .favouritesTab, .recnentlyPlayed]
    }
}

struct DashboardTab: View {
    @StateObject var router = Router<DashboardTabDestination>()
    @State private var sleedtedTab: TabItem? = TabItem.allDefinedTabs.first
    @State private var allTabs: [TabItem] = TabItem.allDefinedTabs
    @EnvironmentObject var audioManager: AudioManager
    @AppStorage(StroageKeys.streakCountKey) var currentStreak = 0
    @AppStorage(StroageKeys.totalSessionsCompletedKey) var sessionsCompleted = 0
    @AppStorage(StroageKeys.totalSessionListenTimeKey) var totalTimeListened = 0.0
    
    var body: some View {
        NavigationStack(path: $router.path) {
            ScrollView {
                LazyVStack(pinnedViews: [.sectionHeaders]) {
                    Section(header: tabsSelection) {
                        if let sleedtedTab {
                            getViw(for: sleedtedTab)
                        }
                    }
                }
            }
            .contentMargins(.bottom, audioManager.currentPlayingSession != nil ? 52 : 0, for: .scrollContent)
            .navigationTitle(sleedtedTab?.title ?? "Dashboard")
            .navigationDestination(for: DashboardTabDestination.self) { dest in
                switch dest {
                case .selfLove14Days:
                    SelfLove14days()
                }
            }
        }
    }
    
    @ViewBuilder
    func getViw(for tab: TabItem) -> some View {
        switch tab.title {
        case TabItem.dashboard.title:
            dashboardView
        case TabItem.favouritesTab.title:
            favouritesView
        case TabItem.recnentlyPlayed.title:
            recnetlyPlayerView
        case TabItem.special.title:
            specialsView
        default:
            fatalError("No tab identified for \(tab.title)")
        }
    }
    
    var dashboardView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 10) {
                majorStats
                minorStats
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal)
    }
    
    var favouritesView: some View {
        VStack(spacing: 24) {
            FavoritesView()
                .padding(.horizontal)
            Spacer(minLength: 0)
        }
    }
    
    var recnetlyPlayerView: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                if sessionsCompleted == 0 {
                    Text("Complete your first session to see your progress")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 32)
                } else {
                    RecentSessionsList()
                }
            }
            Spacer(minLength: 0)
        }
    }
    
    var specialsView: some View {
        VStack {
            Button {
                router.push(.selfLove14Days)
            } label: {
                valentinesBanner
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
                    .clipShape(RoundedRectangle(cornerRadius: 16))
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
        .padding(.horizontal)
    }
    
    var majorStats: some View {
        VStack {
            HStack(spacing: 12) {
                Image(systemName: "beats.headphones")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.blue)
                Text("Total Sessions")
                    .font(.system(size: 30))
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            Text(String(sessionsCompleted))
                .bold()
                .font(.largeTitle)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))
        }
    }
    
    var minorStats: some View {
        HStack {
            Spacer()
            StatView(
                title: "Sleepy Minutes",
                state: String(format: "%.1f", totalTimeListened / 60),
                icon: "clock"
            )
            Spacer()
            StatView(
                title: "Streaks",
                state: String(currentStreak),
                icon: "checkmark.arrow.trianglehead.counterclockwise"
            )
            Spacer()
        }
    }
    
    private var tabsSelection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(allTabs) { tab in
                    ChipButton(
                        title: tab.title,
                        isSelected: sleedtedTab?.id == tab.id
                    ) {
                        sleedtedTab = tab
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical)
        }
        .background(.black)
    }
}

struct StatView: View {
    
    let title: String
    let state: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            Text(title)
                .font(.headline)
            Text(String(state))
                .font(.system(size: 20))
        }
    }
}

// MARK: - Preview Provider
struct ProgressTabView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardTab()
            .environmentObject(Presenter())
            .environmentObject(ProgressManager.shared)
            .environmentObject(AudioManager.shared)
            .preferredColorScheme(.dark)
    }
}
