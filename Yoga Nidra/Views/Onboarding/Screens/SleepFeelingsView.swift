import SwiftUI

struct SleepFeelingsView: View {
    let nextPage: () -> Void
    @StateObject private var preferencesManager = PreferencesManager.shared
    @State private var selectedOption: QuestionOption?
    
    let options = [
        QuestionOption(emoji: "😫", text: "Completely drained"),
        QuestionOption(emoji: "😤", text: "Irritable"),
        QuestionOption(emoji: "🤯", text: "Can't focus"),
        QuestionOption(emoji: "😔", text: "Low energy")
    ]
    
    var body: some View {
        QuestionScreenView(
            question: "How do you feel after a poor night's sleep?",
            subtitle: "Let's understand your experience better",
            options: options,
            selectedOption: $selectedOption,
            nextPage: {
                if let selected = selectedOption {
                    preferencesManager.updateSleepFeelings(selected.text)
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