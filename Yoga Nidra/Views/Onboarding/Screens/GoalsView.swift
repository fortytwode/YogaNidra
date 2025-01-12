import SwiftUI

struct GoalsView: View {
    let nextPage: () -> Void
    @StateObject private var preferencesManager = PreferencesManager.shared
    @State private var selectedOption: QuestionOption?
    
    let options = [
        QuestionOption(emoji: "🧘‍♀️", text: "Inner peace"),
        QuestionOption(emoji: "💤", text: "Better sleep quality"),
        QuestionOption(emoji: "🌟", text: "Stress reduction"),
        QuestionOption(emoji: "🧠", text: "Mental clarity")
    ]
    
    var body: some View {
        QuestionScreenView(
            question: "What's your main goal with Yoga Nidra?",
            subtitle: "We'll personalize your journey",
            options: options,
            selectedOption: $selectedOption,
            nextPage: {
                if let selected = selectedOption {
                    preferencesManager.updateMainGoal(selected.text)
                }
                nextPage()
            }
        )
    }
} 