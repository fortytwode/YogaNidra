import SwiftUI

struct StatsView: View {
    @EnvironmentObject var progressManager: ProgressManager
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Your Progress")
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatisticCard(
                    title: "Total Time",
                    value: formatTime(progressManager.totalTimeListened)
                )
                
                StatisticCard(
                    title: "Sessions",
                    value: "\(progressManager.sessionsCompleted)"
                )
                
                StatisticCard(
                    title: "Streak",
                    value: "\(progressManager.currentStreak) days"
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval / 3600)
        if hours > 0 {
            return "\(hours)h"
        }
        let minutes = Int(timeInterval / 60)
        return "\(minutes)m"
    }
}

struct StatisticCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title3)
                .bold()
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

#Preview {
    StatsView()
        .environmentObject(ProgressManager.preview)
        .preferredColorScheme(.dark)
}
