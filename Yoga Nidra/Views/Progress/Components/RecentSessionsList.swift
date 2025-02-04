import SwiftUI

struct RecentSessionsList: View {
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var sheetPresenter: Presenter
    @StateObject private var audioManager = AudioManager.shared
    
    var recentSessions: [(YogaNidraSession, SessionProgress)] {
        progressManager.sessionProgress
            .sorted { $0.value.lastCompleted ?? .distantPast > $1.value.lastCompleted ?? .distantPast }
            .prefix(5)
            .compactMap { progress in
                guard let session = YogaNidraSession.previewData.first(where: { $0.id == progress.key }) else {
                    return nil
                }
                return (session, progress.value)
            }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            if recentSessions.isEmpty {
                Text("Complete your first session to see your progress")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(recentSessions, id: \.0.id) { session, progress in
                    Button {
                        Task {
                            // Try to play immediately
                            do {
                                try await audioManager.onPlaySession(session: session)
                            } catch {
                                print("Failed to play session: \(error)")
                            }
                        }
                        // Also show the details sheet
                        sheetPresenter.present(.sessionDetials(session))
                    } label: {
                        RecentSessionRow(session: session, progress: progress)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

struct RecentSessionRow: View {
    let session: YogaNidraSession
    let progress: SessionProgress
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.title)
                    .font(.headline)
                
                if let lastCompleted = progress.lastCompleted {
                    Text(lastCompleted, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("\(progress.completionCount) times completed")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(formatDuration(progress.totalTimeListened))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(uiColor: .systemGray6))
        .cornerRadius(12)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
