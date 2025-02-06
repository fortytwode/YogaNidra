import SwiftUI

struct StatsGridView: View {
    @EnvironmentObject var progressManager: ProgressManager
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatCard(
                title: "Total Time",
                value: "\(progressManager.totalMinutesListened)",
                unit: "minutes",
                icon: "clock.fill"
            )
            
            StatCard(
                title: "Sessions",
                value: "\(progressManager.sessionsCompleted)",
                unit: "completed",
                icon: "checkmark.circle.fill"
            )
        }
    }
}

#Preview {
    StatsGridView()
        .environmentObject(ProgressManager.preview)
        .padding()
}
