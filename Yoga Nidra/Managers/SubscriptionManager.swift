import Foundation
import StoreKit

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published var isSubscribed = false
    @Published var isInTrialPeriod = false
    @Published var trialEndDate: Date?
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage: String?
    
    // Add computed properties for subscription text
    var trialText: String {
        "Start 7 days free trial"
    }
    
    var subscriptionPrice: String {
        "$59.99"  // Or fetch from StoreKit product
    }
    
    private var subscriptionProduct: Product?
    private let productID = "com.rocketship.YogaNidraSleepDeeply.premium.annual"
    
    init() {
        print("🛍️ SubscriptionManager initializing...")
    }
    
    func setupProducts() async {
        print("🔍 Debug: Starting product setup")
        print("🔍 Debug: Bundle ID: \(Bundle.main.bundleIdentifier ?? "unknown")")
        print("🔍 Debug: Looking for product ID: \(productID)")
        
        do {
            print("🔍 Debug: Requesting products...")
            let products = try await Product.products(for: [productID])
            
            print("🔍 Debug: Request completed")
            print("🔍 Debug: Products count: \(products.count)")
            
            if let product = products.first {
                print("✅ Debug: Found product: \(product.id)")
                print("✅ Debug: Product price: \(product.price)")
                print("✅ Debug: Product description: \(product.description)")
                self.subscriptionProduct = product
            } else {
                print("❌ Debug: No products found")
                print("❌ Debug: Verify product ID in App Store Connect")
            }
        } catch {
            print("❌ Debug: Error loading products: \(error)")
            print("❌ Debug: Full error: \(String(describing: error))")
        }
    }
    
    func purchase() async {
        print("💰 Starting purchase flow")
        
        // Try to load products if we don't have them
        if subscriptionProduct == nil {
            print("💰 No product loaded, fetching products...")
            await setupProducts()
        }
        
        guard let product = subscriptionProduct else {
            print("❌ Product still not available after setup")
            errorMessage = "Unable to load subscription details. Please try again."
            showError = true
            return
        }
        
        print("💰 Starting purchase for product: \(product.id)")
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                print("✅ Purchase success, verifying...")
                let transaction = try await checkVerified(verification)
                await updateSubscriptionStatus(transaction)
                await transaction.finish()
                print("✅ Purchase completed and verified")
                
            case .userCancelled:
                print("ℹ️ User cancelled purchase")
                
            case .pending:
                print("⏳ Purchase pending")
                errorMessage = "Purchase is pending approval"
                showError = true
                
            @unknown default:
                print("❌ Unknown purchase result")
                errorMessage = "Purchase failed with unknown status"
                showError = true
            }
            
        } catch {
            print("❌ Purchase error: \(error)")
            print("❌ Error type: \(type(of: error))")
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            showError = true
        }
    }
    
    func checkSubscriptionStatus() async {
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try await checkVerified(result)
                
                await MainActor.run {
                    if let expirationDate = transaction.expirationDate {
                        // Check if this is a trial by looking at the transaction date
                        let isInTrial = transaction.purchaseDate.distance(to: expirationDate) <= 7*24*60*60 // 7 days in seconds
                        isInTrialPeriod = isInTrial && expirationDate > Date()
                        trialEndDate = isInTrial ? expirationDate : nil
                        
                        // Update subscription status
                        isSubscribed = transaction.revocationDate == nil &&
                                     expirationDate > .now
                    }
                }
            } catch {
                print("Failed to verify transaction: \(error)")
            }
        }
    }
    
    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await AppStore.sync()
            await checkSubscriptionStatus()
        } catch {
            errorMessage = "Failed to restore purchases"
            showError = true
        }
    }
    
    private func updateSubscriptionStatus(_ transaction: Transaction) {
        if let expirationDate = transaction.expirationDate {
            // Check if this is a trial by looking at the transaction date
            let isInTrial = transaction.purchaseDate.distance(to: expirationDate) <= 7*24*60*60 // 7 days in seconds
            isInTrialPeriod = isInTrial && expirationDate > Date()
            trialEndDate = isInTrial ? expirationDate : nil
            
            // Update subscription status
            isSubscribed = transaction.revocationDate == nil &&
                         expirationDate > .now
        }
        
        objectWillChange.send()
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) async throws -> T {
        switch result {
        case .unverified:
            throw SubscriptionError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }
    
    func checkIsSubscribed() async -> Bool {
        await MainActor.run {
            return isSubscribed
        }
    }
    
    // Add verification method
    func verifySetup() {
        print("🔍 Debug: Subscription Manager Status:")
        print("- Product ID configured: \(productID)")
        print("- Has subscription product: \(subscriptionProduct != nil)")
        print("- Is subscribed: \(isSubscribed)")
        print("- Is in trial: \(isInTrialPeriod)")
    }
}

enum SubscriptionError: LocalizedError {
    case productNotFound
    case verificationFailed
    
    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Subscription product not found"
        case .verificationFailed:
            return "Failed to verify purchase"
        }
    }
}
