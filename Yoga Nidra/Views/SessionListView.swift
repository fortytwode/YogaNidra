import SwiftUI

struct SessionListView: View {
    let sessions = YogaNidraSession.previewData
    
    var body: some View {
        NavigationStack {
            List(sessions) { session in
                NavigationLink(destination: SessionDetailView(session: session)) {
                    VStack(alignment: .leading) {
                        Text(session.title)
                            .font(.headline)
                        Text(session.category.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(formatDuration(session.duration))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Yoga Nidra")
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes) minutes"
    }
} 