import SwiftUI

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
                
                if !storeManager.isSubscribed {
                    Section {
                        Button {
                            // Navigate to PaywallView
                        } label: {
                            HStack {
                                Spacer()
                                Text("Upgrade to Premium")
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                        }
                        .tint(.blue)
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileTabView()
        .environmentObject(StoreManager.shared)
}
