import SwiftUI

struct DisvoverTabItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    
    static let favouritesTab: Self = .init(title: "Favorites")
    static let recnentlyPlayed: Self = .init(title: "Recently Played")
    static let special: Self = .init(title: "Specials")
    
    static var allDefinedTabs: [Self] {
        [special, .favouritesTab, .recnentlyPlayed]
    }
}

struct DiscoverTab: View {
    @StateObject var router = Router<DisoverTabDestination>()
    @State private var sleedtedTab: DisvoverTabItem? = .allDefinedTabs.first
    @State private var allTabs: [DisvoverTabItem] = DisvoverTabItem.allDefinedTabs
    @EnvironmentObject var audioManager: AudioManager
    @AppStorage(StroageKeys.totalSessionsCompletedKey) var sessionsCompleted = 0
    
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
            .navigationDestination(for: DisoverTabDestination.self) { dest in
                switch dest {
                case .selfLove14Days:
                    SelfLove14days()
                case .springReset:
                    SpringReset()
                }
            }
        }
    }
    
    @ViewBuilder
    func getViw(for tab: DisvoverTabItem) -> some View {
        switch tab.title {
        case DisvoverTabItem.favouritesTab.title:
            favouritesView
        case DisvoverTabItem.recnentlyPlayed.title:
            recnetlyPlayerView
        case DisvoverTabItem.special.title:
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
