import SwiftUI

struct StatsView: View {
    @AppStorage(ProgressManager.shared.totalSessionListenTimeKey) var totalTimeListened = 0.0
    @AppStorage(ProgressManager.shared.totalSessionsCompletedKey) var sessionsCompleted = 0
    @AppStorage(ProgressManager.shared.streakCountKey) var currentStreak = 0
    
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
                    value: String(format: "%.2f", totalTimeListened / 60),
                    unit: "listened",
                    icon: "clock.fill"
                )
                
                StatisticCard(
                    title: "Sessions",
                    value: "\(sessionsCompleted)",
                    unit: "completed",
                    icon: "checkmark.circle.fill"
                )
                
                StatisticCard(
                    title: "Streak",
                    value: "\(currentStreak)",
                    unit: "days",
                    icon: "flame.fill"
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct StatisticCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.subheadline)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text("\(value) \(unit)")
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
        .environmentObject(Presenter())
        .environmentObject(ProgressManager.shared)
        .preferredColorScheme(.dark)
}
