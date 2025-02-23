import SwiftUI
import Foundation

// MARK: - Helper Types

struct RecentSessionItem: Identifiable {
    let session: YogaNidraSession
    let lastCompleted: Date
    
    var id: String { session.id }
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
    
    var body: some View {
        VStack(spacing: 12) {
            headerSection
            
            if progressManager.recentSessions.isEmpty {
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
        ForEach(progressManager.recentSessions) { session in
            Button {
                sheetPresenter.present(.sessionDetials(session.session))
            } label: {
                SessionCard(session: session.session)
            }
        }
    }
}
