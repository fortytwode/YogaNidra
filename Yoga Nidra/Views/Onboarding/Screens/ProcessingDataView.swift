import SwiftUI

struct ProcessingDataView: View {
    @State private var scale: CGFloat = 1.0
    let nextPage: () -> Void
    
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
            
            Text("Creating your personalized\nsleep profile...")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
        }
        .onAppear {
            scale = 2.0
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
}

#Preview {
    ProcessingDataView(nextPage: {})
} 