# Yoga Nidra App RevenueCat Integration

## RevenueCat SDK Integration

### Overview
RevenueCat is a subscription management platform that simplifies in-app purchases and subscriptions. It provides tools for tracking subscription status, managing entitlements, and analyzing revenue metrics. The integration in Yoga Nidra app enables subscription management with analytics and cross-platform receipt validation.

### Key Features
- Cross-platform subscription management
- Server-side receipt validation
- Subscription status tracking
- Analytics and revenue metrics
- Entitlements management
- Integration with other services (like Superwall)

### Files Modified

1. **AppDelegate.swift**
   - Added RevenueCat SDK initialization
   - Code:
   ```swift
   private func configureRevenueCat() {
       // Configure RevenueCat with the most basic configuration
       Purchases.configure(withAPIKey: "appl_KDvjJIUgkZHCeRNGQZCsJlrMFbB")
   }
   ```

2. **RevenueCatManager.swift**
   - Created a manager class to centralize RevenueCat interactions
   - Implemented methods for loading offerings, purchasing, and restoring purchases
   - Added subscription status tracking
   - Code:
   ```swift
   @MainActor
   class RevenueCatManager: NSObject, ObservableObject {
       // Singleton
       static let shared = RevenueCatManager()
       
       // Published properties for SwiftUI
       @Published var isSubscribed = false
       @Published var isInTrialPeriod = false
       @Published var offerings: Offerings?
       @Published var isLoading = false
       @Published var errorMessage: String?
       @Published var trialEndDate: Date?
       
       // Constants
       let entitlementID = "premium"
       
       private override init() {
           super.init()
           Purchases.shared.delegate = self
           Task {
               await loadOfferings()
           }
       }
       
       // Load available offerings from RevenueCat
       func loadOfferings() async {
           isLoading = true
           do {
               offerings = try await Purchases.shared.offerings()
               try await checkSubscriptionStatus()
           } catch {
               errorMessage = error.localizedDescription
           }
           isLoading = false
       }
       
       // Check if user is subscribed
       func checkSubscriptionStatus() async throws {
           let customerInfo = try await Purchases.shared.customerInfo()
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
   ```

3. **StoreManager.swift**
   - Updated to use RevenueCat for purchases
   - Integrated with the app's existing purchase flow
   - Code:
   ```swift
   func purchase() async throws {
       guard let offering = RevenueCatManager.shared.offerings?.current,
             let package = offering.availablePackages.first else {
           throw StoreError.noProductsAvailable
       }
       
       do {
           let purchaseResult = try await Purchases.shared.purchase(package: package)
           if purchaseResult.customerInfo.entitlements["premium"]?.isActive == true {
               // Purchase successful
               return
           } else {
               throw StoreError.purchaseFailed
           }
       } catch {
           throw error
       }
   }
   
   func restore() async throws {
       do {
           let customerInfo = try await Purchases.shared.restorePurchases()
           if customerInfo.entitlements["premium"]?.isActive == true {
               // Restore successful
               return
           } else {
               throw StoreError.noPurchasesToRestore
           }
       } catch {
           throw error
       }
   }
   ```

4. **PaywallView.swift**
   - Updated to display subscription options from RevenueCat
   - Added purchase and restore functionality
   - Code:
   ```swift
   @StateObject private var revenueCatManager = RevenueCatManager.shared
   
   // In the view body
   Text("Then just \(storeManager.formattedPrice) (that's $5/month for better sleep) 💎")
   
   Button {
       Task {
           do {
               try await storeManager.purchase()
               onboardingManager.isOnboardingCompleted = true
               
               // Track trial started event with Facebook
               FacebookEventTracker.shared.trackTrialStarted(planName: "premium_yearly")
           } catch {
               showError = true
               errorMessage = error.localizedDescription
           }
       }
   } label: {
       // Button label
   }
   ```

### Current Implementation

The current implementation provides a robust integration with RevenueCat:

1. **SDK Initialization**
   - RevenueCat is initialized in AppDelegate with your API key
   - The manager class is set up as a singleton for app-wide access

2. **Subscription Management**
   - Methods for purchasing and restoring subscriptions
   - Automatic checking of subscription status
   - Trial period detection and tracking

3. **UI Integration**
   - Paywall displays pricing information from RevenueCat
   - Loading states for network operations
   - Error handling for purchase failures

4. **Analytics**
   - Facebook events are triggered for subscription events
   - RevenueCat's built-in analytics track purchases and revenue

### RevenueCat Dashboard Setup

To complete the RevenueCat integration, you need to set up the following in the RevenueCat dashboard:

1. **Configure Products**
   - Add your App Store Connect products to RevenueCat
   - Set up entitlements (the app uses "premium" as the entitlement ID)
   - Configure offering packages (e.g., monthly, yearly)

2. **Set Up Integrations**
   - Connect RevenueCat to other analytics platforms if needed
   - Configure webhooks for server-side notifications

3. **Test Sandbox Purchases**
   - Use sandbox accounts to test the purchase flow
   - Verify that entitlements are correctly assigned

4. **Monitor Analytics**
   - Track conversion rates and revenue metrics
   - Monitor subscription renewals and cancellations

### Future Enhancements

1. **Subscription Management UI**
   - Add a dedicated screen for users to manage their subscriptions:
   ```swift
   struct SubscriptionManagementView: View {
       @StateObject private var revenueCatManager = RevenueCatManager.shared
       
       var body: some View {
           VStack {
               if revenueCatManager.isSubscribed {
                   Text("You are subscribed to Premium")
                   if let expirationDate = revenueCatManager.trialEndDate {
                       Text("Your subscription will renew on \(expirationDate.formatted(date: .abbreviated, time: .omitted))")
                   }
                   Button("Manage Subscription") {
                       if let url = URL(string: "itms-apps://apps.apple.com/account/subscriptions") {
                           UIApplication.shared.open(url)
                       }
                   }
               } else {
                   Text("You are not currently subscribed")
                   Button("Subscribe Now") {
                       // Show paywall
                   }
               }
           }
       }
   }
   ```

2. **Promotional Offers**
   - Implement support for promotional offers and discounts:
   ```swift
   func offerPromotion(to userId: String) async throws {
       guard let offering = RevenueCatManager.shared.offerings?.current,
             let package = offering.availablePackages.first else {
           throw StoreError.noProductsAvailable
       }
       
       // Apply promotion discount
       let discount = SKPaymentDiscount(
           identifier: "PROMO_50_OFF",
           keyIdentifier: "your_key_identifier",
           nonce: UUID(),
           signature: "signature",
           timestamp: NSNumber(value: Int(Date().timeIntervalSince1970))
       )
       
       try await Purchases.shared.purchase(package: package, discount: discount)
   }
   ```

3. **Advanced User Identification**
   - Enhance user identification for cross-device subscription syncing:
   ```swift
   func identifyUser(userId: String) async throws {
       let customerInfo = try await Purchases.shared.logIn(userId)
       print("User \(userId) identified with RevenueCat")
       
       // Check if the user has existing purchases on another device
       if customerInfo.entitlements["premium"]?.isActive == true {
           print("User has active subscription from another device")
       }
   }
   ```

4. **Subscription Offers**
   - Implement different subscription tiers or introductory offers:
   ```swift
   func showSubscriptionOptions() -> some View {
       VStack {
           if let offerings = revenueCatManager.offerings {
               ForEach(offerings.current?.availablePackages ?? [], id: \.identifier) { package in
                   SubscriptionOptionView(package: package)
               }
           } else {
               ProgressView()
           }
       }
   }
   ```

5. **Receipt Validation Enhancements**
   - Add additional security measures for receipt validation:
   ```swift
   func validateReceipt() async throws {
       let customerInfo = try await Purchases.shared.customerInfo()
       guard let receiptURL = Bundle.main.appStoreReceiptURL,
             let receiptData = try? Data(contentsOf: receiptURL) else {
           throw StoreError.receiptNotFound
       }
       
       let receiptString = receiptData.base64EncodedString()
       // Send to your server for additional validation if needed
   }
   ```

### Troubleshooting

If you encounter issues with RevenueCat:

1. **Purchase Failures**
   - Check that products are correctly configured in App Store Connect
   - Verify that products are synced to RevenueCat
   - Test with sandbox accounts

2. **Subscription Status Issues**
   - Call `Purchases.shared.customerInfo()` to refresh subscription status
   - Check that the entitlement ID matches what's configured in RevenueCat

3. **Integration Problems**
   - Verify API keys are correct
   - Check network connectivity
   - Enable debug logging:
   ```swift
   Purchases.logLevel = .debug
   ```

4. **Sandbox Testing**
   - Use TestFlight for testing in-app purchases
   - Create sandbox tester accounts in App Store Connect
   - Remember that sandbox subscriptions have accelerated renewal periods

5. **Receipt Validation Failures**
   - Check that your app's bundle ID matches what's in App Store Connect
   - Verify that your app is using the correct RevenueCat API key
   - Ensure your app has the correct entitlements for in-app purchases
