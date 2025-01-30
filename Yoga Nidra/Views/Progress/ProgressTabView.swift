import SwiftUI

struct ProgressTabView: View {
    @StateObject var router = Router<ProgressTabDestination>()
    @EnvironmentObject var progressManager: ProgressManager
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        NavigationStack(path: $router.path) {
            VStack {
                ScrollView {
                    VStack(spacing: 24) {
                        StatsGridView()
                            .padding(.horizontal)
                        
                        StreakCard(streakDays: progressManager.streakDays)
                            .padding(.horizontal)
                        
                        FavoritesView()
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Recent Activity")
                                .font(.title2)
                                .bold()
                                .padding(.horizontal)
                            
                            if progressManager.sessionsCompleted == 0 {
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
                
                Divider()
                
                HStack(spacing: 24) {
                    Button {
                        openURL(URL(string: "http://rocketshiphq.com/yoga-nidra-terms")!)
                    } label: {
                        Text("Terms")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    
                    Button {
                        openURL(URL(string: "http://rocketshiphq.com/yoga-nidra-privacy")!)
                    } label: {
                        Text("Privacy Policy")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 12)
            }
            .navigationTitle("Your Progress")
            .environmentObject(router)
            .navigationDestination(for: ProgressTabDestination.self) { destination in
                switch destination {
                case .none:
                    Text("No view for ProgressTabDestination")
                }
            }
        }
    }
}

#Preview {
    ProgressTabView()
        .environmentObject(ProgressManager.shared)
}
