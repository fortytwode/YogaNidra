import SwiftUI

struct SleepScienceView: View {
    let nextPage: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Text("Your sleep can improve dramatically")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("Research shows Yoga Nidra helps:")
                .font(.title3)
                .foregroundColor(.white)
            
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
            .background(Color(white: 0.2))
            .cornerRadius(16)
            
            Spacer()
            
            Button(action: nextPage) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal, 24)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
    
    private func benefitRow(icon: String, highlight: String, description: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 4) {
                if !highlight.isEmpty {
                    Text(highlight)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                Text(description)
                    .font(.body)
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    SleepScienceView(nextPage: {})
} 