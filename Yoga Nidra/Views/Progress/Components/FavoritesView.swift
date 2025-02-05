import SwiftUI

struct FavoritesView: View {
    @StateObject private var favoritesManager = FavoritesManager.shared
    @EnvironmentObject private var sheetPresenter: Presenter
    @StateObject private var audioManager = AudioManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerSection
            
            if favoritesManager.favoriteSessions.isEmpty {
                emptyStateSection
            } else {
                favoriteSessionsList
            }
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
            Text("Your Favorites")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Spacer()
            
            if !favoritesManager.favoriteSessions.isEmpty {
                NavigationLink(destination: AllFavoritesView()) {
                    Text("See All")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
        }
    }
    
    private var emptyStateSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart")
                .font(.system(size: 32))
                .foregroundColor(.gray)
            Text("No favorites yet")
                .font(.headline)
                .foregroundColor(.gray)
            Text("Add meditations to your favorites\nfor quick access")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var favoriteSessionsList: some View {
        VStack(spacing: 12) {
            ForEach(favoritesManager.favoriteSessions) { session in
                FavoriteSessionRow(session: session)
            }
        }
    }
}

// MARK: - Supporting Views

struct FavoriteSessionRow: View {
    let session: YogaNidraSession
    @EnvironmentObject private var sheetPresenter: Presenter
    @StateObject private var audioManager = AudioManager.shared
    
    var body: some View {
        Button {
            Task {
                await audioManager.play(session)
                sheetPresenter.present(.sessionDetials(session))
            }
        } label: {
            HStack(spacing: 16) {
                // Thumbnail
                Image(session.thumbnailUrl)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Session Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(session.instructor)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                    
                    Text("\(Int(session.duration / 60)) mins")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                // Play Button
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
    }
}

struct AllFavoritesView: View {
    @StateObject private var favoritesManager = FavoritesManager.shared
    @EnvironmentObject private var sheetPresenter: Presenter
    @StateObject private var audioManager = AudioManager.shared
    
    var body: some View {
        ScrollView {
            let columns = [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ]
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(favoritesManager.favoriteSessions) { session in
                    SessionCardButton(session: session)
                }
            }
            .padding(16)
        }
        .navigationTitle("All Favorites")
        .background(Color.black)
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
}

#Preview {
    NavigationView {
        FavoritesView()
            .preferredColorScheme(.dark)
            .environmentObject(Presenter())
    }
}
