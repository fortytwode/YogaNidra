import SwiftUI

struct RelaxationObstaclesView: View {
    let nextPage: () -> Void
    @StateObject private var preferencesManager = PreferencesManager.shared
    @State private var selectedOption: QuestionOption?
    
    let options = [
        QuestionOption(emoji: "💭", text: "Racing thoughts"),
        QuestionOption(emoji: "💪", text: "Physical tension"),
        QuestionOption(emoji: "🔊", text: "Environmental noise"),
        QuestionOption(emoji: "⏰", text: "Time management")
    ]
    
    var body: some View {
        QuestionScreenView(
            question: "What's your biggest obstacle to relaxation?",
            subtitle: "We'll help you overcome it",
            options: options,
            selectedOption: $selectedOption,
            nextPage: {
                if let selected = selectedOption {
                    preferencesManager.updateRelaxationObstacle(selected.text)
                }
                nextPage()
            }
        )
    }
} 