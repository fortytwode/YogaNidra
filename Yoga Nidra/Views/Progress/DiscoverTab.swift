import SwiftUI

struct DiscoverTabItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    
    static let favouritesTab: Self = .init(title: "Favorites")
    static let recentlyPlayed: Self = .init(title: "Recently Played")
    static let special: Self = .init(title: "Specials")
    
    static var allDefinedTabs: [Self] {
        [special, .favouritesTab, .recentlyPlayed]
    }
}

struct DiscoverTab: View {
    @StateObject var router = Router<DisoverTabDestination>()
    @State private var selectedTab: DiscoverTabItem? = .allDefinedTabs.first
    @State private var allTabs: [DiscoverTabItem] = DiscoverTabItem.allDefinedTabs
    @EnvironmentObject var audioManager: AudioManager
    @AppStorage(StroageKeys.totalSessionsCompletedKey) var sessionsCompleted = 0
    
    var body: some View {
        NavigationStack(path: $router.path) {
            ScrollView {
                LazyVStack(pinnedViews: [.sectionHeaders]) {
                    Section(header: tabsSelection) {
                        if let selectedTab {
                            getView(for: selectedTab)
                        }
                    }
                }
            }
            .contentMargins(.bottom, audioManager.currentPlayingSession != nil ? 52 : 0, for: .scrollContent)
            .navigationTitle(selectedTab?.title ?? "Dashboard")
            .navigationDestination(for: DisoverTabDestination.self) { dest in
                switch dest {
                case .selfLove14Days:
                    SelfLove14days()
                case .springReset:
                    SpringReset()
                case .earthMonth:
                    EarthMonth()
                }
            }
        }
    }
    
    @ViewBuilder
    func getView(for tab: DiscoverTabItem) -> some View {
        switch tab.title {
        case DiscoverTabItem.favouritesTab.title:
            favouritesView
        case DiscoverTabItem.recentlyPlayed.title:
            recentlyPlayedView
        case DiscoverTabItem.special.title:
            specialsView
        default:
            fatalError("No tab identified for \(tab.title)")
        }
    }
    
    var favouritesView: some View {
        VStack(spacing: 24) {
            FavoritesView()
                .padding(.horizontal)
            Spacer(minLength: 0)
        }
    }
    
    var recentlyPlayedView: some View {
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
                router.push(.earthMonth)
            } label: {
                EarthMonthBanner()
            }
            Button {
                router.push(.springReset)
            } label: {
                springResetBanner
            }
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
    
    var springResetBanner: some View {
        ZStack {
            Image("spring_reset")
                .resizable()
                .aspectRatio(1, contentMode: .fill)
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [.springGreen.opacity(0.5)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                )
            VStack {
                Text("Spring Reset: 10 Nights to Renewed Rest.")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                Spacer()
                Text("Spring forward into deeper rest. Tap to renew yourself. 🌺")
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                .padding()
            }
        }
        .padding(.horizontal)
    }
    
    private var tabsSelection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(allTabs) { tab in
                    ChipButton(
                        title: tab.title,
                        isSelected: selectedTab?.id == tab.id
                    ) {
                        selectedTab = tab
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical)
        }
        .background(.black)
    }
}

// MARK: - Preview Provider
struct ProgressTabView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverTab()
            .environmentObject(Presenter())
            .environmentObject(ProgressManager.shared)
            .environmentObject(AudioManager.shared)
            .preferredColorScheme(.dark)
    }
}
