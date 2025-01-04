import SwiftUI

struct SessionDetailView: View {
    let session: YogaNidraSession
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Session info
                Text(session.title)
                    .font(.title)
                    .bold()
                
                Text(session.description)
                    .foregroundColor(.secondary)
                
                // Audio player
                AudioPlayerView(session: session)
                
                // ... rest of your session detail view
            }
            .padding()
        }
    }
} 