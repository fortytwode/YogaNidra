import SwiftUI

struct WakeupView: View {
    let nextPage: () -> Void
    @State private var selectedOption: Int? = nil
    
    let options = [
        (emoji: "✨", text: "Never (sweet dreams all night!)"),
        (emoji: "🌗", text: "Sometimes (occasional midnight wanderer)"),
        (emoji: "🌑", text: "Often (frequent stargazer)"),
        (emoji: "😴", text: "Every night (professional moon watcher)")
    ]
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                Text("How often do you wake up in the middle of the night?")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.top, 32)
                
                Text("Let's find your perfect midnight peace recipe 🌙")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 16) {
                ForEach(0..<options.count, id: \.self) { index in
                    Button(action: {
                        selectedOption = index
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            nextPage()
                        }
                    }) {
                        HStack(spacing: 16) {
                            Text(options[index].emoji)
                                .font(.title2)
                            
                            Text(options[index].text)
                                .font(.body)
                                .foregroundColor(.white)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                            
                            if selectedOption == index {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity)
                        .background(Color(white: selectedOption == index ? 0.3 : 0.2))
                        .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .background(
            Image("mountain-lake-twilight")
                .resizable()
                .scaledToFill()
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.4),
                            Color.black.opacity(0.6)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .ignoresSafeArea()
        )
    }
}

#Preview {
    WakeupView(nextPage: {})
}
