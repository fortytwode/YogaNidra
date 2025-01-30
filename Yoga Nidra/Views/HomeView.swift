import SwiftUI

struct HomeView: View {
    @StateObject var router = Router<HomeTabDestination>()
    @EnvironmentObject var sheetPresenter: Presenter
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
                    // Header with image background
                    headerAndBackground
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
                        // Try to play immediately
                        do {
                            try audioManager.onPlaySession(session: session)
                        } catch {
                            print("Failed to play session: \(error)")
                        }
                        // Also show the details sheet
                        sheetPresenter.present(.sessionDetials(session))
                    } label: {
                        SessionCard(session: session)
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    var headerAndBackground: some View {
        ZStack {
            Image("header")
                .resizable()
                .scaledToFill()
                .frame(height: 192)
                .clipped()
            
            VStack {
                Spacer()
                VStack(alignment: .leading, spacing: 8) {
                    Text("Time to Unwind")
                        .font(.system(size: 32, weight: .bold))
                    Text("Let your mind drift into peaceful dreams")
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 0.6, green: 0.6, blue: 1.0))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
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
                        // Try to play immediately
                        do {
                            try audioManager.onPlaySession(session: session)
                        } catch {
                            print("Failed to play session: \(error)")
                        }
                        // Also show the details sheet
                        sheetPresenter.present(.sessionDetials(session))
                    } label: {
                        RecommendedSessionCard(session: session)
                    }
                }
            }
            .padding(.horizontal, 24)
            
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
