import SwiftUI

#if DEBUG
@available(iOS 15.0, *)
struct RatingDebugView: View {
    @StateObject private var progressManager = ProgressManager.shared
    @StateObject private var overlayManager = OverlayManager.shared
    @State private var sessionTime: Double = 0
    @State private var sessionsCompleted: Int = 0
    @State private var lastPromptDate: Date = Date()
    
    var body: some View {
        Form {
            Section("Current Values") {
                LabeledContent("Total Session Time", value: "\(Int(progressManager.totalSessionListenTime)) seconds")
                LabeledContent("Sessions Completed", value: "\(progressManager.sessionsCompleted)")
                LabeledContent("Rating Prompts This Year", value: "\(progressManager.ratingPromptsInYear)/3")
                LabeledContent("Current Cooldown", value: {
                    switch progressManager.ratingPromptsInYear {
                        case 0: return "2 weeks"
                        case 1: return "30 days"
                        case 2: return "1 year"
                        default: return "No more prompts this year"
                    }
                }())
                if let yearStart = progressManager.ratingYearStartDate {
                    LabeledContent("Year Started", value: yearStart.formatted())
                }
                if let lastDate = progressManager.lastRatingDialogDate {
                    LabeledContent("Last Prompt Date", value: lastDate.formatted())
                }
            }
            
            Section("Modify Session Time") {
                Stepper("Session Time: \(Int(sessionTime)) minutes", value: $sessionTime, in: 0...60)
                Button("Set Session Time") {
                    progressManager.setTotalSessionListenTime(sessionTime * 60)
                }
            }
            
            Section("Modify Sessions Completed") {
                Stepper("Sessions: \(sessionsCompleted)", value: $sessionsCompleted, in: 0...10)
                Button("Set Sessions Completed") {
                    progressManager.sessionsCompleted = sessionsCompleted
                }
            }
            
            Section("Last Prompt Date") {
                DatePicker("Last Prompt Date", selection: $lastPromptDate, displayedComponents: [.date])
                Button("Set Last Prompt Date") {
                    progressManager.setLastRatingDialogDate(lastPromptDate)
                }
            }
            
            Section("Quick Actions") {
                Button("Force Show Rating Prompt") {
                    overlayManager.showOverlay(RatingPromptView())
                }
                
                Button("Reset All Rating State", role: .destructive) {
                    progressManager.resetRatingState()
                }
            }
        }
        .navigationTitle("Rating Debug")
        .onAppear {
            sessionTime = progressManager.totalSessionListenTime / 60
            sessionsCompleted = progressManager.sessionsCompleted
            if let lastDate = progressManager.lastRatingDialogDate {
                lastPromptDate = lastDate
            }
        }
    }
}
#endif
