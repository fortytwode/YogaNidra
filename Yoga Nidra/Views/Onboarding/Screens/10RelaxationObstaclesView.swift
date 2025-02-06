import SwiftUI

struct RelaxationObstaclesView: View {
    let nextPage: () -> Void
    @State private var selectedOption: Int? = nil
    
    let options = [
        (emoji: "💭", text: "Racing thoughts (mind needs a gentle hush)"),
        (emoji: "💪", text: "Physical tension (muscles need a gentle unwinding)"),
        (emoji: "🔊", text: "Environmental noise (longing for a quiet snuggle spot)"),
        (emoji: "⏰", text: "Time management (searching for your cozy moments)")
    ]
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Text("What's keeping you from drifting into dreamland?")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.top, 32)
                
                Text("Let's wrap you in tranquility, like your favorite comfort blanket ✨")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 16) {
                ForEach(0..<options.count, id: \.self) { index in
                    Button(action: {
                        selectedOption = index
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            nextPage()
                        }
                    }) {
                        HStack(spacing: 16) {
                            Text(options[index].emoji)
                                .font(.title2)
                            
                            Text(options[index].text)
                                .font(.body)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            if selectedOption == index {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(white: selectedOption == index ? 0.3 : 0.2))
                        .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .background(
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
        )
    }
}

#Preview {
    RelaxationObstaclesView(nextPage: {})
}