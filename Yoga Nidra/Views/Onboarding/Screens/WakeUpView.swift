import SwiftUI

struct WakeUpView: View {
    let nextPage: () -> Void
    @State private var selectedOption: QuestionOption?
    
    let options = [
        QuestionOption(emoji: "✨", text: "Never"),
        QuestionOption(emoji: "🌓", text: "Sometimes"),
        QuestionOption(emoji: "🌑", text: "Often"),
        QuestionOption(emoji: "😴", text: "Every night")
    ]
    
    var body: some View {
        QuestionScreenView(
            question: "Do you wake up at night and have trouble getting back to sleep?",
            subtitle: "We'll help you stay asleep longer",
            options: options,
            selectedOption: $selectedOption,
            nextPage: nextPage
        )
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
}

#Preview {
    WakeUpView(nextPage: {})
} 