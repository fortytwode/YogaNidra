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
    static let shared = RevenueCatManager()
    
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
    
    // MARK: - Events
    private var purchaseCompletedSubject = PassthroughSubject<Bool, Never>()
    var purchaseCompletedPublisher: AnyPublisher<Bool, Never> {
        purchaseCompletedSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    private override init() {
        super.init()
        configureRevenueCat()
        setupObservers()
        
        // Use Task to call async method from non-async initializer
        Task {
            await loadOfferings()
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
        isLoading = true
        
        do {
            let offerings = try await Purchases.shared.offerings()
            self.offerings = offerings
            self.currentPackage = offerings.current?.availablePackages.first
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            isLoading = false
        }
    }
    
    func purchase() async throws {
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
        Task { @MainActor in
            isSubscribed = customerInfo.entitlements[entitlementID]?.isActive == true
            
            // Check for trial period
            if let expirationDate = customerInfo.entitlements[entitlementID]?.expirationDate,
               let _ = customerInfo.entitlements[entitlementID]?.latestPurchaseDate {
                let isInTrial = customerInfo.entitlements[entitlementID]?.periodType == .trial
                isInTrialPeriod = isInTrial
                trialEndDate = expirationDate
            }
        }
    }
}
