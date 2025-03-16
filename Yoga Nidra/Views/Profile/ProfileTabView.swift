import SwiftUI

struct ProfileTabItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    
    static let dashboard: Self = .init(title: "Dashboard")
    static let settings: Self = .init(title: "Settings")
    
    static var allDefinedTabs: [Self] {
        [.dashboard, .settings]
    }
}

struct ProfileTabView: View {
    @StateObject var router = Router<ProgileTabDestination>()
    @EnvironmentObject private var storeManager: StoreManager
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var sheetPresenter: Presenter
    @EnvironmentObject var audioManager: AudioManager
    @State private var sleedtedTab: ProfileTabItem? = .allDefinedTabs.first
    @State private var allTabs: [ProfileTabItem] = ProfileTabItem.allDefinedTabs
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
            .navigationDestination(for: ProgileTabDestination.self) { dest in
                switch dest {
                case .settings:
                    NotificationSettingsView()
                }
            }
            .contentMargins(.bottom, audioManager.currentPlayingSession != nil ? 52 : 0, for: .scrollContent)
            .navigationTitle("Profile")
            .environmentObject(router)
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
    
    @ViewBuilder
    func getViw(for tab: ProfileTabItem) -> some View {
        switch tab.title {
        case ProfileTabItem.dashboard.title:
            dashboardView
        case ProfileTabItem.settings.title:
            settings
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
    
    var settings: some View {
        LazyVStack(spacing: 16) {
            // Subscription Status Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: storeManager.isSubscribed ? "lock.open" : "lock.fill")
                        .foregroundColor(.yellow)
                    Text(storeManager.isSubscribed ? "Premium Member" : "Free Member")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .cornerRadius(10)
            }
            .padding(.horizontal)
            
            // Links Section
            VStack(spacing: 8) {
                Button {
                    openURL(URL(string: "http://rocketshiphq.com/yoga-nidra-terms")!)
                } label: {
                    HStack {
                        Image(systemName: "doc.text")
                        Text("Terms of Service")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(.gray.opacity(0.3))
                    .cornerRadius(10)
                }
                
                Button {
                    openURL(URL(string: "http://rocketshiphq.com/yoga-nidra-privacy")!)
                } label: {
                    HStack {
                        Image(systemName: "hand.raised")
                        Text("Privacy Policy")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(.gray.opacity(0.3))
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            
            // App Settings Section
            VStack(alignment: .leading) {
                Text("App Settings")
                    .font(.headline)
                    .padding(.bottom, 8)
                
                Button {
                    router.push(.settings)
                } label: {
                    HStack {
                        Image(systemName: "bell")
                        Text("Notifications")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(.gray.opacity(0.3))
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            
            // Upgrade to Premium Button
            if !storeManager.isSubscribed {
                Button {
                    sheetPresenter.present(.subscriptionPaywall)
                } label: {
                    HStack {
                        Image(systemName: "crown")
                        Text("Upgrade to Premium")
                            .font(.headline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
}

// MARK: - Preview Provider
#if DEBUG
struct ProfileTabView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileTabView()
            .environmentObject(StoreManager.preview)
    }
}
#endif
