# Yoga Nidra App Facebook SDK Integration

## Facebook SDK Integration

### Overview
The Facebook SDK integration in Yoga Nidra enables event tracking for analytics and marketing purposes. The implementation uses Facebook's Aggregated Event Measurement (AEM) to track key user actions while maintaining privacy compliance. This allows for measuring ad campaign effectiveness and understanding user behavior.

### Key Features
- Event tracking for key user actions
- Aggregated Event Measurement (AEM) support
- Integration with app's subscription and meditation flows
- Support for ad campaign attribution
- Privacy-focused implementation

### Files Modified

1. **AppDelegate.swift**
   - Added Facebook SDK initialization
   - Set up core app events logging
   - Code:
   ```swift
   private func setupFacebookSDK(launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) {
       ApplicationDelegate.shared.application(
           UIApplication.shared,
           didFinishLaunchingWithOptions: launchOptions
       )
   }
   
   func application(
       _ app: UIApplication,
       open url: URL,
       options: [UIApplication.OpenURLOptionsKey : Any] = [:]
   ) -> Bool {
       ApplicationDelegate.shared.application(
           app,
           open: url,
           options: options
       )
       return true
   }
   ```

2. **FacebookEventTracker.swift**
   - Created a dedicated service class to centralize Facebook event tracking
   - Implemented methods for tracking key events
   - Code:
   ```swift
   import Foundation
   import FBSDKCoreKit

   class FacebookEventTracker {
       // Singleton
       static let shared = FacebookEventTracker()
       
       private init() {}
       
       // Track when user completes onboarding
       func trackOnboardingCompleted() {
           AppEvents.shared.logEvent(AppEvents.Name("onboarding_completed"))
       }
       
       // Track when user starts a trial
       func trackTrialStarted(planName: String) {
           AppEvents.shared.logEvent(AppEvents.Name("fb_mobile_start_trial"))
       }
       
       // Track when user completes their first meditation
       func trackFirstMeditationCompleted() {
           // Only track first meditation once
           if !UserDefaults.standard.bool(forKey: "hasCompletedFirstMeditation") {
               UserDefaults.standard.set(true, forKey: "hasCompletedFirstMeditation")
               AppEvents.shared.logEvent(AppEvents.Name("first_meditation_completed"))
           }
       }
   }
   ```

3. **OnboardingManager.swift**
   - Added Facebook event tracking for onboarding completion
   - Code:
   ```swift
   func completeOnboarding() {
       isOnboardingCompleted = true
       
       // Track onboarding completion with Facebook
       Task {
           await MainActor.run {
               FacebookEventTracker.shared.trackOnboardingCompleted()
           }
       }
   }
   ```

4. **PaywallView.swift**
   - Added Facebook event tracking for trial starts
   - Code:
   ```swift
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

5. **AudioManager.swift**
   - Added Facebook event tracking for first meditation completion
   - Code:
   ```swift
   func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
       // Only track first meditation if it hasn't been tracked already
       if !UserDefaults.standard.bool(forKey: "hasCompletedFirstMeditation") {
           FacebookEventTracker.shared.trackFirstMeditationCompleted()
       }
       
       // Rest of the method...
   }
   ```

### Current Implementation

The current implementation tracks three key events:

1. **Onboarding Completed**
   - Tracked when a user finishes the onboarding flow
   - Event name: `onboarding_completed`
   - Triggered in OnboardingManager

2. **Trial Started**
   - Tracked when a user starts a subscription trial
   - Event name: `fb_mobile_start_trial` (standard Facebook event name)
   - Triggered in PaywallView

3. **First Meditation Completed**
   - Tracked when a user completes their first meditation session
   - Event name: `first_meditation_completed`
   - Triggered in AudioManager
   - Uses UserDefaults to ensure it's only tracked once per user

### Implementation Notes

1. **Aggregated Event Measurement (AEM)**
   - The implementation uses Facebook's AEM approach for iOS 14.5+ compatibility
   - This allows for measuring ad campaign effectiveness while respecting user privacy
   - Events are aggregated and anonymized by Facebook

2. **No App Tracking Transparency (ATT) Prompt**
   - The current implementation does not include the ATT prompt
   - This was a deliberate step-by-step approach to first implement basic tracking
   - ATT can be added later if more detailed user-level tracking is needed

3. **Event Visibility**
   - Events won't be visible in Facebook Events Manager until the app is released
   - This is normal behavior for apps that haven't been published yet

### Facebook Dashboard Setup

To complete the Facebook SDK integration, you need to set up the following in the Facebook dashboard:

1. **Configure Events**
   - In Events Manager, set up the three custom events
   - Prioritize events for Aggregated Event Measurement (max 8 events)

2. **Set Up Ad Campaigns**
   - Create app install or engagement campaigns
   - Set conversion events to track campaign effectiveness

3. **Configure App Settings**
   - Verify your app's bundle ID and other settings
   - Set up correct permissions and features

4. **Test Events**
   - Use Facebook's Event Testing tool to verify events are being sent correctly
   - Check for any implementation issues

### Future Enhancements

1. **App Tracking Transparency**
   - Implement the ATT prompt for users who might opt-in to tracking:
   ```swift
   func requestTrackingAuthorization() {
       if #available(iOS 14.5, *) {
           ATTrackingManager.requestTrackingAuthorization { status in
               switch status {
               case .authorized:
                   // Enable full tracking
                   Settings.shared.isAdvertiserTrackingEnabled = true
               case .denied, .restricted, .notDetermined:
                   // Use limited tracking (AEM)
                   Settings.shared.isAdvertiserTrackingEnabled = false
               @unknown default:
                   Settings.shared.isAdvertiserTrackingEnabled = false
               }
           }
       }
   }
   ```

2. **Advanced Event Parameters**
   - Add more detailed parameters to events for better analytics:
   ```swift
   func trackMeditationCompleted(sessionId: String, duration: TimeInterval, category: String) {
       let parameters = [
           "session_id": sessionId,
           "duration": duration,
           "category": category
       ] as [String : Any]
       
       AppEvents.shared.logEvent(AppEvents.Name("meditation_completed"), parameters: parameters)
   }
   ```

3. **Conversion Value Tracking**
   - Implement SKAdNetwork conversion value updates:
   ```swift
   func updateConversionValue(for event: String) {
       if #available(iOS 14.0, *) {
           var conversionValue = 0
           
           switch event {
           case "onboarding_completed":
               conversionValue = 1
           case "first_meditation_completed":
               conversionValue = 2
           case "fb_mobile_start_trial":
               conversionValue = 4
           default:
               break
           }
           
           SKAdNetwork.updateConversionValue(conversionValue)
       }
   }
   ```

4. **Facebook Login**
   - Add Facebook Login functionality:
   ```swift
   func loginWithFacebook() {
       let loginManager = LoginManager()
       loginManager.logIn(permissions: ["public_profile", "email"], from: nil) { result, error in
           if let error = error {
               print("Facebook login failed: \(error.localizedDescription)")
               return
           }
           
           if let result = result, !result.isCancelled {
               // Login successful
               let token = result.token?.tokenString
               // Use token for authentication
           }
       }
   }
   ```

5. **Deep Linking**
   - Implement deep linking for better campaign attribution:
   ```swift
   func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
       // Handle Facebook URL schemes
       ApplicationDelegate.shared.application(app, open: url, options: options)
       
       // Handle your app's custom URL schemes
       if url.scheme == "yoganidra" {
           // Process deep link
           handleDeepLink(url)
       }
       
       return true
   }
   ```

### Troubleshooting

If you encounter issues with Facebook SDK:

1. **Events Not Appearing**
   - Events won't appear in Events Manager until the app is released
   - Use Facebook's Event Testing tool to verify implementation
   - Check that the correct app ID is being used

2. **Integration Issues**
   - Verify that all required frameworks are linked
   - Check Info.plist for required Facebook configuration
   - Ensure AppDelegate is properly set up

3. **Privacy Concerns**
   - Review Facebook's data use policy
   - Ensure your app's privacy policy mentions Facebook data collection
   - Consider implementing ATT prompt for transparency

4. **Performance Impact**
   - Monitor app performance with Facebook SDK integrated
   - Consider batching events if sending many events
   - Use the lightweight version of the SDK if needed

5. **Debugging**
   - Enable verbose logging:
   ```swift
   Settings.shared.isLoggingEnabled = true
   ```
   - Check Xcode console for Facebook SDK logs
   - Use Facebook's developer tools for troubleshooting
