import SwiftUI

struct ProfileTabView: View {
    @StateObject var router = Router<ProfileTabDestination>()
    @EnvironmentObject private var storeManager: StoreManager
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var sheetPresenter: Presenter
    @EnvironmentObject var audioManager: AudioManager
    @AppStorage(StroageKeys.streakCountKey) var currentStreak = 0
    @AppStorage(StroageKeys.totalSessionsCompletedKey) var sessionsCompleted = 0
    @AppStorage(StroageKeys.totalSessionListenTimeKey) var totalTimeListened = 0.0
    
    var body: some View {
        NavigationStack(path: $router.path) {
            ScrollView {
                VStack(spacing: 24) {
                    // Premium Member Status
                    membershipStatusView
                    
                    // Statistics Card
                    VStack(spacing: 10) {
                        majorStats
                        minorStats
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.3))
                    }
                    
                    // Settings Sections
                    appSettingsSection
                    linksSection
                    
                    // Conditional Upgrade Button
                    if !storeManager.isSubscribed {
                        upgradeButton
                    }
                    
                    Spacer(minLength: 0)
                }
                .padding(.horizontal)
            }
            .navigationDestination(for: ProfileTabDestination.self) { dest in
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
    
    // MARK: - Premium Member Status
    var membershipStatusView: some View {
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
    }
    
    // MARK: - Stats Views
    var majorStats: some View {
        VStack {
            HStack(spacing: 12) {
                Image(systemName: "beats.headphones")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.blue)
                Text("Total Sessions")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 4)
            
            Text("\(sessionsCompleted)")
                .font(.system(size: 42, weight: .bold))
        }
    }
    
    var minorStats: some View {
        HStack {
            VStack(spacing: 4) {
                Image(systemName: "clock")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.blue)
                
                Text("Sleepy Minutes")
                    .font(.subheadline)
                
                Text(String(format: "%.1f", totalTimeListened / 60))
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            
            VStack(spacing: 4) {
                Image(systemName: "flame")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.blue)
                
                Text("Streaks")
                    .font(.subheadline)
                
                Text("\(currentStreak)")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    // MARK: - Settings Sections
    var linksSection: some View {
        HStack(spacing: 16) {
            Button {
                openURL(URL(string: "http://rocketshiphq.com/yoga-nidra-terms")!)
            } label: {
                Text("Terms of Service")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            
            Button {
                openURL(URL(string: "http://rocketshiphq.com/yoga-nidra-privacy")!)
            } label: {
                Text("Privacy Policy")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 8)
    }
    
    var appSettingsSection: some View {
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
    }
    
    var upgradeButton: some View {
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
    }
}

// MARK: - Preview Provider
#if DEBUG
struct ProfileTabView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileTabView()
            .environmentObject(StoreManager.preview)
            .environmentObject(Presenter.preview)
            .environmentObject(AudioManager.preview)
    }
}
#endif
