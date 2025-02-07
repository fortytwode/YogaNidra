import SwiftUI

struct TrialExplanationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var storeManager: StoreManager
    @Binding var currentPage: Int
    
    let trialEndDate: Date
    
    init(currentPage: Binding<Int>) {
        self._currentPage = currentPage
        self.trialEndDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    }
    
    var body: some View {
        ZStack {
            bodyContent
        }
        .background {
            Image("mountain-lake-twilight")
                .resizable()
                .scaledToFill()
                .overlay(Color.black.opacity(0.4))
                .edgesIgnoringSafeArea(.all)
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.3)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    var bodyContent: some View {
        VStack(spacing: 0) {
            // Headline
            VStack(spacing: 0) {
                Text("Your Dreamy Journey Begins ✨")
                    .font(.system(size: 38))
                    .fontWeight(.medium)
                    .padding(.top, 20)
                
                Text("Tonight's treats 🌟")
                    .font(.title2)
                    .fontWeight(.medium)
                    .opacity(0.9)
                    .padding(.top, 20)
            }
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
            
            // Timeline Items
            VStack(spacing: 10) {
                TimelineItem(
                    icon: "sparkles",
                    title: "Tonight's treats 🌟",
                    descriptions: [
                        "All dreamy stories unlocked & ready ✨",
                        "Your sleep sanctuary awaits 🛋️",
                        "Start your first peaceful night 🌙"
                    ]
                )
                
                TimelineItem(
                    icon: "moon.stars",
                    title: "3 sleeps later 💫",
                    descriptions: [
                        "Find your favorite bedtime stories 📖",
                        "Create your perfect wind-down ritual 🍵",
                        "Drift into deeper dreams 💭"
                    ]
                )
                
                TimelineItem(
                    icon: "sparkles.rectangle.stack",
                    title: "A week of dreams 🌌",
                    descriptions: [
                        "Keep snoozing soundly until \(trialEndDate.formatted(date: .abbreviated, time: .omitted)) 💝",
                        "Your peaceful journey continues ⭐",
                        "Easy to pause anytime before then ✨"
                    ]
                )
            }
            .padding(.vertical, 20)
            
            Spacer()
            VStack(spacing: 0) {
                Button {
                    withAnimation {
                        currentPage = 15 // Navigate to PaywallView
                    }
                } label: {
                    HStack {
                        Text("Let's get cozy")
                        Text("→")
                        Text("🌙")
                    }
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.white)
                    .cornerRadius(16)
                    .padding(.horizontal, 24)
                }
            }
        }
    }
}

struct TimelineItem: View {
    let icon: String
    let title: String
    let descriptions: [String]
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(descriptions, id: \.self) { description in
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(nil)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Preview Provider
#if DEBUG
struct TrialExplanationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardingQuestionWrapper(currentStep: 15) {
                TrialExplanationView(currentPage: .constant(0))
                    .environmentObject(StoreManager.preview)
            }
            
            OnboardingQuestionWrapper(currentStep: 15) {
                TrialExplanationView(currentPage: .constant(0))
                    .environmentObject(StoreManager.preview)
                    .previewDevice("iPhone SE (3rd generation)")
            }
        }
    }
}
#endif
