import SwiftUI

struct OnboardingProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    
    private let barHeight: CGFloat = 4
    private let progressColor = Color.blue
    private let backgroundColor = Color.gray.opacity(0.3)
    
    var progress: CGFloat {
        CGFloat(currentStep) / CGFloat(totalSteps)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background bar
                Rectangle()
                    .fill(backgroundColor)
                    .frame(height: barHeight)
                    .cornerRadius(barHeight / 2)
                
                // Progress bar
                Rectangle()
                    .fill(progressColor)
                    .frame(width: geometry.size.width * progress, height: barHeight)
                    .cornerRadius(barHeight / 2)
            }
        }
        .frame(height: barHeight)
        .padding(.horizontal)
    }
}
