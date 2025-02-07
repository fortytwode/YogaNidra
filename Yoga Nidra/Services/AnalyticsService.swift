import Foundation
import Firebase
import FirebaseAnalytics
import FirebaseCrashlytics

@MainActor
final class AnalyticsService {
    static let shared = AnalyticsService()
    
    private init() {}
    
    // MARK: - Session Events
    func trackSessionStart(_ session: YogaNidraSession) {
        Analytics.logEvent("session_started", parameters: [
            "session_id": session.id,
            "session_title": session.title,
            "session_duration": session.duration,
            "session_category": session.category
        ])
    }
    
    func trackSessionComplete(_ session: YogaNidraSession) {
        Analytics.logEvent("session_completed", parameters: [
            "session_id": session.id,
            "session_title": session.title,
            "session_duration": session.duration,
            "session_category": session.category
        ])
    }
    
    func trackSessionPause(_ session: YogaNidraSession, atTime: TimeInterval) {
        Analytics.logEvent("session_paused", parameters: [
            "session_id": session.id,
            "pause_time": NSNumber(value: atTime),
            "session_progress": NSNumber(value: (atTime / Double(session.duration)) * 100)
        ])
    }
    
    // MARK: - Subscription Events
    func trackSubscriptionStart(tier: String, price: Decimal, currency: String) {
        Analytics.logEvent(AnalyticsEventBeginCheckout, parameters: [
            AnalyticsParameterPrice: NSDecimalNumber(decimal: price).doubleValue,
            AnalyticsParameterCurrency: currency,
            AnalyticsParameterItems: [
                [
                    AnalyticsParameterItemName: "Premium Subscription",
                    AnalyticsParameterItemVariant: tier
                ]
            ]
        ])
    }
    
    func trackSubscriptionSuccess(tier: String, price: Decimal, currency: String) {
        Analytics.logEvent(AnalyticsEventPurchase, parameters: [
            AnalyticsParameterSuccess: 1,
            AnalyticsParameterPrice: NSDecimalNumber(decimal: price).doubleValue,
            AnalyticsParameterCurrency: currency,
            AnalyticsParameterItems: [
                [
                    AnalyticsParameterItemName: "Premium Subscription",
                    AnalyticsParameterItemVariant: tier
                ]
            ]
        ])
    }
    
    // MARK: - Error Reporting
    func trackError(_ error: Error, context: [String: Any] = [:]) {
        var finalContext = context
        finalContext["timestamp"] = Date().timeIntervalSince1970
        
        // Log to Analytics
        Analytics.logEvent("error_occurred", parameters: [
            "error_domain": (error as NSError).domain,
            "error_code": (error as NSError).code,
            "error_description": error.localizedDescription
        ])
        
        // Log to Crashlytics
        Crashlytics.crashlytics().record(error: error, userInfo: finalContext)
    }
    
    // MARK: - User Properties
    func setUserProperties(isPremium: Bool, lastSessionDate: Date?) {
        Analytics.setUserProperty(isPremium ? "premium" : "free", forName: "user_tier")
        if let lastSession = lastSessionDate {
            Analytics.setUserProperty(ISO8601DateFormatter().string(from: lastSession), 
                                   forName: "last_session_date")
        }
    }
    
    // MARK: - Screen Tracking
    func trackScreen(_ screenName: String, class: String) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName,
            AnalyticsParameterScreenClass: `class`
        ])
    }
    
    // MARK: - Validation
    func validateAnalyticsSetup() {
        #if DEBUG
        print("🔍 Validating Analytics Setup...")
        
        // Test event
        Analytics.logEvent("analytics_validation", parameters: [
            "test_timestamp": Date().timeIntervalSince1970
        ])
        
        // Test error tracking
        let testError = NSError(domain: "AnalyticsValidation",
                              code: -1,
                              userInfo: [NSLocalizedDescriptionKey: "Test error for validation"])
        trackError(testError, context: ["validation": true])
        
        print("✅ Analytics validation complete")
        #endif
    }
}
