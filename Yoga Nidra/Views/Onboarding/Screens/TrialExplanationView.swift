import SwiftUI

struct TrialExplanationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var storeManager: StoreManager
    @State private var currentPage = 0
    
    let trialEndDate: Date
    
    init() {
        self.trialEndDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    }
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
                .frame(height: 140)
            
            // Headline
            VStack(spacing: 40) {
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
                
                Text("How does your free trial work?")
                    .font(.title2)
                    .fontWeight(.medium)
                    .opacity(0.9)
            }
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
            
            Spacer()
                .frame(height: 8)
            
            // Timeline Items
            VStack(spacing: 40) {
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
            
            Spacer(minLength: 0)
            
            VStack(spacing: 0) {
                Button {
                    // Navigate to PaywallView
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
                
                Spacer()
                    .frame(height: 196)
            }
        }
        .background(
            ZStack {
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
        )
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
            TrialExplanationView()
                .environmentObject(StoreManager.preview)
            
            TrialExplanationView()
                .environmentObject(StoreManager.preview)
                .previewDevice("iPhone SE (3rd generation)")
        }
    }
}
#endif
