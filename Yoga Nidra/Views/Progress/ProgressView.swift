import SwiftUI

struct ProgressView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Stats Section
                    StatsView()
                        .padding(.top)
                    
                    // Recent Sessions List
                    RecentSessionsList()
                    
                    // Favorites Section
                    FavoritesView()
                }
                .padding(.horizontal)
            }
            .navigationTitle("Progress")
            .background(Color.black)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ProgressView()
        .environmentObject(Presenter())
        .environmentObject(ProgressManager.preview)
}
