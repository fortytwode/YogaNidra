import SwiftUI

struct SessionListView_v2: View {
    let sessions = YogaNidraSession.allSessions
    @State private var selectedCategory: SessionCategory? = nil
    @StateObject var router = Router<LibraryTabDestination>()
    @EnvironmentObject var sheetPresenter: Presenter
    @StateObject private var audioManager = AudioManager.shared
    
    var filteredSessions: [YogaNidraSession] {
        guard let category = selectedCategory else {
            return sessions // Return all sessions when no category is selected
        }
        return sessions.filter { $0.category.id == category.id }
    }
    
    var body: some View {
        NavigationStack(path: $router.path) {
            ScrollView {
                VStack(spacing: 24) {
                    // Category filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            CategoryFilterButton(title: "All", isSelected: selectedCategory == nil) {
                                selectedCategory = nil
                            }
                            
                            ForEach(CategoryManager.shared.categories) { category in
                                CategoryFilterButton(
                                    title: category.id,
                                    isSelected: selectedCategory?.id == category.id
                                ) {
                                    selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // Grid layout with filtered sessions
                    let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)
                    
                    LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
                        ForEach(filteredSessions) { session in
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
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical)
            }
            .navigationTitle("Library")
            .background(Color.black)
            .onAppear {
                print("ScrollView appeared")
            }
            .environmentObject(router)
            .navigationDestination(for: LibraryTabDestination.self) { destination in
                switch destination {
                case .none:
                    Text("No view for LibraryTabDestination")
                }
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
