import SwiftUI

struct ProgressTabView: View {
    @StateObject var router = Router<ProgressTabDestination>()
    @EnvironmentObject var audioManager: AudioManager
    @AppStorage(StroageKeys.streakCountKey) var currentStreak = 0
    @AppStorage(StroageKeys.totalSessionsCompletedKey) var sessionsCompleted = 0
    @AppStorage(StroageKeys.totalSessionListenTimeKey) var totalTimeListened = 0.0
    
    var body: some View {
        NavigationStack(path: $router.path) {
            VStack {
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 10) {
                            majorStats
                            minorStats
                        }
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.3))
                        }
                        .padding()
                        
                        FavoritesView()
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            if sessionsCompleted == 0 {
                                Text("Complete your first session to see your progress")
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 32)
                            } else {
                                RecentSessionsList()
                            }
                        }
                        
                        Spacer(minLength: 0)
                    }
                    .padding(.vertical)
                }
                .contentMargins(.bottom, audioManager.currentPlayingSession != nil ? 52 : 0, for: .scrollContent)
            }
            .navigationTitle("Progress")
            .navigationDestination(for: ProgressTabDestination.self) { _ in
                EmptyView()
            }
        }
    }
    
    var majorStats: some View {
        VStack {
            HStack(spacing: 12) {
                Image(systemName: "beats.headphones")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.blue)
                Text("Total Sessions")
                    .font(.system(size: 30))
                    .fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            Text(String(sessionsCompleted))
                .bold()
                .font(.largeTitle)
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))
        }
    }
    
    var minorStats: some View {
        HStack {
            Spacer()
            StatView(
                title: "Sleepy Minutes",
                state: String(format: "%.1f", totalTimeListened / 60),
                icon: "clock"
            )
            Spacer()
            StatView(
                title: "Streaks",
                state: String(currentStreak),
                icon: "checkmark.arrow.trianglehead.counterclockwise"
            )
            Spacer()
        }
    }
}

struct StatView: View {
    
    let title: String
    let state: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            Text(title)
                .font(.headline)
            Text(String(state))
                .font(.system(size: 20))
        }
    }
}

// MARK: - Preview Provider
struct ProgressTabView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressTabView()
            .environmentObject(Presenter())
            .environmentObject(ProgressManager.shared)
            .environmentObject(AudioManager.shared)
            .preferredColorScheme(.dark)
    }
}
