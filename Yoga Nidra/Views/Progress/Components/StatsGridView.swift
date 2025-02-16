import SwiftUI

struct StatsGridView: View {
    @AppStorage(StroageKeys.totalSessionListenTimeKey) var totalTimeListened = 0.0
    @AppStorage(StroageKeys.totalSessionsCompletedKey) var sessionsCompleted = 0
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatCard(
                title: "Total Time",
                value: String(format: "%.2f", totalTimeListened / 60),
                unit: "minutes",
                icon: "clock.fill"
            )
            
            StatCard(
                title: "Sessions",
                value: "\(sessionsCompleted)",
                unit: "completed",
                icon: "checkmark.circle.fill"
            )
        }
    }
}

#Preview {
    StatsGridView()
        .environmentObject(ProgressManager.shared)
        .padding()
}
