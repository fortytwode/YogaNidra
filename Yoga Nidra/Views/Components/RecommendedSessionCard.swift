import SwiftUI

struct RecommendedSessionCard: View {
    let session: YogaNidraSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Recommended for you")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                if session.isPremium {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                }
            }
            
            // Session Info
            HStack(spacing: 16) {
                // Thumbnail
                AsyncImage(url: URL(string: session.thumbnailUrl)) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 80, height: 80)
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(session.title)
                        .font(.headline)
                    
                    Text("\(Int(session.duration / 60)) minutes")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    // Tags
                    ScrollView(.horizontal, showsIndicators: false) {
                        Text(session.category.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(0.1))
                            .foregroundColor(.accentColor)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color(uiColor: .systemGray6))
        .cornerRadius(16)
    }
} 
