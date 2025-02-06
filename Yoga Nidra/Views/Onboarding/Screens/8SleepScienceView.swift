import SwiftUI

struct SleepScienceView: View {
    let nextPage: () -> Void
    
    var body: some View {
        ZStack {
            // Background
            Image("mountain-lake-twilight")
                .resizable()
                .scaledToFill()
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.4),
                            Color.black.opacity(0.6)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .ignoresSafeArea()
            
            // Content
            VStack(spacing: 0) {
                VStack(spacing: 24) {
                    Text("Here's what we'll mix into\nyour practice:")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 32)
                    
                    Text("Yoga Nidra practitioners report...")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
                
                VStack(alignment: .leading, spacing: 24) {
                    // Main benefits
                    VStack(alignment: .leading, spacing: 20) {
                        benefitRow(emoji: "⬇️", text: "A generous cup of calm (27% less stress)")
                        benefitRow(emoji: "💗", text: "Heart harmony (whipped until fluffy)")
                        benefitRow(emoji: "🧘‍♀️", text: "Inner peace (baked low and slow)")
                    }
                    .padding(.vertical, 24)
                    
                    // Additional benefits
                    VStack(alignment: .leading, spacing: 20) {
                        benefitRow(emoji: "🌊", text: "Deep sleep drizzle")
                        benefitRow(emoji: "✨", text: "Morning brightness glaze")
                        benefitRow(emoji: "🌙", text: "Midnight comfort sprinkles")
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)
                
                Spacer()
                
                // CTA Button
                Button(action: nextPage) {
                    HStack {
                        Text("Continue your journey")
                            .fontWeight(.medium)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
        }
    }
    
    private func benefitRow(emoji: String, text: String) -> some View {
        HStack(alignment: .center, spacing: 16) {
            Text(emoji)
                .font(.title2)
            Text(text)
                .font(.body)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    SleepScienceView(nextPage: {})
}
