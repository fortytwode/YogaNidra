import Network
import SwiftUI

class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkManager")
    @Published var isOnline = true
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isOnline = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
}

// Add offline banner view
struct OfflineBanner: View {
    @StateObject private var networkManager = NetworkManager.shared
    
    var body: some View {
        if !networkManager.isOnline {
            VStack {
                HStack {
                    Image(systemName: "wifi.slash")
                    Text("You're offline")
                    Spacer()
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .foregroundColor(.gray)
            }
        }
    }
} 