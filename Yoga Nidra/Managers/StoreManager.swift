import StoreKit
import SwiftUI
import Combine

@MainActor
final class StoreManager: ObservableObject {
    // MARK: - Singleton
    static let shared = StoreManager()
    
    #if DEBUG
    // Preview helper
    static var preview: StoreManager {
        let manager = StoreManager()
        manager.isSubscribed = false
        manager.subscriptionPrice = "$59.99"
        manager.formattedPrice = "$59.99/year"
        return manager
    }
    #endif
    
    // MARK: - Published Properties
    @Published private(set) var isSubscribed = false
    @Published private(set) var isInTrialPeriod = false
    @Published private(set) var trialEndDate: Date?
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage: String?
    @Published private(set) var subscriptionPrice: String = "$59.99"
    @Published private(set) var formattedPrice: String = ""
    
    // MARK: - Private Properties
    private var subscriptionProduct: Product?
    private let productID = "com.rocketship.YogaNidraSleepDeeply.premium.annual"
    private var transactionListener: Task<Void, Never>?
    private var updateListenerTask: Task<Void, Never>?
    private var isPurchaseInProgress = false
    private var isLoadingProducts = false
    private var hasLoadedProducts = false
    private var currentPurchaseTask: Task<Void, Error>?
    private var purchasedIdentifiers: Set<String> = []
    
    // MARK: Events
    private var onPuchaseCompleted = PassthroughSubject<TransactionReason, Never>()
    var onPurchaseCompletedPublisher: AnyPublisher<TransactionReason, Never> {
        onPuchaseCompleted.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    private init() {
        print("🚀 StoreManager: Initializing...")
        startTransactionListeners()
        
        // Initial product load
        Task {
            try? await loadProducts()
        }
    }
    
    deinit {
        transactionListener?.cancel()
        updateListenerTask?.cancel()
    }
    
    // MARK: - Transaction Listeners
    private func startTransactionListeners() {
        print("👂 StoreManager: Starting transaction listeners...")
        
        // Current entitlements listener
        transactionListener = Task.detached(priority: .background) {
            print("🎯 StoreManager: Starting current entitlements check...")
            do {
                for await result in StoreKit.Transaction.currentEntitlements {
                    try await self.handle(transactionResult: result, reason: .whileTransactionUpdate)
                }
            } catch {
                print("❌ StoreManager: Failed to handle transaction: \(error)")
            }
        }
        
        // Updates listener
        updateListenerTask = Task.detached(priority: .background) {
            print("🔄 StoreManager: Starting transaction updates listener...")
            do {
                for await update in StoreKit.Transaction.updates {
                    try await self.handle(transactionResult: update, reason: .whileTransactionUpdate)
                }
            } catch {
                print("❌ StoreManager: Failed to handle update: \(error)")
            }
        }
    }
    
    // MARK: - Product Loading
    func loadProducts() async throws {
        guard !isLoadingProducts else { return }
        
        isLoadingProducts = true
        defer { isLoadingProducts = false }
        
        print("🔍 StoreManager: Loading products...")
        
        do {
            let products = try await Product.products(for: [productID])
            guard let product = products.first else {
                print("❌ StoreManager: No products found")
                throw StoreError.notFound
            }
            
            print("✅ StoreManager: Products loaded successfully")
            self.subscriptionProduct = product
            self.subscriptionPrice = product.displayPrice
            hasLoadedProducts = true
            
        } catch {
            print("❌ StoreManager: Failed to load products: \(error.localizedDescription)")
            throw StoreError.failed(error)
        }
    }
    
    // MARK: - Purchase Flow
    func purchase() async throws {
        guard let product = subscriptionProduct else {
            throw StoreError.notFound
        }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                try await handleVerification(verification)
            case .userCancelled:
                throw StoreError.failed(nil)
            case .pending:
                throw StoreError.pending
            @unknown default:
                throw StoreError.unknown
            }
        } catch {
            throw StoreError.failed(error)
        }
    }
    
    @MainActor
    private func logPurchaseAnalytics(_ product: Product) {
        if product.type == .autoRenewable {
            FirebaseManager.shared.logSubscriptionStarted(productId: product.id)
        }
    }
    
    private func handleVerification(_ verification: StoreKit.VerificationResult<StoreKit.Transaction>) async throws {
        switch verification {
        case .verified(let transaction):
            await transaction.finish()
            try await refreshPurchasedIdentifiers()
            
            if transaction.productType == .autoRenewable {
                if let product = try? await Product.products(for: [transaction.productID]).first {
                    await logPurchaseAnalytics(product)
                }
            }
            
        case .unverified:
            throw StoreError.failed(nil)
        }
    }
    
    private func refreshPurchasedIdentifiers() async throws {
        do {
            for await result in StoreKit.Transaction.currentEntitlements {
                if case .verified(let transaction) = result {
                    if transaction.revocationDate == nil {
                        purchasedIdentifiers.insert(transaction.productID)
                    } else {
                        purchasedIdentifiers.remove(transaction.productID)
                    }
                }
            }
            await updateSubscriptionStatus()
        } catch {
            throw StoreError.failed(error)
        }
    }
    
    @MainActor
    private func updateSubscriptionStatus() {
        isSubscribed = !purchasedIdentifiers.isEmpty
    }
    
    // Restore Purchases
    func restore() async throws {
        do {
            try await AppStore.sync()
            try await refreshPurchasedIdentifiers()
        } catch {
            throw StoreError.failed(error)
        }
    }
    
    // Handle transaction verification
    private func handle(transactionResult verification: StoreKit.VerificationResult<StoreKit.Transaction>, reason: TransactionReason) async throws {
        switch verification {
        case .verified(let transaction):
            await transaction.finish()
            try await refreshPurchasedIdentifiers()
            
            if let product = try? await Product.products(for: [transaction.productID]).first,
               product.type == .autoRenewable {
                await logPurchaseAnalytics(product)
            }
            
            onPuchaseCompleted.send(reason)
            
        case .unverified:
            throw StoreError.failed(nil)
        }
    }
    
    // MARK: - Trial Period Detection
    private func checkTrialEligibility(_ transaction: StoreKit.Transaction) {
        // Check if the transaction indicates a trial period
        if transaction.isUpgraded {
            isInTrialPeriod = true
            trialEndDate = transaction.expirationDate
        }
    }
    
    private func updateFormattedPrice(_ product: Product) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        
        formattedPrice = product.displayPrice
        print("💲 StoreManager: Updated price to: \(formattedPrice)")
    }
}

// MARK: - Errors
enum StoreError: Error {
    case pending
    case failed(Error?)
    case notFound
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .pending:
            return "Purchase is pending"
        case .failed(let error):
            return error?.localizedDescription
        case .notFound:
            return "Product not found"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

enum TransactionReason {
    case whileTransactionUpdate
    case restored(whileOnboarding: Bool)
    case purchased(whileOnboarding: Bool)
}
