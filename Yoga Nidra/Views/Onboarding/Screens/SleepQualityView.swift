import SwiftUI

struct SleepQualityView: View {
    let nextPage: () -> Void
    @StateObject private var preferencesManager = PreferencesManager.shared
    @State private var selectedOption: QuestionOption?
    
    let options = [
        QuestionOption(emoji: "😊", text: "Very satisfied"),
        QuestionOption(emoji: "😐", text: "Neutral"),
        QuestionOption(emoji: "😕", text: "Unsatisfied"),
        QuestionOption(emoji: "😫", text: "Very unsatisfied")
    ]
    
    var body: some View {
        QuestionScreenView(
            question: "How satisfied are you with your sleep?",
            subtitle: "This helps us personalize your experience",
            options: options,
            selectedOption: $selectedOption,
            nextPage: {
                if let selected = selectedOption {
                    preferencesManager.updateSleepQuality(selected.text)
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