# Yoga Nidra App SDK Documentation

## Superwall SDK Integration

### Overview
Superwall is a powerful SDK that allows you to create and manage paywalls remotely without requiring app updates. It integrates with RevenueCat to handle subscription management and provides A/B testing capabilities for optimizing conversion rates.

### Key Features
- Remote paywall configuration and management
- A/B testing for paywall optimization
- Event-based paywall triggers
- Analytics and conversion tracking
- Seamless integration with RevenueCat

### Files Modified

1. **AppDelegate.swift**
   - Added Superwall SDK initialization
   - Configured basic RevenueCat integration
   - Code:
   ```swift
   private func configureSuperwallSDK() {
       // Simple configuration with just the API key
       Superwall.configure(apiKey: "pk_43c10a21c60615dc63a3862187df3ced631ac5742bdd23db")
   }
   
   private func configureRevenueCat() {
       // Configure RevenueCat with the most basic configuration
       Purchases.configure(withAPIKey: "appl_KDvjJIUgkZHCeRNGQZCsJlrMFbB")
   }
   ```

2. **SuperwallManager.swift**
   - Created a new manager class to centralize Superwall interactions
   - Implemented methods for showing paywalls and tracking events
   - Maintained compatibility with existing Facebook event tracking
   - Code:
   ```swift
   // Simple method to show a paywall
   func showPaywall() {
       // Just register the placement without any complex handlers
       Superwall.shared.register(placement: "show_paywall")
       
       // Track paywall view with Facebook
       AppEvents.shared.logEvent(AppEvents.Name("paywall_viewed"))
   }
   
   // Track an event that might trigger a paywall
   func trackEvent(_ eventName: String) {
       // Simply register the placement
       Superwall.shared.register(placement: eventName)
       
       // Also track in Facebook for key events
       if eventName == "onboarding_completed" {
           AppEvents.shared.logEvent(AppEvents.Name("onboarding_completed"))
       } else if eventName == "first_meditation_completed" {
           AppEvents.shared.logEvent(AppEvents.Name("first_meditation_completed"))
       }
   }
   ```

3. **PaywallView.swift**
   - Updated to use SuperwallManager for paywall presentation
   - Maintained fallback UI in case Superwall doesn't present a paywall
   - Code:
   ```swift
   private func presentSuperwallPaywall() {
       // Use the simplified SuperwallManager method
       SuperwallManager.shared.showPaywall()
   }
   ```

### Current Implementation

The current implementation provides a minimal but functional integration with Superwall:

1. **SDK Initialization**
   - Both Superwall and RevenueCat are initialized in AppDelegate
   - Basic configuration is used to minimize complexity

2. **Event Tracking**
   - Key events are registered with Superwall:
     - `onboarding_completed`
     - `first_meditation_completed`
     - `show_paywall`
   - Facebook event tracking is maintained for analytics continuity

3. **Paywall Presentation**
   - When a user reaches the paywall screen, Superwall is triggered
   - A fallback UI is shown if Superwall doesn't present anything

4. **User Identification**
   - Method provided to set the same user ID in both Superwall and RevenueCat

### A/B Testing Implementation

To implement A/B testing with Superwall, you don't need additional code in your app. Superwall handles A/B testing through its dashboard:

1. **Dashboard Configuration**
   - Create multiple paywall variants in the Superwall dashboard
   - Set up an experiment with traffic allocation percentages
   - Define conversion goals (e.g., subscription purchase)

2. **Tracking Results**
   - Superwall automatically tracks which variant performs better
   - You can view results in the Superwall dashboard
   - Metrics include impressions, conversions, and revenue

3. **Optimizing Conversions**
   - Based on results, you can adjust traffic allocation
   - Eventually, you can direct 100% of traffic to the best-performing variant

### Future Enhancements

1. **Advanced Event Parameters**
   - Pass additional context with events for better targeting:
   ```swift
   func trackEventWithParams(_ eventName: String, params: [String: Any]) {
       Superwall.shared.register(placement: eventName, params: params)
   }
   ```

2. **Custom Paywall Handlers**
   - Implement more sophisticated presentation handlers:
   ```swift
   func showPaywallWithHandler() {
       let handler = PaywallPresentationHandler()
       // Configure handler methods
       Superwall.shared.register(placement: "show_paywall", params: nil, handler: handler)
   }
   ```

3. **User Attributes**
   - Set user attributes for better targeting:
   ```swift
   func setUserAttributes(_ attributes: [String: Any]) {
       Superwall.shared.setUserAttributes(attributes)
   }
   ```

4. **Subscription Status Sync**
   - Implement more robust subscription status synchronization:
   ```swift
   func updateSubscriptionStatus(isSubscribed: Bool) {
       if isSubscribed {
           Superwall.shared.subscriptionStatus = .active(entitlements: ["premium"])
       } else {
           Superwall.shared.subscriptionStatus = .inactive
       }
   }
   ```

5. **Deeper RevenueCat Integration**
   - Implement a custom purchase controller for more control:
   ```swift
   class CustomPurchaseController: NSObject, PurchaseController {
       // Implement required methods
   }
   
   // In AppDelegate
   Superwall.configure(
       apiKey: "YOUR_API_KEY",
       purchaseController: CustomPurchaseController(),
       options: nil
   )
   ```

### Dashboard Setup Requirements

To complete the Superwall integration, you need to set up the following in the Superwall dashboard:

1. **Create Paywalls**
   - Design your paywall UI in the Superwall dashboard
   - Configure product offerings that match your RevenueCat products

2. **Create Campaigns**
   - Set up campaigns that use the placement names from your code
   - Configure audience rules if needed

3. **Link Products**
   - Ensure product IDs in Superwall match your RevenueCat product IDs

4. **Set Up Events**
   - Configure which events should trigger paywalls
   - Set up event properties for targeting if needed

### Troubleshooting

If paywalls aren't appearing:

1. **Check Placement Names**
   - Ensure placement names in code match those in the Superwall dashboard

2. **Verify API Keys**
   - Confirm that API keys are correct for both Superwall and RevenueCat

3. **Check Network Connectivity**
   - Superwall requires internet connection to fetch paywall configurations

4. **Debug Mode**
   - Enable debug logging for more information:
   ```swift
   Superwall.shared.logLevel = .debug
   ```

5. **Test User Identification**
   - Make sure user IDs are correctly synchronized between SDKs