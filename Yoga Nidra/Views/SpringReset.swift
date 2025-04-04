import SwiftUI

struct SpringReset: View {
    @State var sessions = YogaNidraSession.springResetSessions
    @EnvironmentObject var sheetPresenter: Presenter
    @EnvironmentObject private var audioManager: AudioManager
    @State private var selectedSession: YogaNidraSession?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Valentine's themed header
                VStack(spacing: 8) {
                    Text("🌺 Spring Reset 🌺")
                        .font(.headline)
                        .foregroundColor(.springOrange)
                        .padding()
                }
                sessionGridSection
            }
        }
        .contentMargins(.bottom, audioManager.currentPlayingSession != nil ? 52 : 0, for: .scrollContent)
        .navigationTitle("Spring Reset")
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(
            LinearGradient(
                gradient: Gradient(colors: [.pink.opacity(0.1), .springOrange.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            for: .navigationBar
        )
        .overlay {
            FloatingLeavesView()
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
                                    gradient: Gradient(colors: [.springGreen.opacity(0.1), .clear]),
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
