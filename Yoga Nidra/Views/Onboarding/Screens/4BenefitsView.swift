import SwiftUI

struct BenefitsView: View {
    let nextPage: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            ScrollView {
                VStack(spacing: 32) {
                    // Header Section
                    VStack(spacing: 16) {
                        Text("✨ LOVE IT OR SNOOZE IT: FAIR TRIAL POLICY")
                            .font(.system(size: 14, weight: .medium))
                            .kerning(1.2)
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text("Start with a free trial,\nstay for the sweet dreams")
                            .font(.system(size: 32, weight: .bold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text("🧁Like a free sample at the sleep bakery🥐")
                            .font(.system(size: 17))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.top, 40)
                    
                    // Price Comparison Cards
                    HStack(spacing: 20) {
                        HStack(spacing: 8) {
                            Text("😴")
                                .font(.system(size: 32))
                            Text("Sweet\ndreams\nnightly")
                                .font(.system(size: 15))
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity)
                        
                        Text("for less\nthan")
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                        
                        HStack(spacing: 8) {
                            Text("☕️")
                                .font(.system(size: 32))
                            Text("your daily\ncaffeine fix")
                                .font(.system(size: 15))
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    
                    // Value Proposition
                    Text("Every subscription helps us bake more peaceful moments for those who need them most 🌙")
                        .font(.system(size: 15))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Benefits Section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Our recipe for better sleep:")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            benefitRow(emoji: "📊", text: "44% less stress on your mind")
                            benefitRow(emoji: "⏰", text: "Fall asleep faster than a cat in sunshine")
                            benefitRow(emoji: "✨", text: "20 min power-ups into hours of rest")
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(white: 0.1))
                    .cornerRadius(16)
                    .padding(.horizontal, 24)
                }
            }
            .scrollIndicators(.hidden)
            
            // Continue Button
            Button(action: nextPage) {
                Text("Continue →")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
        }
        .background(
            ZStack {
                Image("northern-lights")
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
        HStack(alignment: .top, spacing: 12) {
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
    BenefitsView(nextPage: {})
        .preferredColorScheme(.dark)
}
