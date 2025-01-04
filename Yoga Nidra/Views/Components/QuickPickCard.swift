import SwiftUI

struct QuickPickCard: View {
    let session: YogaNidraSession
    
    var body: some View {
        VStack(alignment: .leading) {
            // Debug: Print the image name we're trying to load
            let _ = print("Loading image: \(session.thumbnailUrl)")
            
            Image(session.thumbnailUrl)
                .resizable()
                .scaledToFill()
                .frame(height: 160)
                .clipped()
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(session.title)
                    .font(.headline)
                Text(session.category.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
        }
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}

struct RecentlyPlayedList: View {
    let sessions: [YogaNidraSession]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(sessions) { session in
                NavigationLink(destination: SessionDetailView(session: session)) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(session.title)
                                .font(.headline)
                            Text(session.category.rawValue)
                                .font(.subheadline)
                                .foregroundColor(session.category.color)
                        }
                        
                        Spacer()
                        
                        Text(formatDuration(session.duration))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(uiColor: .systemGray6))
                    .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes) min"
    }
} 