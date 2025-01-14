import SwiftUI

struct OnboardingContainerView: View {
    @State private var currentPage = 0
    
    var body: some View {
        TabView(selection: $currentPage) {
            WelcomeView(nextPage: nextPage)
                .tag(0)
            
            BenefitsView(nextPage: nextPage)
                .tag(1)
            
            ExplanationView(nextPage: nextPage)
                .tag(2)
            
            GoalsView(nextPage: nextPage)
                .tag(3)
            
            SleepQualityView(nextPage: nextPage)
                .tag(4)
            
            SleepPatternView(nextPage: nextPage)
                .tag(5)
            
            SleepScienceView(nextPage: nextPage)
                .tag(6)
            
            FallAsleepView(nextPage: nextPage)
                .tag(7)
            
            WakeUpView(nextPage: nextPage)
                .tag(8)
            
            MorningTirednessView(nextPage: nextPage)
                .tag(9)
            
            SleepFeelingsView(nextPage: nextPage)
                .tag(10)
            
            FinalProfileView()
                .tag(11)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
    
    private func nextPage() {
        withAnimation {
            currentPage += 1
        }
    }
}