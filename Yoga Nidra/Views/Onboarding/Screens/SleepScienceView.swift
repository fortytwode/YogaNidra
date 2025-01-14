import SwiftUI

struct SleepScienceView: View {
    let nextPage: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Text("Based on your responses, Yoga Nidra can help you get deeper, more restorative sleep.")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 60)
                
                Text("Yoga Nidra practitioners report...")
                    .font(.title3)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
            
            VStack(spacing: 24) {
                // Container 1: Physiological Benefits
                VStack(alignment: .leading, spacing: 16) {
                    benefitRow(emoji: "💗", text: "Improved heart rate variability")
                    benefitRow(emoji: "⬇️", text: "27% reduction in cortisol levels")
                    benefitRow(emoji: "🧘‍♀️", text: "Enhanced parasympathetic activation")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(white: 0.2))
                .cornerRadius(16)
                
                // Container 2: Sleep Benefits
                VStack(alignment: .leading, spacing: 16) {
                    benefitRow(emoji: "🌊", text: "Increased slow-wave sleep")
                    benefitRow(emoji: "🌅", text: "Improved morning alertness")
                    benefitRow(emoji: "✨", text: "Reduced nighttime awakenings")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(white: 0.2))
                .cornerRadius(16)
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            Button(action: nextPage) {
                HStack {
                    Text("Tell us more")
                    Text("→")
                }
                .font(.headline)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(
            ZStack {
                Image("mountain-lake-twilight")
                    .resizable()
                    .scaledToFill()
                
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.3),
                        Color.black.opacity(0.5)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .ignoresSafeArea()
        )
    }
    
    private func benefitRow(emoji: String, text: String) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Text(emoji)
                .font(.title2)
            Text(text)
                .font(.body)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    SleepScienceView(nextPage: {})
}