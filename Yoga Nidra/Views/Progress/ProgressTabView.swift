import SwiftUI

struct ProgressTabView: View {
    @StateObject var router = Router<ProgressTabDestination>()
    @EnvironmentObject var progressManager: ProgressManager
    
    var body: some View {
        NavigationStack(path: $router.path) {
            ScrollView {
                VStack(spacing: 24) {
                    StatsGridView()
                        .padding(.horizontal)
                    
                    StreakCard(streakDays: progressManager.streakDays)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        Text("Recent Activity")
                            .font(.title2)
                            .bold()
                            .padding(.horizontal)
                        
                        RecentSessionsList()
                    }
                }
                .padding(.vertical)
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
