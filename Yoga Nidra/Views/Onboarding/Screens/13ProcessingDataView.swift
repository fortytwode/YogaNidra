import SwiftUI

struct ProcessingDataView: View {
    @State private var scale: CGFloat = 1.0
    @State private var currentMessageIndex = 0
    @State private var messageOpacity = 1.0
    let nextPage: () -> Void
    
    let loadingMessages = [
        "Crafting your sleep sanctuary...",
        "Preparing your dream retreat...",
        "Tailoring your rest experience..."
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            Circle()
                .stroke(Color.white, lineWidth: 2)
                .frame(width: 80, height: 80)
                .scaleEffect(scale)
                .opacity(2 - scale)
                .animation(
                    .easeInOut(duration: 1)
                    .repeatForever(autoreverses: false),
                    value: scale
                )
            
            Text(loadingMessages[currentMessageIndex])
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .opacity(messageOpacity)
                .animation(.easeInOut(duration: 0.5), value: messageOpacity)
        }
        .onAppear {
            scale = 2.0
            startMessageAnimation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                nextPage()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image("mountain-lake-twilight")
                .resizable()
                .scaledToFill()
                .overlay(Color.black.opacity(0.6))
                .ignoresSafeArea()
        )
    }
    
    private func startMessageAnimation() {
        // Create a timer to cycle through messages
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            withAnimation {
                messageOpacity = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                currentMessageIndex = (currentMessageIndex + 1) % loadingMessages.count
                withAnimation {
                    messageOpacity = 1
                }
            }
        }
    }
}

#Preview {
    ProcessingDataView(nextPage: {})
}