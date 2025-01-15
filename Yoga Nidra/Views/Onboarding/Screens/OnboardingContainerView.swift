import SwiftUI

struct OnboardingContainerView: View {
    @State private var currentPage = 0
    @EnvironmentObject var audioManager: AudioManager
    
    var body: some View {
        TabView(selection: $currentPage) {
            // Information screens (no progress bar)
            WelcomeView(nextPage: nextPage)
                .tag(0)
            
            GoalsView(nextPage: nextPage)
                .tag(1)
            
            ExplanationView(nextPage: nextPage)
                .tag(2)
            
            BenefitsView(nextPage: nextPage)
                .tag(3)
            
            // Question screens (with progress bar)
            OnboardingQuestionWrapper(currentStep: 1) {
                SleepQualityView(nextPage: nextPage)
            }
            .tag(4)
            
            OnboardingQuestionWrapper(currentStep: 2) {
                SleepPatternView(nextPage: nextPage)
            }
            .tag(5)
            
            OnboardingQuestionWrapper(currentStep: 3) {
                FallAsleepView(nextPage: nextPage)
            }
            .tag(6)
            
            OnboardingQuestionWrapper(currentStep: 4) {
                SleepScienceView(nextPage: nextPage)
            }
            .tag(7)
            
            OnboardingQuestionWrapper(currentStep: 5) {
                WakeUpView(nextPage: nextPage)
            }
            .tag(8)
            
            OnboardingQuestionWrapper(currentStep: 6) {
                RelaxationObstaclesView(nextPage: nextPage)
            }
            .tag(9)
            
            OnboardingQuestionWrapper(currentStep: 7) {
                SleepImpactView(nextPage: nextPage)
            }
            .tag(10)
            
            // Final Profile (no progress bar)
            FinalProfileView(nextPage: nextPage)
                .tag(11)
            
            // Paywall (no progress bar)
            PaywallView()
                .tag(12)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onLoad {
            try? audioManager.play(audioFileWithExtension: "calm-ambient.mp3")
        }
    }
    
    private func nextPage() {
        withAnimation {
            currentPage += 1
        }
    }
}
