import SwiftUI

struct MorningTirednessView: View {
    let nextPage: () -> Void
    @State private var selectedOption: QuestionOption?
    
    let options = [
        QuestionOption(emoji: "✨", text: "Rarely or never"),
        QuestionOption(emoji: "🌅", text: "1-2 times a week"),
        QuestionOption(emoji: "😴", text: "3-5 times a week"),
        QuestionOption(emoji: "💤", text: "Almost every morning")
    ]
    
    var body: some View {
        QuestionScreenView(
            question: "How often do you wake up tired in the morning?",
            subtitle: "We'll help you wake up refreshed",
            options: options,
            selectedOption: $selectedOption,
            nextPage: nextPage
        )
    }
} 