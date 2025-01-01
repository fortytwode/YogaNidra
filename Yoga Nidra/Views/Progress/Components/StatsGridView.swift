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

struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.title)
                .bold()
            
            Text(unit)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(uiColor: .systemGray6))
        .cornerRadius(12)
    }
} 