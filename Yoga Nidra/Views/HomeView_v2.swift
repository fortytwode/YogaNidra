import SwiftUI

struct HomeView_v2: View {
    let sessions = YogaNidraSession.previewData
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with image background
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
                    
                    // Popular section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Popular")
                                .font(.title2)
                                .bold()
                            Spacer()
                            NavigationLink("See All") {
                                SessionListView_v2()
                            }
                            .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 24)
                        
                        // Grid with navigation
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            // First session
                            NavigationLink(destination: SessionDetailView(session: sessions[0])) {
                                VStack(alignment: .leading, spacing: 0) {
                                    Rectangle()
                                        .fill(Color(uiColor: UIColor(red: 0.3, green: 0.3, blue: 0.5, alpha: 1.0)))
                                        .frame(height: 160)
                                        .cornerRadius(8)
                                        .overlay(alignment: .bottomLeading) {
                                            Text("20 min")
                                                .font(.subheadline)
                                                .foregroundColor(.white)
                                                .padding(12)
                                        }
                                        .overlay(alignment: .bottomTrailing) {
                                            Image(systemName: "play.fill")
                                                .foregroundColor(.white)
                                                .padding(8)
                                                .background(Circle().fill(Color.white.opacity(0.2)))
                                                .padding(12)
                                        }
                                }
                            }
                            
                            // Second session
                            NavigationLink(destination: SessionDetailView(session: sessions[1])) {
                                VStack(alignment: .leading, spacing: 0) {
                                    Rectangle()
                                        .fill(Color(uiColor: UIColor(red: 0.3, green: 0.3, blue: 0.5, alpha: 1.0)))
                                        .frame(height: 160)
                                        .cornerRadius(8)
                                        .overlay(alignment: .bottomLeading) {
                                            Text("15 min")
                                                .font(.subheadline)
                                                .foregroundColor(.white)
                                                .padding(12)
                                        }
                                        .overlay(alignment: .bottomTrailing) {
                                            Image(systemName: "play.fill")
                                                .foregroundColor(.white)
                                                .padding(8)
                                                .background(Circle().fill(Color.white.opacity(0.2)))
                                                .padding(12)
                                        }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Second row: Text labels in HStack
                        HStack(alignment: .top) {
                            // First column text
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Evening Relaxation")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .lineLimit(2)
                                Text("Sarah Wilson")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Second column text
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Deep Sleep Meditation")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .lineLimit(2)
                                Text("Michael Chen")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    // Recommended section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recommended for You")
                            .font(.title2)
                            .bold()
                            .padding(.horizontal, 24)
                    }
                    
                    // Test content with more obvious markers
                    ForEach(1...5, id: \.self) { index in
                        Text("Test Item \(index)")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 100)  // Make items taller
                            .background(Color.blue)  // Visible background
                            .padding()
                            .onAppear {
                                print("Test Item \(index) appeared")
                            }
                    }
                }
                .padding(.vertical)
            }
            .simultaneousGesture(DragGesture().onChanged { value in
                print("Scroll detected: \(value.translation)")
            })
            .onAppear {
                print("ScrollView appeared")
            }
            .navigationTitle("Yoga Nidra")
            .background(Color(uiColor: UIColor(red: 0.06, green: 0.09, blue: 0.16, alpha: 1.0)))
        }
        .preferredColorScheme(.dark)
    }
}