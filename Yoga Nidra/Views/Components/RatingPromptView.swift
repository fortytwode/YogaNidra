import SwiftUI
import StoreKit

struct RatingPromptView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var overlayManager: OverlayManager
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.3).ignoresSafeArea()
            VStack(spacing: 24) {
                header
                buttons
            }
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(colorScheme == .dark ? Color(white: 0.1) : Color(white: 0.98))
                    
                    if let _ = UIImage(named: "rating-background") {
                        Image("rating-background")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .opacity(0.1)
                            .clipped()
                    }
                }
                .edgesIgnoringSafeArea(.bottom)
            )
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
                .foregroundColor(.secondary)
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
                    .foregroundColor(.secondary)
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

// MARK: - Previews
struct RatingPromptView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Light mode preview
            RatingPromptView()
                .environmentObject(OverlayManager())
                .preferredColorScheme(.light)
                .previewDisplayName("Rating Prompt - Light")
                .background(Color.white)
            
            // Dark mode preview
            RatingPromptView()
                .environmentObject(OverlayManager())
                .preferredColorScheme(.dark)
                .previewDisplayName("Rating Prompt - Dark")
                .background(Color.black)
            
            // Preview in context
            ZStack {
                TabView {
                    Color.black.opacity(0.9)
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }
                }
                
                RatingPromptView()
                    .environmentObject(OverlayManager())
            }
            .previewDisplayName("Rating Prompt - In Context")
        }
    }
}
