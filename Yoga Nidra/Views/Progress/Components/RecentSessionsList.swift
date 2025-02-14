import SwiftUI
import Foundation

// MARK: - Helper Types

struct RecentSessionItem: Identifiable {
    let session: YogaNidraSession
    let progress: SessionProgress
    
    var id: UUID { session.id }
}

// MARK: - Date Formatting

private extension Date {
    func timeAgoString() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

struct RecentSessionsList: View {
    @EnvironmentObject var progressManager: ProgressManager
    @EnvironmentObject var sheetPresenter: Presenter
    @StateObject private var audioManager = AudioManager.shared
    
    private var recentSessions: [RecentSessionItem] {
        progressManager.recentSessions.compactMap { session, progress in
            // Ensure session ID is valid
            guard session.id != UUID.init() else { return nil }
            return RecentSessionItem(session: session, progress: progress)
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            headerSection
            
            if recentSessions.isEmpty {
                emptyStateSection
            } else {
                recentSessionsSection
            }
        }
        .padding(.horizontal)
        .onAppear {
            // Removed loadRecentSessions() call
        }
        .alert("Playback Error", isPresented: .init(
            get: { audioManager.errorMessage != nil },
            set: { if !$0 { audioManager.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            if let error = audioManager.errorMessage {
                Text(error)
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        HStack {
            Text("Recent Sessions")
                .font(.title3)
                .fontWeight(.bold)
            Spacer()
        }
    }
    
    private var emptyStateSection: some View {
        Text("No recent sessions")
            .foregroundColor(.gray)
    }
    
    private var recentSessionsSection: some View {
        ForEach(recentSessions) { item in
            RecentSessionButton(session: item.session, progress: item.progress)
        }
    }
    
    // MARK: - Supporting Views

    struct RecentSessionButton: View {
        let session: YogaNidraSession
        let progress: SessionProgress
        @EnvironmentObject var sheetPresenter: Presenter
        @StateObject private var audioManager = AudioManager.shared
        
        var body: some View {
            Button {
                sheetPresenter.present(.sessionDetials(session))
            } label: {
                RecentSessionRow(session: session, progress: progress)
            }
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
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(session.instructor)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                    
                    if let lastCompleted = progress.lastCompleted {
                        Text("Last completed: \(lastCompleted.timeAgoString())")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
    }
}
