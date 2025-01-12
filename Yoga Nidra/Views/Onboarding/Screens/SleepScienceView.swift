import SwiftUI

struct SleepScienceView: View {
    let nextPage: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Text("Your sleep can improve dramatically")
                .font(.system(size: 32, weight: .bold))
                .multilineTextAlignment(.center)
            
            Text("Research shows Yoga Nidra helps:")
                .font(.title3)
                .foregroundColor(.gray)
            
            VStack(spacing: 24) {
                benefitRow(
                    icon: "clock.fill",
                    highlight: "30 minutes",
                    description: "Reduce time to fall asleep"
                )
                
                benefitRow(
                    icon: "waveform.path.ecg",
                    highlight: "75%",
                    description: "Increase deep sleep by over"
                )
                
                benefitRow(
                    icon: "moon.zzz.fill",
                    highlight: "",
                    description: "Improve sleep maintenance"
                )
            }
            .padding(24)
            .background(Color(uiColor: .systemGray6))
            .cornerRadius(16)
            
            Text("Source: Sleep Medicine Review, 2022")
                .font(.caption)
                .foregroundColor(.gray)
            
            Spacer()
            
            Button(action: nextPage) {
                Text("Start your journey to better sleep")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal, 24)
    }
    
    private func benefitRow(icon: String, highlight: String, description: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 44)
            
            if description.contains(highlight) {
                Text(description)
                    .font(.headline)
            } else {
                Text(description)
                    .font(.headline) +
                Text(" ") +
                Text(highlight)
                    .font(.headline)
                    .foregroundColor(.accentColor)
            }
        }
    }
}

#Preview {
    SleepScienceView(nextPage: {})
} 