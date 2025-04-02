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
       Purchases.configure(withAPIKey: "appl_KDvjJIUgkZHCsJlrMFbB")
   }
   ```

2. **SuperwallManager.swift**
   - Created a new manager class to centralize Superwall interactions
   - Implemented methods for showing paywalls and tracking events
   - Added error handling and subscription status management
   - Maintained compatibility with existing Facebook event tracking
   - Code:
   ```swift
   // Enhanced method to show a paywall with error handling
   func showPaywallWithErrorHandling() {
       let handler = PaywallPresentationHandler()
       
       // Handle presentation errors - using the method (not property assignment)
       handler.onError { error in
           print("Superwall presentation error: \(error.localizedDescription)")
           
           // Log to Firebase Analytics directly
           Analytics.logEvent("superwall_presentation_error", parameters: [
               "error": error.localizedDescription
           ])
           
           // Notify observers about the failure
           NotificationCenter.default.post(
               name: SuperwallManager.presentationFailedNotification,
               object: nil
           )
       }
       
       // Register the placement with the handler
       Superwall.shared.register(
           placement: "show_paywall",
           params: nil,
           handler: handler
       )
   }
   
   // Update subscription status in Superwall
   func updateSubscriptionStatus(isSubscribed: Bool) {
       if isSubscribed {
           // Create an empty Set of Entitlement
           let entitlements: Set<Entitlement> = [Entitlement(id: "premium")]
           Superwall.shared.subscriptionStatus = .active(entitlements)
       } else {
           Superwall.shared.subscriptionStatus = .inactive
       }
   }
   ```

3. **PaywallView.swift**
   - Updated to use enhanced SuperwallManager for paywall presentation
   - Implemented notification observer for handling presentation failures
   - Added dynamic UI that adapts when Superwall fails to present
   - Code:
   ```swift
   .onAppear {
       // Add notification observer for Superwall presentation failures
       notificationToken = NotificationCenter.default.addObserver(
           forName: SuperwallManager.presentationFailedNotification,
           object: nil,
           queue: .main
       ) { [self] _ in
           self.superwallPresentationFailed = true
       }
       
       // Show Superwall after a brief delay
       DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
           presentSuperwallPaywall()
       }
   }
   
   private func presentSuperwallPaywall() {
       // Use the enhanced error handling method
       SuperwallManager.shared.showPaywallWithErrorHandling()
   }
   ```

4. **RevenueCatManager.swift**
   - Updated to sync subscription status with Superwall
   - Code:
   ```swift
   nonisolated func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
       Task { @MainActor in
           isSubscribed = customerInfo.entitlements[entitlementID]?.isActive == true
           
           // Update Superwall subscription status
           SuperwallManager.shared.updateSubscriptionStatus(isSubscribed: isSubscribed)
       }
   }
   ```

### Current Implementation

The current implementation provides a robust integration with Superwall:

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
   - Enhanced error handling with proper notification system
   - Fallback UI automatically shows with full opacity if Superwall fails to present
   - Firebase Analytics tracks presentation errors for debugging

4. **User Identification**
   - Method provided to set the same user ID in both Superwall and RevenueCat
   - Proper error handling for RevenueCat identification

5. **Subscription Status Management**
   - Automatic syncing of subscription status between RevenueCat and Superwall
   - Proper handling of entitlements for active subscriptions

6. **User Attributes**
   - Support for setting user attributes for better targeting
   - Convenience method for updating common user profile data

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

### Testing Your Implementation

Before submitting to the App Store, you can test the following locally:

1. **Paywall Presentation**
   - Navigate to the paywall screen to verify Superwall presents correctly
   - Check console logs for any errors

2. **Fallback UI**
   - You can test the fallback UI by:
     - Temporarily using an invalid API key
     - Turning off internet connection
     - The native UI should appear with full opacity

3. **Event Logging**
   - Use debug logs to confirm events are being sent to Facebook and Firebase
   - Full event visibility in Facebook Events Manager will only be available after app release

4. **Subscription Status**
   - Test subscription purchase flow with sandbox accounts
   - Verify that subscription status is properly reflected in the app

### Future Enhancements

1. **Advanced Event Parameters**
   - Pass additional context with events for better targeting

2. **Deeper Analytics Integration**
   - Implement more sophisticated analytics tracking
   - Add custom conversion events

3. **Localization Support**
   - Configure paywalls for different languages and regions

4. **Offline Support**
   - Enhance fallback UI for offline scenarios
   - Cache paywall configurations for offline use

### Dashboard Setup Requirements

To complete the Superwall integration, you need to set up the following in the Superwall dashboard:

1. **Create Paywalls**
   - Design your paywall UI in the Superwall dashboard
   - Configure product offerings that match your RevenueCat products

2. **Create Campaigns**
   - Set up campaigns that use the placement names from your code (`show_paywall`)
   - Configure audience rules if needed

3. **Link Products**
   - Ensure product IDs in Superwall match your RevenueCat product IDs

4. **Set Up Events**
   - Configure which events should trigger paywalls
   - Set up event properties for targeting if needed

5. **Configure A/B Tests**
   - Create multiple paywall variants
   - Set up experiments with different traffic allocations

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
   Superwall.configure(
       apiKey: "YOUR_API_KEY",
       options: .init(debugMode: true)
   )
   ```

5. **Check Error Notifications**
   - Look for `SuperwallManager.presentationFailedNotification` notifications
   - Check Firebase Analytics for "superwall_presentation_error" events

6. **Verify Subscription Status**
   - Ensure subscription status is being properly synced from RevenueCat to Superwall