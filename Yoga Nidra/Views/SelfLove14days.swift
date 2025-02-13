import SwiftUI

struct SelfLove14days: View {
    @State var sessions = YogaNidraSession.specialEventSessions
    @StateObject var router = Router<LibraryTabDestination>()
    @EnvironmentObject var sheetPresenter: Presenter
    @EnvironmentObject private var audioManager: AudioManager
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack(path: $router.path) {
            ScrollView {
                VStack(spacing: 24) {
                    sessionGridSection
                }
                .padding(.vertical)
            }
            .navigationTitle("14 Days Self Love")
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
            AppState.shared.isValentinteTabShown = true
        }
    }
    
    private var sessionGridSection: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)
        
        return LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
            ForEach(sessions) { session in
                SessionCard(session: session)
                    .onTapGesture {
                        sheetPresenter.present(.sessionDetials(session))
                    }
            }
        }
        .padding(.horizontal, 16)
    }
}
