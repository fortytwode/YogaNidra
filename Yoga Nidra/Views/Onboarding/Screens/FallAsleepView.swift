import SwiftUI

struct FallAsleepView: View {
    let nextPage: () -> Void
    @StateObject private var preferencesManager = PreferencesManager.shared
    @State private var selectedOption: QuestionOption?
    
    let options = [
        QuestionOption(emoji: "⚡️", text: "Less than 15 minutes"),
        QuestionOption(emoji: "🌙", text: "15-30 minutes"),
        QuestionOption(emoji: "🕐", text: "30-60 minutes"),
        QuestionOption(emoji: "😩", text: "Over an hour")
    ]
    
    var body: some View {
        QuestionScreenView(
            question: "How long does it take you to fall asleep?",
            subtitle: "We'll help you fall asleep faster",
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
}

#Preview {
    FallAsleepView(nextPage: {})
} 