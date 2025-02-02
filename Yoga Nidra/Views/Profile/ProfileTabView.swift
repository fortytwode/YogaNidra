import SwiftUI

@available(iOS 15.0, *)
struct ProfileTabView: View {
    @EnvironmentObject private var storeManager: StoreManager
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    // Subscription Status
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                        Text(storeManager.isSubscribed ? "Premium Member" : "Free Member")
                            .font(.headline)
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    // Links
                    Button {
                        openURL(URL(string: "http://rocketshiphq.com/yoga-nidra-terms")!)
                    } label: {
                        HStack {
                            Image(systemName: "doc.text")
                            Text("Terms of Service")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Button {
                        openURL(URL(string: "http://rocketshiphq.com/yoga-nidra-privacy")!)
                    } label: {
                        HStack {
                            Image(systemName: "hand.raised")
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section("App Settings") {
                    NavigationLink {
                        NotificationSettingsView()
                    } label: {
                        Label("Notifications", systemImage: "bell")
                    }
                }
                
                if !storeManager.isSubscribed {
                    Section {
                        NavigationLink {
                            SubscriptionView()
                        } label: {
                            Label("Upgrade to Premium", systemImage: "crown")
                        }
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

// MARK: - Preview Provider
#if DEBUG
struct ProfileTabView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileTabView()
            .environmentObject(StoreManager.preview)
    }
}
#endif
