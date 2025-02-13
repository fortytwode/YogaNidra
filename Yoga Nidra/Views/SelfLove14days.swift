import SwiftUI

struct SelfLove14days: View {
    let sessions = YogaNidraSession.allSessions
    @State private var selectedCategory: SessionCategory? = nil
    @StateObject var router = Router<LibraryTabDestination>()
    @EnvironmentObject var sheetPresenter: Presenter
    @EnvironmentObject private var audioManager: AudioManager
    @State private var searchText = ""
    
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
                    sessionGridSection
                }
                .padding(.vertical)
            }
            .navigationTitle("14 Days Self Love")
            .background(Color.black)
            .environmentObject(router)
            .navigationDestination(for: LibraryTabDestination.self) { destination in
                switch destination {
                case .none:
                    Text("No view for LibraryTabDestination")
                }
            }
        }
        .preferredColorScheme(.dark)
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
    
    private var categoryFiltersSection: some View {
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
    }
    
    private var sessionGridSection: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)
        
        return LazyVGrid(columns: columns, alignment: .center, spacing: 16) {
            ForEach(filteredSessions) { session in
                SessionCardButton(session: session)
            }
        }
        .padding(.horizontal, 16)
    }
}
