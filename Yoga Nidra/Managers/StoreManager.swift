import StoreKit
import Combine
import RevenueCat

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
    
    // RevenueCat integration
    private let revenueCatManager = RevenueCatManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Events
    private var onPuchaseCompleted = PassthroughSubject<TransactionReason, Never>()
    var onPurchaseCompletedPublisher: AnyPublisher<TransactionReason, Never> {
        onPuchaseCompleted.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    private init() {
        print("🚀 StoreManager: Initializing...")
        startTransactionListeners()
        
        // Subscribe to RevenueCat updates
        revenueCatManager.$isSubscribed
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                self?.isSubscribed = value
            }
            .store(in: &cancellables)
        
        revenueCatManager.$isInTrialPeriod
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                self?.isInTrialPeriod = value
            }
            .store(in: &cancellables)
        
        revenueCatManager.$trialEndDate
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                self?.trialEndDate = value
            }
            .store(in: &cancellables)
        
        // Initial product load
        Task {
            try? await loadProducts()
        }
    }
    
    deinit {
        transactionListener?.cancel()
        updateListenerTask?.cancel()
        cancellables.forEach { $0.cancel() }
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
        
        // Load products from RevenueCat
        await revenueCatManager.loadOfferings()
        
        // Also load from StoreKit for backward compatibility
        do {
            let products = try await Product.products(for: [productID])
            if let product = products.first {
                subscriptionProduct = product
                subscriptionPrice = product.displayPrice
                
                // Format price for display
                if product.subscription?.subscriptionPeriod.unit == .year {
                    formattedPrice = "\(product.displayPrice)/year"
                } else {
                    formattedPrice = product.displayPrice
                }
                
                hasLoadedProducts = true
                print("✅ StoreManager: Successfully loaded products")
            } else {
                print("⚠️ StoreManager: No products found")
            }
        } catch {
            print("❌ StoreManager: Failed to load products: \(error)")
            throw error
        }
    }
    
    // MARK: - Purchase
    func purchase() async throws {
        guard !isPurchaseInProgress else {
            throw StoreError.pending
        }
        
        isLoading = true
        isPurchaseInProgress = true
        
        defer {
            isLoading = false
            isPurchaseInProgress = false
        }
        
        do {
            // Use RevenueCat for purchase
            try await revenueCatManager.purchase()
            
            // Notify listeners
            onPuchaseCompleted.send(.purchased(whileOnboarding: false))
            
            print("✅ StoreManager: Purchase completed successfully")
        } catch {
            print("❌ StoreManager: Purchase failed: \(error)")
            throw error
        }
    }
    
    // MARK: - Restore Purchases
    func restore() async throws {
        isLoading = true
        
        do {
            // Use RevenueCat for restore
            try await revenueCatManager.restorePurchases()
            
            // Notify listeners
            onPuchaseCompleted.send(.restored(whileOnboarding: false))
            
            print("✅ StoreManager: Restore completed successfully")
            isLoading = false
        } catch {
            print("❌ StoreManager: Restore failed: \(error)")
            isLoading = false
            throw error
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
    
    // Handle transaction verification
    private func handle(transactionResult verification: StoreKit.VerificationResult<StoreKit.Transaction>, reason: TransactionReason) async throws {
        switch verification {
        case .verified(let transaction):
            await transaction.finish()
            try await refreshPurchasedIdentifiers()
            
            if let product = try? await Product.products(for: [transaction.productID]).first,
               product.type == .autoRenewable {
                logPurchaseAnalytics(product, transaction: transaction)
            }
            
            onPuchaseCompleted.send(reason)
            
        case .unverified:
            throw StoreError.failed(nil)
        }
    }
    
    @MainActor
    private func logPurchaseAnalytics(_ product: Product, transaction: StoreKit.Transaction? = nil) {
        guard product.type == .autoRenewable else { return }
        
        let firebaseManager = FirebaseManager.shared
        
        if let transaction = transaction {
            if transaction.isUpgraded {
                // Trial conversion
                firebaseManager.logTrialConverted(productId: product.id)
            } else if product.subscription != nil {
                // Regular subscription purchase
                firebaseManager.logSubscriptionStarted(productId: product.id)
            }
        } else {
            // Default subscription start
            firebaseManager.logSubscriptionStarted(productId: product.id, isTrial: false)
        }
    }
    
    private func handleSubscriptionCancellation(_ transaction: StoreKit.Transaction) {
        if isInTrialPeriod {
            FirebaseManager.shared.logTrialCancelled(productId: transaction.productID)
        } else {
            FirebaseManager.shared.logSubscriptionCancelled(productId: transaction.productID)
        }
    }
    
    private func handleSubscriptionRenewal(_ transaction: StoreKit.Transaction) {
        FirebaseManager.shared.logSubscriptionRenewed(productId: transaction.productID)
    }
    
    private func handleVerification(_ verification: StoreKit.VerificationResult<StoreKit.Transaction>) async throws {
        switch verification {
        case .verified(let transaction):
            await transaction.finish()
            try await refreshPurchasedIdentifiers()
            
            if transaction.productType == .autoRenewable {
                if let product = try? await Product.products(for: [transaction.productID]).first {
                    logPurchaseAnalytics(product, transaction: transaction)
                }
            }
            
        case .unverified:
            throw StoreError.failed(nil)
        }
    }
    
    private func refreshPurchasedIdentifiers() async throws {
        for await result in StoreKit.Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.revocationDate == nil {
                    purchasedIdentifiers.insert(transaction.productID)
                } else {
                    purchasedIdentifiers.remove(transaction.productID)
                }
            }
        }
        updateSubscriptionStatus()
    }
    
    @MainActor
    private func updateSubscriptionStatus() {
        isSubscribed = !purchasedIdentifiers.isEmpty
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
}
