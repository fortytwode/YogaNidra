import SwiftUI
import StoreKit

struct RatingPromptView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var ratingManager: RatingManager
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 24) {
            // Header with icon
            VStack(spacing: 16) {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.purple)
                    .symbolEffect(.bounce)
                
                Text("How's Your Sleep Journey?")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                
                Text("Your feedback helps others discover the healing power of Yoga Nidra")
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
            
            // Buttons
            VStack(spacing: 12) {
                Button {
                    ratingManager.rateApp()
                    dismiss()
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
                    dismiss()
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
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(colorScheme == .dark ? Color(white: 0.1) : Color(white: 0.98))
                .edgesIgnoringSafeArea(.bottom)
        )
    }
}

// MARK: - Preview
#Preview("Rating Prompt - Light") {
    RatingPromptView()
        .environmentObject(RatingManager.shared)
        .preferredColorScheme(.light)
        .frame(height: 300)
        .background(Color.black.opacity(0.3))
}

#Preview("Rating Prompt - Dark") {
    RatingPromptView()
        .environmentObject(RatingManager.shared)
        .preferredColorScheme(.dark)
        .frame(height: 300)
        .background(Color.black.opacity(0.3))
}
