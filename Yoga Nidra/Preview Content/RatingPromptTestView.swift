import SwiftUI

struct RatingPromptTestView: View {
    @StateObject private var ratingManager = RatingManager.shared
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Rating Prompt Testing")
                .font(.title2.bold())
            
            // Test Actions
            VStack(spacing: 16) {
                Button("Show Rating Prompt") {
                    ratingManager.showTestRatingPrompt()
                }
                .buttonStyle(.borderedProminent)
                .tint(.purple)
                
                Button("Reset Rating State") {
                    ratingManager.resetRatingState()
                }
                .buttonStyle(.bordered)
            }
            .padding(.vertical)
            
            // Debug Stats
            VStack(alignment: .leading, spacing: 8) {
                Text("Debug Statistics")
                    .font(.headline)
                    .padding(.bottom, 4)
                
                Text(ratingManager.debugStats)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(colorScheme == .dark ? Color(white: 0.15) : Color(white: 0.95))
            )
            
            #if targetEnvironment(simulator)
            Text("⚠️ Note: The App Store rating UI will only appear on physical devices")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            #endif
            
            Spacer()
        }
        .padding()
        .navigationTitle("Test Rating")
        .sheet(isPresented: $ratingManager.showRatingPrompt) {
            RatingPromptView()
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview("Rating Test - Light") {
    NavigationView {
        RatingPromptTestView()
    }
    .preferredColorScheme(.light)
}

#Preview("Rating Test - Dark") {
    NavigationView {
        RatingPromptTestView()
    }
    .preferredColorScheme(.dark)
}
