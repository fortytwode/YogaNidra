import SwiftUI
import StoreKit

class RatingManager: ObservableObject {
    static let shared = RatingManager()
    
    @Published var showRatingPrompt = false
    @AppStorage("hasShownRatingPrompt") private var hasShownRatingPrompt = false
    @AppStorage("hasRatedApp") private var hasRatedApp = false
    @AppStorage("ratingPromptConversion") private var ratingPromptConversion = 0.0
    @AppStorage("totalRatingPrompts") private var totalPrompts = 0
    @AppStorage("totalRatingConversions") private var totalConversions = 0
    
    private init() {}
    
    func checkAndShowRatingPrompt(sessionProgress: SessionProgress) {
        guard !hasShownRatingPrompt else { return }
        guard sessionProgress.completionCount == 1 else { return }
        
        showRatingPrompt = true
        hasShownRatingPrompt = true
        trackPromptShown()
    }
    
    func rateApp() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
            hasRatedApp = true
            trackRatingConversion()
        }
    }
    
    // Analytics tracking
    private func trackPromptShown() {
        totalPrompts += 1
    }
    
    private func trackRatingConversion() {
        totalConversions += 1
        ratingPromptConversion = Double(totalConversions) / Double(totalPrompts)
    }
    
    // MARK: - Development Testing
    #if DEBUG
    var debugStats: String {
        """
        Prompts Shown: \(totalPrompts)
        Conversions: \(totalConversions)
        Conversion Rate: \(String(format: "%.1f%%", ratingPromptConversion * 100))
        Has Rated: \(hasRatedApp)
        Has Shown Prompt: \(hasShownRatingPrompt)
        """
    }
    
    func showTestRatingPrompt() {
        showRatingPrompt = true
    }
    
    func resetRatingState() {
        hasShownRatingPrompt = false
        hasRatedApp = false
        totalPrompts = 0
        totalConversions = 0
        ratingPromptConversion = 0.0
    }
    #endif
}
