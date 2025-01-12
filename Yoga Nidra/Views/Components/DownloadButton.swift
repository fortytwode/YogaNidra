import SwiftUI

struct DownloadButton: View {
    let session: YogaNidraSession
    @ObservedObject private var downloadManager: DownloadManager
    @ObservedObject private var storeManager: StoreManager
    @State private var showingPremiumSheet = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    init(session: YogaNidraSession) {
        self.session = session
        self._downloadManager = ObservedObject(wrappedValue: DownloadManager.shared)
        self._storeManager = ObservedObject(wrappedValue: StoreManager.shared)
    }
    
    var body: some View {
        Group {
            if session.isDownloaded {
                // Downloaded state
                Button {
                    Task {
                        do {
                            try await downloadManager.removeDownload(session)
                        } catch {
                            errorMessage = error.localizedDescription
                            showError = true
                        }
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
                    Circle()
                        .trim(from: 0, to: CGFloat(download.progress))
                        .stroke(lineWidth: 2)
                        .rotationEffect(.degrees(-90))
                    Button {
                        downloadManager.cancelDownload(session)
                    } label: {
                        Image(systemName: "xmark")
                            .font(.caption)
                    }
                }
                .frame(width: 24, height: 24)
            } else {
                // Download button
                Button {
                    Task {
                        if storeManager.isSubscribed {
                            do {
                                try await downloadManager.downloadSession(session)
                            } catch {
                                errorMessage = error.localizedDescription
                                showError = true
                            }
                        } else {
                            showingPremiumSheet = true
                        }
                    }
                } label: {
                    Image(systemName: "arrow.down.circle")
                        .foregroundColor(.accentColor)
                }
            }
        }
        .sheet(isPresented: $showingPremiumSheet) {
            SubscriptionView()
        }
        .alert("Download Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
} 