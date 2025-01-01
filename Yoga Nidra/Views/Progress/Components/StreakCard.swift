import SwiftUI

struct StreakCard: View {
    let streakDays: Int
    
    var body: some View {
        VStack(spacing: 12) {
            Text("🔥 Current Streak")
                .font(.headline)
            
            Text("\(streakDays)")
                .font(.system(size: 44, weight: .bold))
            
            Text("days")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(uiColor: .systemGray6))
        .cornerRadius(12)
    }
} 