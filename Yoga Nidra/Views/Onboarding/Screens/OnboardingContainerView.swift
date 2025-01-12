import SwiftUI

struct OnboardingContainerView: View {
    @State private var currentPage = 0
    
    var body: some View {
        TabView(selection: $currentPage) {
            WelcomeView(nextPage: nextPage)
                .tag(0)
            
            BenefitsView(nextPage: nextPage)
                .tag(1)
            
            GoalsView(nextPage: nextPage)
                .tag(2)
            
            SleepQualityView(nextPage: nextPage)
                .tag(3)
            
            SleepPatternView(nextPage: nextPage)
                .tag(4)
            
            SleepScienceView(nextPage: nextPage)
                .tag(5)
            
            FallAsleepView(nextPage: nextPage)
                .tag(6)
            
            WakeUpView(nextPage: nextPage)
                .tag(7)
            
            MorningTirednessView(nextPage: nextPage)
                .tag(8)
            
            SleepFeelingsView(nextPage: nextPage)
                .tag(9)
            
            FinalProfileView()
                .tag(10)
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