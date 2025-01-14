import SwiftUI

struct OnboardingQuestionWrapper<Content: View>: View {
    let currentStep: Int
    let content: Content
    
    init(currentStep: Int, @ViewBuilder content: () -> Content) {
        self.currentStep = currentStep
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Add some space at the top
            Color.clear
                .frame(height: 48)
            
            // Progress bar
            GeometryReader { geometry in
                let progress = CGFloat(currentStep) / 8.0 // 8 question screens total
                
                ZStack(alignment: .leading) {
                    // Background bar
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 6)
                    
                    // Progress bar
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * progress, height: 6)
                }
                .cornerRadius(3)
            }
            .frame(height: 6)
            .padding(.horizontal)
            
            // Add space between progress bar and content
            Color.clear
                .frame(height: 32)
            
            // Content
            content
        }
    }
}
