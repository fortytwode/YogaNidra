import SwiftUI

struct ProgressTabView: View {
    @StateObject var router = Router<ProgressTabDestination>()
    @EnvironmentObject var audioManager: AudioManager
    @Environment(\.openURL) private var openURL
    @AppStorage(ProgressManager.shared.streakCountKey) var currentStreak = 0
    @AppStorage(ProgressManager.shared.totalSessionsCompletedKey) var sessionsCompleted = 0
    
    var body: some View {
        NavigationStack(path: $router.path) {
            VStack {
                ScrollView {
                    VStack(spacing: 24) {
                        StatsGridView()
                            .padding(.horizontal)
                        
                        StreakCard(streakDays: currentStreak)
                            .padding(.horizontal)
                        
                        FavoritesView()
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Recent Activity")
                                .font(.title2)
                                .bold()
                                .padding(.horizontal)
                            
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
                    .padding(.vertical)
                }
                .contentMargins(.bottom, audioManager.currentPlayingSession != nil ? 52 : 0, for: .scrollContent)
                
                Divider()
                
                HStack(spacing: 24) {
                    if let termsURL = URL(string: "http://rocketshiphq.com/yoga-nidra-terms") {
                        Button {
                            openURL(termsURL)
                        } label: {
                            Text("Terms")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let privacyURL = URL(string: "http://rocketshiphq.com/yoga-nidra-privacy") {
                        Button {
                            openURL(privacyURL)
                        } label: {
                            Text("Privacy")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Progress")
            .navigationDestination(for: ProgressTabDestination.self) { _ in
                EmptyView()
            }
        }
    }
}

// MARK: - Preview Provider
struct ProgressTabView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressTabView()
            .environmentObject(Presenter())
            .environmentObject(ProgressManager.shared)
    }
}
