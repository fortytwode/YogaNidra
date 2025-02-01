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
                RoundedRectangle(cornerRadius: 24)
                    .fill(colorScheme == .dark ? Color(white: 0.1) : Color(white: 0.98))
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
            
            Text("How's Your Sleep Journey?")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            
            MarqueeText(
                text: "Your feedback helps others discover the healing power of Yoga Nidra",
                font: UIFont.preferredFont(forTextStyle: .body),
                leftFade: 16,
                rightFade: 16,
                startDelay: 1
            )
            .font(.body)
            .multilineTextAlignment(.center)
            .foregroundColor(.secondary)
            
#if targetEnvironment(simulator)
            Text("Note: App Store rating only works on physical devices")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 8)
#endif
        }
        .padding(.top, 32)
        .padding(.horizontal)
    }
    
    var buttons: some View {
        VStack(spacing: 12) {
            Button {
                RatingManager.shared.rateApp()
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
                Text("Not Now")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(colorScheme == .dark ? Color(white: 0.2) : Color(white: 0.95))
                    .foregroundColor(.secondary)
                    .cornerRadius(12)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 24)
    }
}

#Preview("Rating Prompt - Light") {
    RatingPromptView()
        .environmentObject(RatingManager.shared)
        .preferredColorScheme(.light)
}

#Preview("Rating Prompt - Dark") {
    RatingPromptView()
        .environmentObject(RatingManager.shared)
        .preferredColorScheme(.dark)
}
