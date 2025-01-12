import StoreKit
import SwiftUI

@MainActor
final class StoreManager: ObservableObject {
    // MARK: - Singleton
    static let shared = StoreManager()
    
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
    private var processedTransactionIds = Set<UInt64>()
    private var isPurchaseInProgress = false
    private var isLoadingProducts = false
    private var hasLoadedProducts = false
    private var currentPurchaseTask: Task<Void, Error>?
    
    // MARK: - Initialization
    private init() {
        print("🚀 StoreManager: Initializing...")
        loadSavedSubscriptionState()
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
            for await result in Transaction.currentEntitlements {
                await self.handle(transactionResult: result)
            }
        }
        
        // Updates listener
        updateListenerTask = Task.detached(priority: .background) {
            print("🔄 StoreManager: Starting transaction updates listener...")
            for await update in Transaction.updates {
                await self.handle(transactionResult: update)
            }
        }
    }
    
    private func handle(transactionResult: VerificationResult<StoreKit.Transaction>) async {
        switch transactionResult {
        case .verified(let transaction):
            // Check if we've already processed this transaction
            guard !processedTransactionIds.contains(transaction.id) else {
                print("⚠️ StoreManager: Skipping already processed transaction: \(transaction.id)")
                return
            }
            
            print("✅ StoreManager: Processing new transaction: \(transaction.id)")
            processedTransactionIds.insert(transaction.id)
            
            // Update subscription state
            await MainActor.run {
                isSubscribed = true
                isInTrialPeriod = transaction.isUpgraded
                if let expirationDate = transaction.expirationDate {
                    trialEndDate = expirationDate
                }
            }
            
            // Save state
            saveSubscriptionState(true)
            
            // Finish the transaction
            await transaction.finish()
            print("🏁 StoreManager: Transaction finished: \(transaction.id)")
            
            // Add trial check
            checkTrialEligibility(transaction)
            
        case .unverified(_, let error):
            print("❌ StoreManager: Transaction verification failed: \(error.localizedDescription)")
            await MainActor.run {
                errorMessage = "Transaction verification failed: \(error.localizedDescription)"
                showError = true
            }
        }
    }
    
    // MARK: - Product Loading
    func loadProducts() async throws {
        guard !isLoadingProducts && !hasLoadedProducts else {
            print("⏭️ StoreManager: Products already loaded or loading in progress")
            return
        }
        
        isLoadingProducts = true
        defer { isLoadingProducts = false }
        
        print("🔍 StoreManager: Loading products...")
        isLoading = true
        defer { isLoading = false }
        
        let products = try await Product.products(for: [productID])
        guard let product = products.first else {
            print("❌ StoreManager: No products found")
            throw StoreError.productNotFound
        }
        
        print("""
        ✅ StoreManager: Product loaded successfully:
           - ID: \(product.id)
           - Price: \(product.price)
           - Type: \(product.type)
        """)
        
        self.subscriptionProduct = product
        // Format the price
        self.subscriptionPrice = product.displayPrice
        
        hasLoadedProducts = true
    }
    
    // MARK: - Purchase Flow
    func purchase() async throws {
        guard currentPurchaseTask == nil else {
            print("⚠️ StoreManager: Purchase already in progress")
            return
        }
        
        let task = Task {
            defer { currentPurchaseTask = nil }
            guard !isPurchaseInProgress else {
                print("⚠️ StoreManager: Purchase already in progress")
                return
            }
            
            guard let product = subscriptionProduct else {
                print("❌ StoreManager: No product available for purchase")
                throw StoreError.productNotFound
            }
            
            isPurchaseInProgress = true
            defer { isPurchaseInProgress = false }
            
            print("💰 StoreManager: Starting purchase for \(product.id)")
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                print("✅ StoreManager: Purchase successful, verifying...")
                await handle(transactionResult: verification)
                
            case .userCancelled:
                print("🚫 StoreManager: Purchase cancelled by user")
                
            case .pending:
                print("⏳ StoreManager: Purchase pending (Ask to Buy)")
                
            @unknown default:
                print("❓ StoreManager: Unknown purchase result")
                throw StoreError.unknown
            }
        }
        currentPurchaseTask = task
        try await task.value
    }
    
    // MARK: - State Management
    private func loadSavedSubscriptionState() {
        isSubscribed = UserDefaults.standard.bool(forKey: "subscriptionStateKey")
        print("📱 StoreManager: Loaded saved subscription state: \(isSubscribed)")
    }
    
    private func saveSubscriptionState(_ state: Bool) {
        UserDefaults.standard.set(state, forKey: "subscriptionStateKey")
        print("💾 StoreManager: Saved subscription state: \(state)")
    }
    
    // Restore Purchases
    func restorePurchases() async throws {
        print("🔄 StoreManager: Starting purchase restoration")
        isLoading = true
        defer { isLoading = false }
        
        try await AppStore.sync()
        print("✅ StoreManager: Purchase restoration completed")
        
        // Check current entitlements after restore
        for await result in Transaction.currentEntitlements {
            await handle(transactionResult: result)
        }
    }
    
    // MARK: - Trial Period Detection
    private func checkTrialEligibility(_ transaction: StoreKit.Transaction) {
        if let expirationDate = transaction.expirationDate {
            let isInTrial = transaction.purchaseDate.distance(to: expirationDate) <= 7*24*60*60
            isInTrialPeriod = isInTrial && expirationDate > Date()
            trialEndDate = isInTrial ? expirationDate : nil
            print("📅 StoreManager: Trial status - Active: \(isInTrialPeriod), Ends: \(expirationDate)")
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

// MARK: - Error Types
enum StoreError: LocalizedError {
    case productNotFound
    case networkError(Error)
    case purchaseInProgress
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Subscription product not found"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .purchaseInProgress:
            return "Purchase already in progress"
        case .unknown:
            return "An unknown error occurred"
        }
    }
} 