import SwiftUI

struct OnboardingContainerView: View {
    @StateObject private var onboardingManager = OnboardingManager.shared
    @State private var currentPage = 0
    
    var body: some View {
        TabView(selection: $currentPage) {
            WelcomeView(nextPage: { currentPage += 1 })
                .tag(0)
            
            BenefitsView(nextPage: { currentPage += 1 })
                .tag(1)
            
            SleepQualityView(nextPage: { currentPage += 1 })
                .tag(2)
            
            FallAsleepView(nextPage: { currentPage += 1 })
                .tag(3)
            
            WakeUpView(nextPage: { currentPage += 1 })
                .tag(4)
            
            MorningTirednessView(nextPage: { currentPage += 1 })
                .tag(5)
            
            SleepImpactView(nextPage: { currentPage += 1 })
                .tag(6)
            
            FinalProfileView()
                .tag(7)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .ignoresSafeArea()
        .environmentObject(onboardingManager)
    }
}

#Preview {
    OnboardingContainerView()
        .preferredColorScheme(.dark)
} 