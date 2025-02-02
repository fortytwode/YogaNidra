import SwiftUI

struct RecommendedSessionCard: View {
    let session: YogaNidraSession
    
    var formattedDuration: String {
        let minutes = Int(session.duration / 60)
        return "\(minutes) mins"
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Thumbnail
            Image(session.thumbnailUrl)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Session info
            VStack(alignment: .leading, spacing: 4) {
                Text(session.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text(session.instructor)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                
                Text(formattedDuration)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
            }
            .multilineTextAlignment(.leading)
            
            Spacer()
            
            // Play button
            Image(systemName: "play.circle.fill")
                .font(.system(size: 32))
                .foregroundColor(.white)
        }
        .padding(16)
        .background(Color.black.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
