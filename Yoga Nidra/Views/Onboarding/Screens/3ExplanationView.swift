import SwiftUI

struct ExplanationView: View {
    let nextPage: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    Text("What is Yoga Nidra? ✨")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 40)
                    
                    // First Equation
                    let firstFormula = ["🧘‍♀️ Yoga", "+", "😴 Nidra", "=", "✨ Yogic Sleep"]
                    formulaView(parts: firstFormula)
                    
                    // Warm Hug Section
                    sectionView(
                        title: "Like a warm hug for your mind:",
                        items: [
                            (emoji: "💆‍♀️", text: "A spa day for your thoughts"),
                            (emoji: "🌙", text: "Your personal sleep whisperer"),
                            (emoji: "✨", text: "Nature's deepest rest recipe")
                        ]
                    )
                    
                    // Science Section
                    sectionView(
                        title: "The snuggly science:",
                        items: [
                            (emoji: "🧠", text: "Tucks your brain in like a pro"),
                            (emoji: "💫", text: "Drifts you into delta waves"),
                            (emoji: "🌟", text: "Helps you float off to dreamland")
                        ]
                    )
                    
                    // Bottom Equation - Vertical layout to ensure visibility
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Text("🧘‍♀️ Ancient wisdom")
                                .lineLimit(1)
                            Text("+")
                            Text("🔬 Modern science")
                                .lineLimit(1)
                        }
                        
                        HStack {
                            Text("= 💫 Sweet dreams")
                        }
                        
                    }
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .padding(.vertical, 0)
                    .padding(.horizontal)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            
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
    
    private func formulaView(parts: [String]) -> some View {
        HStack(spacing: 6) {
            ForEach(parts, id: \.self) { part in
                Text(part)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .font(.system(size: 20))
        .foregroundColor(.white)
        .padding(.vertical, 8)
        .multilineTextAlignment(.center)
    }
    
    private func sectionView(title: String, items: [(emoji: String, text: String)]) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(title)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 16) {
                ForEach(items, id: \.text) { item in
                    HStack(alignment: .top, spacing: 12) {
                        Text(item.emoji)
                            .font(.system(size: 24))
                        Text(item.text)
                            .font(.system(size: 17))
                            .foregroundColor(.white)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.2))
        .cornerRadius(16)
    }
}

#Preview {
    ExplanationView(nextPage: {})
        .preferredColorScheme(.dark)
}
