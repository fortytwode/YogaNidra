import SwiftUI

struct ProgressView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Recent Sessions List
                    RecentSessionsList()
                        .padding(.top)
                    
                    // Favorites Section
                    FavoritesView()
                    
                    // Stats or other sections can be added here
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
}
