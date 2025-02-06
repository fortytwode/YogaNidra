import SwiftUI

struct FallAsleepView: View {
    let nextPage: () -> Void
    @StateObject private var preferencesManager = PreferencesManager.shared
    @State private var selectedOption: QuestionOption?
    
    private let options = [
        QuestionOption(emoji: "⚡️", text: "Fast as lightning (< 10 min)"),
        QuestionOption(emoji: "🌙", text: "Takes a little while (10-30 min)"),
        QuestionOption(emoji: "🌟", text: "Quite some time (30-60 min)"),
        QuestionOption(emoji: "✨", text: "Feels like forever (> 60 min)")
    ]
    
    var body: some View {
        VStack {
            QuestionScreenView(
                question: "How long does it take you to fall asleep?",
                subtitle: "Let's find your perfect bedtime rhythm 🌙",
                helperText: "Sweet dreams are on the way ✨",
                options: options,
                selectedOption: $selectedOption,
                nextPage: {
                    if let selected = selectedOption {
                        preferencesManager.updateFallAsleepTime(selected.text)
                    }
                    nextPage()
                }
            )
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
}

#Preview {
    FallAsleepView(nextPage: {})
}