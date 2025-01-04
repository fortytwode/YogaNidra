import SwiftUI

struct SessionListView_v2: View {
    let sessions = YogaNidraSession.previewData
    @State private var selectedCategory: SessionCategory? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Category filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            CategoryFilterButton(title: "All", isSelected: selectedCategory == nil) {
                                selectedCategory = nil
                            }
                            
                            ForEach(SessionCategory.allCases.filter { $0 != .all }, id: \.self) { category in
                                CategoryFilterButton(
                                    title: category.rawValue,
                                    isSelected: selectedCategory == category
                                ) {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Grid layout with more items for scrolling test
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(0..<12) { index in // Increased to 12 items
                            NavigationLink(destination: SessionDetailView(session: sessions[index % sessions.count])) {
                                VStack(alignment: .leading, spacing: 0) {
                                    Rectangle()
                                        .fill(Color(uiColor: UIColor(red: 0.3, green: 0.3, blue: 0.5, alpha: 1.0)))
                                        .frame(height: 160)
                                        .cornerRadius(8)
                                        .overlay(alignment: .bottomLeading) {
                                            Text("\((index + 1) * 5) min")
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
                            .onAppear {
                                print("Item \(index) appeared")
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Library")
            .background(Color.black)
            .onAppear {
                print("ScrollView appeared")
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct CategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.white : Color.clear)
                .foregroundColor(isSelected ? .black : .white)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white, lineWidth: 1)
                )
        }
    }
} 