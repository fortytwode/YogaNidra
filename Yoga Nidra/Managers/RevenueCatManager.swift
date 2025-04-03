//
//  RevenueCatManager.swift
//  Yoga Nidra
//
//  Created on 02/04/25.
//

import Foundation
import Combine
import FBSDKCoreKit
import RevenueCat

@MainActor
class RevenueCatManager: NSObject, ObservableObject {
    // MARK: - Singleton
    static let shared: RevenueCatManager = {
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return RevenueCatManager(isPreview: true)
        }
        #endif
        return RevenueCatManager()
    }()
    
    // MARK: - Preview Support
    static var preview: RevenueCatManager {
        return RevenueCatManager(isPreview: true)
    }
    
    // MARK: - Published Properties
    @Published private(set) var isSubscribed = false
    @Published private(set) var isInTrialPeriod = false
    @Published private(set) var trialEndDate: Date?
    @Published private(set) var offerings: Offerings?
    @Published private(set) var currentPackage: Package?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    // MARK: - Constants
    private let entitlementID = "premium"
    private let apiKey = "appl_MhpUQCAfwTMwCVeDAGsENEYsmQB" // Apple SDK key
    private let isPreview: Bool
    
    // MARK: - Events
    private var purchaseCompletedSubject = PassthroughSubject<Bool, Never>()
    var purchaseCompletedPublisher: AnyPublisher<Bool, Never> {
        purchaseCompletedSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    private override init() {
        self.isPreview = false
        super.init()
        configureRevenueCat()
        setupObservers()
        
        // Use Task to call async method from non-async initializer
        Task {
            await loadOfferings()
        }
    }
    
    private init(isPreview: Bool) {
        self.isPreview = isPreview
        super.init()
        
        // Skip actual SDK initialization in preview mode
        if !isPreview {
            configureRevenueCat()
            setupObservers()
            
            // Use Task to call async method from non-async initializer
            Task {
                await loadOfferings()
            }
        } else {
            // Set up mock data for preview
            self.offerings = nil
            self.currentPackage = nil
            self.isSubscribed = false
            self.isInTrialPeriod = false
        }
    }
    
    private func configureRevenueCat() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: apiKey)
        Purchases.shared.delegate = self
    }
    
    private func setupObservers() {
        refreshSubscriptionStatus()
    }
    
    // MARK: - Public Methods
    func loadOfferings() async {
        // Skip SDK calls in preview mode
        guard !isPreview else {
            print("📱 [PREVIEW] Loading offerings")
            // Simulate a delay for realism
            try? await Task.sleep(nanoseconds: 500_000_000)
            return
        }
        
        isLoading = true
        
        do {
            // Add retry logic (up to 3 attempts)
            var attempts = 0
            var success = false
            
            while attempts < 3 && !success {
                attempts += 1
                
                do {
                    print("🔍 RevenueCatManager: Loading offerings (attempt \(attempts)/3)...")
                    let offerings = try await Purchases.shared.offerings()
                    self.offerings = offerings
                    self.currentPackage = offerings.current?.availablePackages.first
                    
                    // Log success or failure
                    if self.currentPackage != nil {
                        print("✅ RevenueCatManager: Successfully loaded offerings with package")
                        success = true
                    } else {
                        print("⚠️ RevenueCatManager: Loaded offerings but no packages available (attempt \(attempts)/3)")
                        // Wait before retry if not the last attempt
                        if attempts < 3 {
                            try await Task.sleep(nanoseconds: 1_000_000_000)
                        }
                    }
                } catch {
                    print("❌ RevenueCatManager: Failed to load offerings (attempt \(attempts)/3): \(error)")
                    // Wait before retry if not the last attempt
                    if attempts < 3 {
                        try await Task.sleep(nanoseconds: 1_000_000_000)
                    }
                }
            }
            
            isLoading = false
            
            // If all attempts failed, set error message
            if !success && self.currentPackage == nil {
                errorMessage = "Failed to load subscription options"
                showError = true
                print("❌ RevenueCatManager: All attempts to load offerings failed")
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            isLoading = false
            print("❌ RevenueCatManager: Exception during offerings loading: \(error)")
        }
    }
    
    func purchase() async throws {
        // Skip SDK calls in preview mode
        guard !isPreview else {
            print("📱 [PREVIEW] Purchase completed")
            isLoading = true
            // Simulate a delay for realism
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            isSubscribed = true
            purchaseCompletedSubject.send(true)
            isLoading = false
            return
        }
        
        guard let package = currentPackage else {
            throw NSError(domain: "RevenueCatManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "No package available"])
        }
        
        isLoading = true
        
        do {
            let result = try await Purchases.shared.purchase(package: package)
            isSubscribed = result.customerInfo.entitlements[entitlementID]?.isActive == true
            
            // Track event with Facebook SDK
            AppEvents.shared.logEvent(AppEvents.Name("fb_mobile_start_trial"))
            
            purchaseCompletedSubject.send(isSubscribed)
            isLoading = false
        } catch {
            isLoading = false
            throw error
        }
    }
    
    func restorePurchases() async throws {
        // Skip SDK calls in preview mode
        guard !isPreview else {
            print("📱 [PREVIEW] Restoring purchases")
            isLoading = true
            // Simulate a delay for realism
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            isSubscribed = true
            purchaseCompletedSubject.send(true)
            isLoading = false
            return
        }
        
        isLoading = true
        
        do {
            let info = try await Purchases.shared.restorePurchases()
            isSubscribed = info.entitlements[entitlementID]?.isActive == true
            purchaseCompletedSubject.send(isSubscribed)
            isLoading = false
        } catch {
            isLoading = false
            throw error
        }
    }
    
    func refreshSubscriptionStatus() {
        // Skip SDK calls in preview mode
        guard !isPreview else {
            print("📱 [PREVIEW] Refreshing subscription status")
            return
        }
        
        Task {
            do {
                let info = try await Purchases.shared.customerInfo()
                isSubscribed = info.entitlements[entitlementID]?.isActive == true
                
                // Check for trial period
                if let expirationDate = info.entitlements[entitlementID]?.expirationDate,
                   let _ = info.entitlements[entitlementID]?.latestPurchaseDate {
                    let isInTrial = info.entitlements[entitlementID]?.periodType == .trial
                    isInTrialPeriod = isInTrial
                    trialEndDate = expirationDate
                }
            } catch {
                print("Error refreshing subscription status: \(error)")
            }
        }
    }
}

// MARK: - PurchasesDelegate
extension RevenueCatManager: PurchasesDelegate {
    nonisolated func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        // Skip processing in preview mode
        guard !isPreview else { return }
        
        Task { @MainActor in
            isSubscribed = customerInfo.entitlements[entitlementID]?.isActive == true
            
            // Check for trial period
            if let expirationDate = customerInfo.entitlements[entitlementID]?.expirationDate,
               let _ = customerInfo.entitlements[entitlementID]?.latestPurchaseDate {
                let isInTrial = customerInfo.entitlements[entitlementID]?.periodType == .trial
                isInTrialPeriod = isInTrial
                trialEndDate = expirationDate
            }
            
            // Update Superwall subscription status
            SuperwallManager.shared.updateSubscriptionStatus(isSubscribed: isSubscribed)
        }
    }
}
