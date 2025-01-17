import SwiftUI

struct CategorySessionsView: View {
    let category: SessionCategory
    let sessions: [YogaNidraSession]
    @State private var sortOption: SortOption = .duration
    @State private var showInfo: Bool = false
    
    init(category: SessionCategory) {
        self.category = category
        self.sessions = YogaNidraSession.previewData.filter { $0.category == category }
    }
    
    var sortedSessions: [YogaNidraSession] {
        switch sortOption {
        case .duration:
            return sessions.sorted { (s1: YogaNidraSession, s2: YogaNidraSession) in 
                s1.duration < s2.duration 
            }
        case .title:
            return sessions.sorted { (s1: YogaNidraSession, s2: YogaNidraSession) in 
                s1.title < s2.title 
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Category Header
                CategoryHeaderView(category: category)
                    .padding()
                
                // Sort Controls
                HStack {
                    Text("Sort by:")
                        .foregroundColor(.secondary)
                    Picker("Sort by", selection: $sortOption) {
                        ForEach(SortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal)
                .padding(.bottom)
                
                // Sessions List
                LazyVStack(spacing: 12) {
                    ForEach(sortedSessions) { session in
                        SessionRowView(session: session)
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(category.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showInfo.toggle() }) {
                    Image(systemName: "info.circle")
                }
            }
        }
        .sheet(isPresented: $showInfo) {
            CategoryInfoView(category: category)
        }
    }
}

// MARK: - Supporting Views
struct CategoryHeaderView: View {
    let category: SessionCategory
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: category.icon)
                .font(.system(size: 44))
                .foregroundColor(category.color)
            
            Text(category.description)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Text("Duration: \(formatDurationRange(category.duration))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(category.color.opacity(0.1))
        .cornerRadius(16)
    }
    
    private func formatDurationRange(_ range: ClosedRange<TimeInterval>) -> String {
        let minMinutes = Int(range.lowerBound) / 60
        let maxMinutes = Int(range.upperBound) / 60
        return "\(minMinutes)-\(maxMinutes) minutes"
    }
}

struct SessionRowView: View {
    @EnvironmentObject var sheetPresenter: Presenter
    let session: YogaNidraSession
    
    var body: some View {
        Button {
            sheetPresenter.present(.sessionDetials(session))
        } label: {
            HStack(spacing: 16) {
                // Session Info
                VStack(alignment: .leading, spacing: 8) {
                    Text(session.title)
                        .font(.headline)
                    
                    Text(formatDuration(session.duration))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(session.instructor)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Premium indicator
                if session.isPremium {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                }
            }
            .padding()
            .background(Color(uiColor: .systemGray6))
            .cornerRadius(12)
        }
    }
    
    private func formatDuration(_ duration: Int) -> String {
        return "\(duration / 60) min"
    }
}

struct CategoryInfoView: View {
    let category: SessionCategory
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: category.icon)
                .font(.system(size: 60))
                .foregroundColor(category.color)
            
            Text(category.rawValue)
                .font(.title)
                .bold()
            
            Text(category.description)
                .multilineTextAlignment(.center)
                .padding()
            
            // Additional category-specific information could go here
            
            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") { dismiss() }
            }
        }
    }
}

// MARK: - Supporting Types
enum SortOption: String, CaseIterable, Identifiable {
    case duration = "Duration"
    case title = "Title"
    
    var id: String { rawValue }
}

#Preview {
    NavigationStack {
        CategorySessionsView(category: .deepSleep)
    }
} 
