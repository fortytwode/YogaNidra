import SwiftUI

struct SleepQuantityView: View {
    let nextPage: () -> Void
    @StateObject private var preferencesManager = PreferencesManager.shared
    @State private var selectedOption: QuestionOption?
    
    private let options = [
        QuestionOption(emoji: "⏰", text: "Just a cat nap (< 6 hours)"),
        QuestionOption(emoji: "🌓", text: "Getting there (6-8 hours)"),
        QuestionOption(emoji: "✨", text: "Sweet spot (8-10 hours)"),
        QuestionOption(emoji: "💫", text: "Sleeping champion (10+ hours)")
    ]
    
    var body: some View {
        QuestionScreenView(
            question: "How long do you usually sleep each night?",
            subtitle: "Let's talk about your sleep time ✨",
            helperText: "Together we'll find your natural sleep rhythm ✨",
            options: options,
            selectedOption: $selectedOption,
            nextPage: {
                if let selected = selectedOption {
                    preferencesManager.updateSleepDuration(selected.text)
                }
                nextPage()
            }
        )
    }
}

struct SleepQuantityView_Previews: PreviewProvider {
    static var previews: some View {
        SleepQuantityView(nextPage: {})
    }
}
