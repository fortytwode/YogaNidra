import Foundation
import StoreKit

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published private(set) var subscription: Product?
    @Published private(set) var isSubscribed = false
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    private let productID = "com.rocketship.YogaNidraSleepDeeply.annual.premium"
    
    init() {
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }
    
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let products = try await Product.products(for: [productID])
            subscription = products.first
            print("✅ Loaded subscription product")
        } catch {
            errorMessage = "Failed to load subscription products"
            showError = true
            print("❌ Failed to load subscription:", error)
        }
    }
    
    func purchase() async {
        guard let product = subscription else {
            errorMessage = "Subscription product not available"
            showError = true
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                await updateSubscriptionStatus()
                print("✅ Subscription successful")
                // Optionally show success message
            case .pending:
                errorMessage = "Purchase is pending approval"
                showError = true
                print("⏳ Subscription pending")
            case .userCancelled:
                print("ℹ️ Purchase cancelled by user")
            @unknown default:
                errorMessage = "Unknown purchase result"
                showError = true
            }
        } catch {
            errorMessage = "Failed to complete purchase: \(error.localizedDescription)"
            showError = true
            print("❌ Purchase failed:", error)
        }
    }
    
    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
            print("✅ Purchases restored")
        } catch {
            errorMessage = "Failed to restore purchases"
            showError = true
            print("❌ Restore failed:", error)
        }
    }
    
    func updateSubscriptionStatus() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            
            if transaction.productID == productID {
                isSubscribed = true
                return
            }
        }
        isSubscribed = false
    }
    
    var subscriptionPrice: String {
        subscription?.displayPrice ?? "$59.99"
    }
    
    var trialText: String {
        "7-day free trial, then"
    }
} 