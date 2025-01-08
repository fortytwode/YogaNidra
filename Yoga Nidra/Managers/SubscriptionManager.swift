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
    
    private let productID = "yearly.premium.audio.sub"
    
    init() {
        listenForTransactions()
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
            case .success:
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

extension SubscriptionManager {
    
    typealias SKTransaction = StoreKit.Transaction
    
    @discardableResult
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            ///Iterate through any transactions that don't come from a direct call to `purchase()`.
            for await result in SKTransaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    
                    ///Deliver products to the user.
                    await self.updateSubscriptionStatus()
                    
                    ///Always finish a transaction.
                    await transaction.finish()
                } catch {
                    ///StoreKit has a transaction that fails verification. Don't deliver content to the user.
                    print("Transaction failed verification")
                }
            }
        }
    }

    public func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        ///Check whether the JWS passes StoreKit verification.
        switch result {
            ///StoreKit parses the JWS, but it fails verification.
        case .unverified:
            throw SKError(SKError.clientInvalid)
            ///The result is verified. Return the unwrapped value.
        case .verified(let safe):
            return safe
        }
    }
}
