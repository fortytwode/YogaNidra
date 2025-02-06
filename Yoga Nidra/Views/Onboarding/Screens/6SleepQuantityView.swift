import SwiftUI

struct SleepQuantityView: View {
    let nextPage: () -> Void
    @StateObject private var preferencesManager = PreferencesManager.shared
    @State private var selectedOption: QuestionOption?
    
    private let options = [
        QuestionOption(emoji: "😴", text: "Less than 6 hours"),
        QuestionOption(emoji: "🌙", text: "6-7 hours"),
        QuestionOption(emoji: "✨", text: "7-8 hours"),
        QuestionOption(emoji: "💫", text: "More than 8 hours")
    ]
    
    var body: some View {
        VStack {
            QuestionScreenView(
                question: "How many hours do you usually sleep?",
                subtitle: "Let's understand your sleep patterns 🌙",
                helperText: "Every minute of rest counts ✨",
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
        .background(
            ZStack {
                Image("northern-lights")
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

struct SleepQuantityView_Previews: PreviewProvider {
    static var previews: some View {
        SleepQuantityView(nextPage: {})
    }
}
