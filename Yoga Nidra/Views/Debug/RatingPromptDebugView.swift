import SwiftUI

struct RatingPromptDebugView: View {
    @EnvironmentObject var overlayManager: OverlayManager
    @AppStorage("lastRatingPromptDate") private var lastRatingPromptDate: Double = 0
    @AppStorage("ratingPromptsShown") private var ratingPromptsShown: Int = 0
    @AppStorage("ratingYearStartDate") private var ratingYearStartDate: Double = Date().timeIntervalSince1970
    @AppStorage("ratingPromptsInYear") private var ratingPromptsInYear: Int = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Form {
                    Section("Rating Prompt Controls") {
                        Button("Show Rating Prompt") {
                            overlayManager.showOverlay(RatingPromptView())
                        }
                        
                        Button("Reset Rating State") {
                            lastRatingPromptDate = 0
                            ratingPromptsShown = 0
                            ratingYearStartDate = Date().timeIntervalSince1970
                            ratingPromptsInYear = 0
                        }
                    }
                    
                    Section("Current State") {
                        if lastRatingPromptDate > 0 {
                            LabeledContent("Last Shown", value: Date(timeIntervalSince1970: lastRatingPromptDate).formatted())
                        } else {
                            Text("Never shown")
                        }
                        
                        LabeledContent("Times Shown", value: "\(ratingPromptsShown)")
                        LabeledContent("Times Shown This Year", value: "\(ratingPromptsInYear)")
                        
                        if ratingYearStartDate > 0 {
                            LabeledContent("Year Start Date", value: Date(timeIntervalSince1970: ratingYearStartDate).formatted())
                        }
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("Background Test")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    RatingPromptView()
                        .frame(height: 400)
                }
                .padding(.top)
            }
        }
        .navigationTitle("Rating Debug")
    }
}

// MARK: - Preview Provider
struct RatingPromptDebugView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RatingPromptDebugView()
                .environmentObject(OverlayManager())
        }
    }
}
