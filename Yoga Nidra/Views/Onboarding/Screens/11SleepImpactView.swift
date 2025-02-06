import SwiftUI

struct SleepImpactView: View {
    let nextPage: () -> Void
    @State private var selectedOption: Int? = nil
    
    let options = [
        (emoji: "⭐️", text: "Not at all (bright-eyed and bushy-tailed!)"),
        (emoji: "🌙", text: "Slightly (could use an extra snuggle)"),
        (emoji: "🛏", text: "Moderately (pillow's calling my name)"),
        (emoji: "🌠", text: "Significantly (ready for a cozy hibernation)")
    ]
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Text("How much does lack of sleep affect your daily life?")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.top, 32)
                
                Text("Let's find your perfect path to dreamland ✨")
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
    SleepImpactView(nextPage: {})
}
