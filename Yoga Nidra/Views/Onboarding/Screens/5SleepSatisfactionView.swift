import SwiftUI

struct SleepSatisfactionView: View {
    let nextPage: () -> Void
    @StateObject private var preferencesManager = PreferencesManager.shared
    @State private var selectedOption: QuestionOption?
    
    private let options = [
        QuestionOption(emoji: "😊", text: "Sleeping like a baby"),
        QuestionOption(emoji: "😌", text: "Could be cozier"),
        QuestionOption(emoji: "😕", text: "Tossing & turning"),
        QuestionOption(emoji: "😫", text: "Need a sleep hug ASAP")
    ]
    
    var body: some View {
        VStack {
            QuestionScreenView(
                question: "How satisfied are you with your sleep?",
                subtitle: "Help us weave the perfect sleep routine for you 💫",
                helperText: "Let's talk about your sleep ✨",
                options: options,
                selectedOption: $selectedOption,
                nextPage: {
                    if let selected = selectedOption {
                        preferencesManager.updateSleepQuality(selected.text)
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

struct SleepSatisfactionView_Previews: PreviewProvider {
    static var previews: some View {
        SleepSatisfactionView(nextPage: {})
    }
}
