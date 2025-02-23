import SwiftUI
import StoreKit

struct RatingPromptView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var overlayManager: OverlayManager
    
    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                header
                buttons
            }
            .background {
                Image("rating-background")
                    .resizable()
                    .opacity(colorScheme == .dark ? 0.2: 0.2)
                    .clipped()
            }
            .background(colorScheme == .dark ? Color(white: 0.1) : .gray.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .background {
                RoundedRectangle(cornerRadius: 24)
                    .shadow(color: colorScheme == .dark ? .white.opacity(0.3) : .black, radius: 8, x: 4, y: 4)
            }
            .padding(.horizontal)
        }
    }
    
    var header: some View {
        VStack(spacing: 16) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 48))
                .foregroundColor(.purple)
                .modify {
                    if #available(iOS 18.0, *) {
                        $0.symbolEffect(.bounce)
                    }
                }
            
            Text("Did that feel good?")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            
            VStack(spacing: 8) {
                Text("Take a moment to rate us.")
                Text("Every rating helps us give the gift of\nbetter sleep to more people.")
            }
            .font(.body)
            .multilineTextAlignment(.center)
            .foregroundColor(.primary.opacity(0.8))
            .lineSpacing(4)
            
#if targetEnvironment(simulator)
            Text("Note: App Store rating only works on physical devices")
                .font(.caption)
                .foregroundColor(.primary)
#endif
        }
        .padding(.top, 32)
        .padding(.horizontal)
    }
    
    var buttons: some View {
        VStack(spacing: 12) {
            Button {
                showRatingPrompt()
                overlayManager.hideOverlay()
            } label: {
                Text("Rate on App Store")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            
            Button {
                overlayManager.hideOverlay()
            } label: {
                Text("Maybe Later")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 32)
    }
    
    private func showRatingPrompt() {
        guard let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return }
        SKStoreReviewController.requestReview(in: scene)
    }
}

#Preview("Rating Prompt - Light") {
    RatingPromptView()
        .preferredColorScheme(.light)
}

#Preview("Rating Prompt - Dark") {
    RatingPromptView()
        .preferredColorScheme(.dark)
}
