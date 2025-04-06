import SwiftUI

struct OnboardingContainerView: View {
    @State private var currentPageIndex = 0
    @State private var previousPageIndex = 0
    @StateObject private var storeManager = StoreManager.shared
    @StateObject private var onboardingManager = OnboardingManager.shared
    @EnvironmentObject var sizeProvider: ScreenSizeProvider
    
    var body: some View {
        let nextPage = { currentPageIndex += 1 }
        
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                Group {
                    switch currentPageIndex {
                    case 0:
                        IWelcomeView(nextPage: nextPage)
                            .environmentObject(sizeProvider)
                    case 1:
                        OnboardingQuestionWrapper(currentStep: 1) {
                            GoalsView(nextPage: nextPage)
                                .environmentObject(sizeProvider)
                        }
                        .environmentObject(sizeProvider)
                    case 2:
                        OnboardingQuestionWrapper(currentStep: 2) {
                            ExplanationView(nextPage: nextPage)
                                .environmentObject(sizeProvider)
                        }
                        .environmentObject(sizeProvider)
                    case 3:
                        OnboardingQuestionWrapper(currentStep: 3) {
                            BenefitsView(nextPage: nextPage)
                                .environmentObject(sizeProvider)
                        }
                        .environmentObject(sizeProvider)
                    case 4:
                        OnboardingQuestionWrapper(currentStep: 4) {
                            SleepSatisfactionView(nextPage: nextPage)
                                .environmentObject(sizeProvider)
                        }
                        .environmentObject(sizeProvider)
                    case 5:
                        OnboardingQuestionWrapper(currentStep: 5) {
                            SleepQuantityView(nextPage: nextPage)
                                .environmentObject(sizeProvider)
                        }
                        .environmentObject(sizeProvider)
                    case 6:
                        OnboardingQuestionWrapper(currentStep: 6) {
                            FallAsleepView(nextPage: nextPage)
                                .environmentObject(sizeProvider)
                        }
                        .environmentObject(sizeProvider)
                    case 7:
                        OnboardingQuestionWrapper(currentStep: 7) {
                            SleepReminderView(nextPage: nextPage)
                                .environmentObject(sizeProvider)
                        }
                        .environmentObject(sizeProvider)
                    case 8:
                        OnboardingQuestionWrapper(currentStep: 8) {
                            SleepScienceView(nextPage: nextPage)
                                .environmentObject(sizeProvider)
                        }
                        .environmentObject(sizeProvider)
                    case 9:
                        OnboardingQuestionWrapper(currentStep: 9) {
                            WakeupView(nextPage: nextPage)
                                .environmentObject(sizeProvider)
                        }
                        .environmentObject(sizeProvider)
                    case 10:
                        OnboardingQuestionWrapper(currentStep: 10) {
                            RelaxationObstaclesView(nextPage: nextPage)
                                .environmentObject(sizeProvider)
                        }
                        .environmentObject(sizeProvider)
                    case 11:
                        OnboardingQuestionWrapper(currentStep: 11) {
                            SleepImpactView(nextPage: nextPage)
                                .environmentObject(sizeProvider)
                        }
                        .environmentObject(sizeProvider)
                    case 12:
                        OnboardingQuestionWrapper(currentStep: 12) {
                            AfterPoorSleepView(nextPage: nextPage)
                                .environmentObject(sizeProvider)
                        }
                        .environmentObject(sizeProvider)
                    case 13:
                        ProcessingDataView(nextPage: nextPage)
                            .environmentObject(sizeProvider)
                    case 14:
                        FinalProfileView(nextPage: nextPage)
                            .environmentObject(sizeProvider)
                    case 15:
                        TrialExplanationView(currentPage: $currentPageIndex)
                            .environmentObject(sizeProvider)
                    case 16:
                        PaywallView()
                            .environmentObject(sizeProvider)
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
        .environmentObject(ScreenSizeProvider()) // Add for preview
}
