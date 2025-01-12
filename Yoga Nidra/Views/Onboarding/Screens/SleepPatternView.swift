import SwiftUI

struct SleepPatternView: View {
    let nextPage: () -> Void
    @StateObject private var preferencesManager = PreferencesManager.shared
    @State private var selectedOption: QuestionOption?
    
    let options = [
        QuestionOption(emoji: "⏰", text: "Less than 6 hours"),
        QuestionOption(emoji: "🌙", text: "6-8 hours"),
        QuestionOption(emoji: "✨", text: "8-10 hours"),
        QuestionOption(emoji: "💤", text: "More than 10 hours")
    ]
    
    var body: some View {
        QuestionScreenView(
            question: "How much sleep do you\nusually get?",
            subtitle: "We'll help you optimize your rest",
            options: options,
            selectedOption: $selectedOption,
            nextPage: {
                if let selected = selectedOption {
                    PreferencesManager.shared.updateSleepDuration(selected.text)
                }
                nextPage()
            }
        )
    }
} 