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
                VStack(spacing: 0) {
                    Text("Begin your journey")
                        .font(.system(size: 38))
                        .fontWeight(.medium)
                    Text("to rejuvenating")
                        .font(.system(size: 38))
                        .fontWeight(.medium)
                    Text("sleep")
                        .font(.system(size: 38))
                        .fontWeight(.medium)
                }
                .padding(.top, 20)
                
                Text("How does your free trial work?")
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
                    title: "Today",
                    descriptions: [
                        "Full access to all sleep sessions & features.",
                        "Unlock all premium meditations.",
                        "Sleep restfully. Tonight."
                    ]
                )
                
                TimelineItem(
                    icon: "moon.stars",
                    title: "In 3 days",
                    descriptions: [
                        "Keep exploring your favorite sessions.",
                        "Continue your relaxation practice.",
                        "Deepen your sleep experience."
                    ]
                )
                
                TimelineItem(
                    icon: "checkmark.circle",
                    title: "In 7 days",
                    descriptions: [
                        "You wont be charged before \(trialEndDate.formatted(date: .abbreviated, time: .omitted)).",
                        "Continue your journey from here.",
                        "Cancel anytime before this."
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
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(.white)
                        .cornerRadius(28)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
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
