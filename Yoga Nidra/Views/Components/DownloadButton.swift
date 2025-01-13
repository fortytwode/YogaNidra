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
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
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
