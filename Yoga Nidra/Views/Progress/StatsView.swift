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
                StatCard(
                    title: "Total Time",
                    value: formatTime(progressManager.totalTimeListened),
                    unit: "listened",
                    icon: "clock.fill"
                )
                
                StatCard(
                    title: "Sessions",
                    value: "\(progressManager.sessionsCompleted)",
                    unit: "completed",
                    icon: "checkmark.circle.fill"
                )
                
                StatCard(
                    title: "Streak",
                    value: "\(progressManager.currentStreak)",
                    unit: "days",
                    icon: "flame.fill"
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
            return "\(hours)"
        }
        let minutes = Int(timeInterval / 60)
        return "\(minutes)"
    }
}

#Preview {
    StatsView()
        .environmentObject(ProgressManager.preview)
        .preferredColorScheme(.dark)
}
