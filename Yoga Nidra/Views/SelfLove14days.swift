import SwiftUI

struct SelfLove14days: View {
    @State var sessions = YogaNidraSession.specialEventSessions
    @EnvironmentObject var sheetPresenter: Presenter
    @EnvironmentObject private var audioManager: AudioManager
    @State private var selectedSession: YogaNidraSession?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Valentine's themed header
                VStack(spacing: 8) {
                    Text("✨ Your journey to self-love ✨")
                        .font(.headline)
                        .foregroundColor(.pink)
                        .padding()
                        .overlay(
                            Image(systemName: "heart.fill")
                                .foregroundColor(.pink.opacity(0.2))
                                .scaleEffect(1.5)
                                .blur(radius: 2)
                        )
                }
                sessionGridSection
            }
        }
        .contentMargins(.bottom, audioManager.currentPlayingSession != nil ? 52 : 0, for: .scrollContent)
        .navigationTitle("14 Days of Self-Love")
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(
            LinearGradient(
                gradient: Gradient(colors: [.pink.opacity(0.1), .purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            for: .navigationBar
        )
        .overlay {
            FloatingHeartsView()
                .allowsHitTesting(false)
        }
    }
    
    private var sessionGridSection: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)
        
        return LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
            ForEach(sessions) { session in
                Button {
                    selectedSession = session
                    sheetPresenter.present(.sessionDetials(session))
                } label: {
                    ZStack {
                        SessionCard(session: session)
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [.pink.opacity(0.1), .clear]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }
}
