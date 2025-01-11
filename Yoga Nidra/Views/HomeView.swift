import SwiftUI

struct HomeView: View {
    let sessions = YogaNidraSession.previewData
    @Binding var selectedTab: Int
    
    var recommendedSessions: [YogaNidraSession] {
        var recommendations: [YogaNidraSession] = []
        var usedCategories: Set<SessionCategory> = []
        
        for session in sessions.shuffled() {
            if !usedCategories.contains(session.category) {
                recommendations.append(session)
                usedCategories.insert(session.category)
                
                if recommendations.count == 4 {
                    break
                }
            }
        }
        return recommendations
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with image background
                    headerAndBacgkround
                    // Popular section
                    popularSection
                    // Recommended section
                    recomenndedSeciont
                }
                .padding(.vertical)
            }
            .navigationTitle("Yoga Nidra")
            .background(Color(uiColor: UIColor(red: 0.06, green: 0.09, blue: 0.16, alpha: 1.0)))
        }
        .preferredColorScheme(.dark)
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
                    NavigationLink(destination: SessionDetailView(session: session)) {
                        SessionCard(session: session)
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    var headerAndBacgkround: some View {
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
    
    var recomenndedSeciont: some View {
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
                    NavigationLink(destination: SessionDetailView(session: session)) {
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
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.top, 8)
        }
    }
}
