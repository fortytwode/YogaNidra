import SwiftUI

struct HomeView: View {
    let sessions = YogaNidraSession.previewData
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Time-based recommendations
                    TimeBasedRecommendationsView(sessions: sessions)
                    
                    // Categories
                    VStack(alignment: .leading) {
                        Text("Sleep Solutions")
                            .font(.title2)
                            .bold()
                            .padding(.horizontal)
                        
                        CategoryGrid()
                    }
                    
                    // Quick Picks
                    VStack(alignment: .leading) {
                        Text("Quick Picks")
                            .font(.title2)
                            .bold()
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(sessions.prefix(3)) { session in
                                    QuickPickCard(session: session)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Recently Played (if any)
                    if let lastPlayed = sessions.filter({ $0.lastPlayed != nil }).sorted(by: { ($0.lastPlayed ?? .distantPast) > ($1.lastPlayed ?? .distantPast) }).first {
                        VStack(alignment: .leading) {
                            Text("Continue Your Practice")
                                .font(.title2)
                                .bold()
                                .padding(.horizontal)
                            
                            NavigationLink(destination: SessionDetailView(session: lastPlayed)) {
                                LastPlayedCard(session: lastPlayed)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Yoga Nidra")
        }
    }
}

// Supporting view for last played session
struct LastPlayedCard: View {
    let session: YogaNidraSession
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Last Session")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(session.title)
                    .font(.headline)
                
                if let lastPlayed = session.lastPlayed {
                    Text(lastPlayed, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "play.circle.fill")
                .font(.title)
                .foregroundColor(session.category.color)
        }
        .padding()
        .background(Color(uiColor: .systemGray6))
        .cornerRadius(12)
    }
}

// Supporting Views
struct FeaturedSessionCard: View {
    let session: YogaNidraSession
    
    var body: some View {
        NavigationLink(destination: SessionDetailView(session: session)) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Featured Session")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(session.title)
                    .font(.title2)
                    .bold()
                
                Text(session.description)
                    .lineLimit(2)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .systemGray6))
            .cornerRadius(12)
        }
    }
}

struct CategoryGrid: View {
    let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(SessionCategory.allCases) { category in
                CategoryCard(category: category)
            }
        }
        .padding(.horizontal)
    }
}

struct CategoryCard: View {
    let category: SessionCategory
    
    var body: some View {
        NavigationLink(destination: CategorySessionsView(category: category)) {
            HStack {
                Image(systemName: category.icon)
                    .font(.title2)
                Text(category.rawValue)
                    .bold()
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(category.color.opacity(0.1))
            .foregroundColor(category.color)
            .cornerRadius(12)
        }
    }
} 