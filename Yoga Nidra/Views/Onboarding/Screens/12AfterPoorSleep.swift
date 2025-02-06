import SwiftUI

struct AfterPoorSleepView: View {
    let nextPage: () -> Void
    @State private var selectedOption: Int? = nil
    
    let options = [
        (emoji: "✨", text: "Perfectly fine (dancing through dreams like a pro)"),
        (emoji: "😫", text: "Completely drained (my pillow is calling from across town)"),
        (emoji: "🥱", text: "Can't focus (sent my socks to snooze in the fridge)"),
        (emoji: "😴", text: "Low energy (my blanket's getting heavier by the minute)")
    ]
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Text("How do you feel after a poor night's sleep?")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.top, 32)
                
                Text("When your comfy dreams decide to play hide and seek ✨")
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
    AfterPoorSleepView(nextPage: {})
}
