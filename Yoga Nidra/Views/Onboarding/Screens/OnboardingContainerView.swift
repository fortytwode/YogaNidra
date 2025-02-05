import SwiftUI

struct OnboardingContainerView: View {
    @State private var currentPageIndex = 0
    @StateObject private var storeManager = StoreManager.shared
    @StateObject private var onboardingManager = OnboardingManager.shared
    
    var body: some View {
        let nextPage = { currentPageIndex += 1 }
        
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                Group {
                    if currentPageIndex == 0 {
                        IWelcomeView(nextPage: nextPage)
                    } else if currentPageIndex == 1 {
                        GoalsView(nextPage: nextPage)
                    } else if currentPageIndex == 2 {
                        ExplanationView(nextPage: nextPage)
                    } else if currentPageIndex == 3 {
                        BenefitsView(nextPage: nextPage)
                    } else if currentPageIndex == 4 {
                        SleepSatisfactionView(nextPage: nextPage)
                    } else if currentPageIndex == 5 {
                        SleepQuantityView(nextPage: nextPage)
                    } else if currentPageIndex == 6 {
                        FallAsleepView(nextPage: nextPage)
                    } else if currentPageIndex == 7 {
                        TrialExplanationView(currentPage: $currentPageIndex)
                    } else if currentPageIndex == 8 {
                        PaywallView()
                    }
                }
            }
            .preferredColorScheme(.dark)
            .environmentObject(storeManager)
            .environmentObject(onboardingManager)
        }
    }
}

#Preview {
    OnboardingContainerView()
}