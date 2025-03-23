
import SwiftUI
import Kingfisher

struct SessionThumbnailImage: View {
    
    let session: YogaNidraSession
    
    var body: some View {
        if session.thumbnailUrl.contains("http"),
           let url = URL(string: session.thumbnailUrl) {
            KFImage.url(url)
                .resizable()
        } else {
            Image(session.thumbnailUrl)
                .resizable()
        }
    }
}

#Preview {
    SessionThumbnailImage(session: .previewData.first!)
}
