import SwiftUI

struct SessionListView_v2: View {
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
                    categoryFiltersSection
                    sessionGridSection
                }
                .padding(.vertical)
            }
            .navigationTitle("Library")
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

// MARK: - Supporting Views

struct SessionCardButton: View {
    let session: YogaNidraSession
    @EnvironmentObject var sheetPresenter: Presenter
    @EnvironmentObject private var audioManager: AudioManager
    
    var body: some View {
        Button {
            Task {
                audioManager.prepareSession(session)
                sheetPresenter.present(.sessionDetials(session))
                await audioManager.startPreparedSession()
            }
        } label: {
            SessionCard(session: session)
        }
        .frame(maxWidth: .infinity)
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
