import SwiftUI

struct HomeView: View {
    @StateObject var router = Router<HomeTabDestination>()
    @EnvironmentObject var sheetPresenter: Presenter
    @EnvironmentObject var overlayManager: OverlayManager
    @EnvironmentObject var progressManager: ProgressManager
    @StateObject private var audioManager = AudioManager.shared
    let sessions = YogaNidraSession.allSessions
    @Binding var selectedTab: Int
    
    var freeSessions: [YogaNidraSession] {
        sessions.filter { !$0.isPremium }
    }
    
    var popularSessions: [YogaNidraSession] {
        // Get 2 random free sessions for popular section
        Array(freeSessions.shuffled().prefix(2))
    }
    
    var recommendedSessions: [YogaNidraSession] {
        // Get 4 sessions total, sorted alphabetically
        return Array(sessions.sorted { $0.title < $1.title }.prefix(4))
    }
    
    var body: some View {
        NavigationStack(path: $router.path) {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Banner
                    ZStack(alignment: .bottomLeading) {
                        Image("header")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 280)  // Increased from default height
                            .clipped()
                        
                        LinearGradient(
                            gradient: Gradient(colors: [.black.opacity(0.7), .clear]),
                            startPoint: .bottom,
                            endPoint: .top
                        )
                        .frame(height: 280)  // Match the image height
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Yoga Nidra")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.white)
                                .textShadowEffect()
                            
                            Text("Time to Unwind")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                                .textShadowEffect()
                            
                            Text("Let your mind drift into peaceful dreams")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .textShadowEffect()
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 24)
                    }
                    // Popular section
                    popularSection
                    // Recommended section
                    recommendedSection
                }
                .padding(.vertical)
            }
            .navigationTitle("Yoga Nidra")
            .environmentObject(router)
            .navigationDestination(for: HomeTabDestination.self) { destination in
                switch destination {
                case .none:
                    Text("No view for HomeTabDestination")
                }
            }
        }
    }
    
    var popularSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Popular")
                    .font(.title2)
                    .bold()
                Spacer()
                Button("See All") {
                    selectedTab = 1
                }
                .foregroundColor(.blue)
            }
            .padding(.horizontal, 24)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(sessions.prefix(2), id: \.id) { session in
                    Button {
                        Task {
                            await audioManager.play(session)
                            sheetPresenter.present(.sessionDetials(session))
                        }
                    } label: {
                        SessionCard(session: session)
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    var recommendedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recommended for You")
                    .font(.title2)
                    .bold()
                Spacer()
                Button("See All") {
                    selectedTab = 1
                }
                .foregroundColor(.blue)
            }
            .padding(.horizontal, 24)
            
            VStack(spacing: 12) {
                ForEach(recommendedSessions) { session in
                    Button {
                        Task {
                            await audioManager.play(session)
                            sheetPresenter.present(.sessionDetials(session))
                        }
                    } label: {
                        RecommendedSessionCard(session: session)
                    }
                }
            }
            .padding(.horizontal, 24)
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
            
            Button("See All") {
                selectedTab = 1
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white.opacity(0.3))
            .cornerRadius(12)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.top, 8)
        }
    }
}

// MARK: - Previews
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(selectedTab: .constant(0))
            .environmentObject(Presenter())
            .environmentObject(OverlayManager())
            .environmentObject(ProgressManager.shared)
    }
}
