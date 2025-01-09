import SwiftUI

struct DownloadButton: View {
    let session: YogaNidraSession
    @StateObject private var downloadManager = DownloadManager.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showingPremiumSheet = false
    
    var body: some View {
        Group {
            if session.isDownloaded {
                // Downloaded state
                Button {
                    // Remove download with async Task
                    Task {
                        await downloadManager.removeDownload(session)
                    }
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            } else if let download = downloadManager.downloads[session.id.uuidString], 
                      download.isDownloading {
                // Downloading state
                ZStack {
                    Circle()
                        .stroke(lineWidth: 2)
                        .opacity(0.3)
                        .foregroundColor(.gray)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(download.progress))
                        .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                        .foregroundColor(.accentColor)
                        .rotationEffect(Angle(degrees: 270.0))
                    
                    Button {
                        Task {
                            await downloadManager.cancelDownload(session)
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 24, height: 24)
            } else {
                // Download button
                Button {
                    Task {
                        await downloadManager.downloadSession(session)
                    }
                } label: {
                    Image(systemName: "arrow.down.circle")
                        .foregroundColor(.accentColor)
                }
            }
        }
        .sheet(isPresented: $showingPremiumSheet) {
            PremiumContentSheet()
        }
    }
} 