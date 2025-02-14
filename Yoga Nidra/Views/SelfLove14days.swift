import SwiftUI

struct SelfLove14days: View {
    @State var sessions = YogaNidraSession.specialEventSessions
    @StateObject var router = Router<LibraryTabDestination>()
    @EnvironmentObject var sheetPresenter: Presenter
    @EnvironmentObject private var audioManager: AudioManager
    @State private var searchText = ""
    @State private var selectedSession: YogaNidraSession?
    @State private var showHeartAnimation = false
    
    private var daysUntilValentines: Int {
        let calendar = Calendar.current
        let valentinesDay = calendar.date(from: DateComponents(year: 2025, month: 2, day: 14))!
        let days = calendar.dateComponents([.day], from: Date(), to: valentinesDay).day ?? 0
        return max(0, days)
    }
    
    var body: some View {
        NavigationStack(path: $router.path) {
            ZStack {
                // Background hearts
                FloatingHeartsView()
                    .allowsHitTesting(false)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Valentine's themed header
                        VStack(spacing: 8) {
                            Text("✨ Your journey to self-love ✨")
                                .font(.headline)
                                .foregroundColor(.pink)
                                .overlay(
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.pink.opacity(0.2))
                                        .scaleEffect(1.5)
                                        .blur(radius: 2)
                                )
                            if daysUntilValentines > 0 {
                                Text("\(daysUntilValentines) days until Valentine's Day 💝")
                                    .font(.caption)
                                    .foregroundColor(.pink.opacity(0.6))
                            }
                        }
                        .padding(.top)
                        
                        sessionGridSection
                    }
                    .padding(.vertical)
                }
                .contentMargins(.bottom, audioManager.currentPlayingSession != nil ? 52 : 0, for: .scrollContent)
            }
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
            .background(Color.black)
            .environmentObject(router)
            .navigationDestination(for: LibraryTabDestination.self) { destination in
                switch destination {
                case .none:
                    Text("No view for LibraryTabDestination")
                }
            }
        }
        .preferredColorScheme(.dark)
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
        .onAppear {
            AppState.shared.shouldShowValentrineDayTab = true
        }
    }
    
    private var sessionGridSection: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)
        
        return LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
            ForEach(sessions) { session in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showHeartAnimation = true
                        selectedSession = session
                    }
                    
                    // Reset animation and show session after brief delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showHeartAnimation = false
                        sheetPresenter.present(.sessionDetials(session))
                    }
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
                        
                        if showHeartAnimation && selectedSession?.id == session.id {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.pink)
                                .opacity(showHeartAnimation ? 0 : 1)
                                .scaleEffect(showHeartAnimation ? 2 : 1)
                                .animation(.easeOut(duration: 0.5), value: showHeartAnimation)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }
}
