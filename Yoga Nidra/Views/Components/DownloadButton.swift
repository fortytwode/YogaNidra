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
                Menu {
                    Button(role: .destructive) {
                        downloadManager.deleteSession(session)
                    } label: {
                        Label("Remove Download", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                        .background(Circle().fill(.white).shadow(radius: 2))
                }
            } else if downloadManager.isDownloading(session) {
                ProgressView()
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(.white).shadow(radius: 2))
            } else {
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
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.title2)
                        .foregroundColor(.accentColor)
                        .background(Circle().fill(.white).shadow(radius: 2))
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
