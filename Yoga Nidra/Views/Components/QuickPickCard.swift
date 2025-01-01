import SwiftUI

struct QuickPickCard: View {
    let session: YogaNidraSession
    
    var body: some View {
        NavigationLink(destination: SessionDetailView(session: session)) {
            VStack(alignment: .leading, spacing: 8) {
                Text(session.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(session.category.rawValue)
                    .font(.subheadline)
                    .foregroundColor(session.category.color)
                
                Text(formatDuration(session.duration))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(width: 160)
            .background(Color(uiColor: .systemGray6))
            .cornerRadius(12)
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes) min"
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