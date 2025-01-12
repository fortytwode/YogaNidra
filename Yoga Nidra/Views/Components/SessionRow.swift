import SwiftUI

struct SessionRow: View {
    let session: YogaNidraSession
    @ObservedObject private var storeManager: StoreManager
    
    init(session: YogaNidraSession) {
        self.session = session
        self._storeManager = ObservedObject(wrappedValue: StoreManager.shared)
    }
    
    var shouldShowPremiumBadge: Bool {
        session.isPremium && !storeManager.isSubscribed
    }
    
    var body: some View {
        HStack {
            // Thumbnail
            AsyncImage(url: URL(string: session.thumbnailUrl)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                case .failure:
                    Image(systemName: "photo")
                        .frame(width: 60, height: 60)
                @unknown default:
                    EmptyView()
                }
            }
            
            VStack(alignment: .leading) {
                HStack {
                    Text(session.title)
                        .font(.headline)
                    
                    if shouldShowPremiumBadge {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                    }
                }
                
                Text("\(session.duration) minutes")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
} 