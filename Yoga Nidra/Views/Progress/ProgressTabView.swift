import SwiftUI

struct ProgressTabView: View {
    @EnvironmentObject var progressManager: ProgressManager
    
    var body: some View {
        NavigationStack {
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
        }
    }
}