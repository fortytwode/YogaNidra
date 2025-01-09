import SwiftUI

struct SleepImpactView: View {
    let nextPage: () -> Void
    @State private var selectedOption: QuestionOption?
    
    let options = [
        QuestionOption(emoji: "🎯", text: "Not at all"),
        QuestionOption(emoji: "🌤", text: "Slightly"),
        QuestionOption(emoji: "⛈", text: "Moderately"),
        QuestionOption(emoji: "⚡️", text: "Significantly")
    ]
    
    var body: some View {
        QuestionScreenView(
            question: "How much does lack of sleep affect your daily life?",
            subtitle: "Your answer helps us customize your experience",
            options: options,
            selectedOption: $selectedOption,
            nextPage: nextPage
        )
    }
}

#Preview {
    SleepImpactView(nextPage: {})
} 