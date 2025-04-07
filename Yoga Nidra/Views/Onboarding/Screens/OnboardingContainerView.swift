import SwiftUI

struct OnboardingContainerView: View {
    @State private var currentPageIndex = 0
    @State private var previousPageIndex = 0
    @StateObject private var storeManager = StoreManager.shared
    @StateObject private var onboardingManager = OnboardingManager.shared
    
    var body: some View {
        let nextPage = { currentPageIndex += 1 }
        
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                Group {
                    switch currentPageIndex {
                    case 0:
                        IWelcomeView(nextPage: nextPage)
                    case 1:
                        OnboardingQuestionWrapper(currentStep: 1) {
                            GoalsView(nextPage: nextPage)
                        }
                    case 2:
                        OnboardingQuestionWrapper(currentStep: 2) {
                            ExplanationView(nextPage: nextPage)
                        }
                    case 3:
                        OnboardingQuestionWrapper(currentStep: 3) {
                            BenefitsView(nextPage: nextPage)
                        }
                    case 4:
                        OnboardingQuestionWrapper(currentStep: 4) {
                            SleepSatisfactionView(nextPage: nextPage)
                        }
                    case 5:
                        OnboardingQuestionWrapper(currentStep: 5) {
                            SleepQuantityView(nextPage: nextPage)
                        }
                    case 6:
                        OnboardingQuestionWrapper(currentStep: 6) {
                            FallAsleepView(nextPage: nextPage)
                        }
                    case 7:
                        OnboardingQuestionWrapper(currentStep: 7) {
                            SleepReminderView(nextPage: nextPage)
                        }
                    case 8:
                        OnboardingQuestionWrapper(currentStep: 8) {
                            SleepScienceView(nextPage: nextPage)
                        }
                    case 9:
                        OnboardingQuestionWrapper(currentStep: 9) {
                            WakeupView(nextPage: nextPage)
                        }
                    case 10:
                        OnboardingQuestionWrapper(currentStep: 10) {
                            RelaxationObstaclesView(nextPage: nextPage)
                        }
                    case 11:
                        OnboardingQuestionWrapper(currentStep: 11) {
                            SleepImpactView(nextPage: nextPage)
                        }
                    case 12:
                        OnboardingQuestionWrapper(currentStep: 12) {
                            AfterPoorSleepView(nextPage: nextPage)
                        }
                    case 13:
                        ProcessingDataView(nextPage: nextPage)
                    case 14:
                        FinalProfileView(nextPage: nextPage)
                    case 15:
                        TrialExplanationView(currentPage: $currentPageIndex)
                    case 16:
                        PaywallView()
                    default:
                        EmptyView()
                    }
                }
            }
            .preferredColorScheme(.dark)
            .environmentObject(storeManager)
            .environmentObject(onboardingManager)
            .onChange(of: currentPageIndex) { newPage in
                // Update the OnboardingManager with the current page
                onboardingManager.currentOnboardingPage = newPage
                print("📱 Onboarding: Navigated to page \(newPage)")
            }
            .onAppear {
                // Set initial page in OnboardingManager
                onboardingManager.currentOnboardingPage = currentPageIndex
            }
        }
    }
}

#Preview {
    OnboardingContainerView()
        .environmentObject(ScreenSizeProvider())
}
