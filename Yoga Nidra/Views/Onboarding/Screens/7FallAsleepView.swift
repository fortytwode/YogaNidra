import SwiftUI

struct FallAsleepView: View {
    let nextPage: () -> Void
    @StateObject private var preferencesManager = PreferencesManager.shared
    @State private var selectedOption: QuestionOption?
    
    private let options = [
        QuestionOption(emoji: "⚡️", text: "Quick as a wink (< 15 mins)"),
        QuestionOption(emoji: "🌙", text: "Gentle drift (15-30 mins)"),
        QuestionOption(emoji: "⏰", text: "Taking my time (30-60 mins)"),
        QuestionOption(emoji: "😴", text: "Need some extra help (60+ mins)")
    ]
    
    var body: some View {
        QuestionScreenView(
            question: "How long does it take you to fall asleep?",
            subtitle: "We'll help you find your sleepy sweet spot",
            helperText: "Yoga Nidra is perfect for shortening that drift-off time 💫",
            options: options,
            selectedOption: $selectedOption,
            nextPage: {
                if let selected = selectedOption {
                    preferencesManager.updateFallAsleepTime(selected.text)
                }
                nextPage()
            }
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
    FallAsleepView(nextPage: {})
}