import SwiftUI

struct FavoritesView: View {
    @StateObject private var favoritesManager = FavoritesManager.shared
    @EnvironmentObject private var sheetPresenter: Presenter
    @StateObject private var audioManager = AudioManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
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
            
            if favoritesManager.favoriteSessions.isEmpty {
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
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(favoritesManager.favoriteSessions) { session in
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
                                VStack(alignment: .leading, spacing: 8) {
                                    ZStack(alignment: .bottomLeading) {
                                        Image(session.thumbnailUrl)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 160, height: 160)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                        
                                        LinearGradient(
                                            gradient: Gradient(colors: [.clear, .black.opacity(0.6)]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        
                                        HStack {
                                            Text("\(Int(session.duration / 60)) min")
                                                .font(.caption)
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                        }
                                        .padding(8)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(session.title)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .lineLimit(2)
                                        
                                        Text(session.instructor)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                            .lineLimit(1)
                                    }
                                }
                                .frame(width: 160)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct AllFavoritesView: View {
    @StateObject private var favoritesManager = FavoritesManager.shared
    @EnvironmentObject private var sheetPresenter: Presenter
    @StateObject private var audioManager = AudioManager.shared
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(favoritesManager.favoriteSessions) { session in
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
            .padding()
        }
        .navigationTitle("Favorites")
        .background(Color.black)
    }
}

#Preview {
    NavigationView {
        FavoritesView()
            .preferredColorScheme(.dark)
            .environmentObject(Presenter())
    }
}
