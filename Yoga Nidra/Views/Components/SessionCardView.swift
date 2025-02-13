import SwiftUI

struct SessionCardView: View {
    let session: YogaNidraSession
    
    var body: some View {
        VStack(alignment: .leading) {
            // Thumbnail with overlays
            Image(session.thumbnailUrl)
                .resizable()
                .scaledToFill()
                .frame(height: 160)
                .clipped()
                .cornerRadius(12)
                .overlay(alignment: .bottomLeading) {
                    HStack {
                        Text("\(Int(session.duration / 60)) min")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        if session.isPremium {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                    .padding(12)
                }
            
            HStack {
                Text(session.title)
                    .font(.headline)
                if session.isPremium {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.yellow)
                }
            }
            
            Text(session.instructor)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}