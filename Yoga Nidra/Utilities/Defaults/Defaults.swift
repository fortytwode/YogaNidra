import Foundation

enum StorageKeys {
    static let usersCollectionKey = "users"
    static let isLaunchedBefore = "isLaunchedBefore"
    static let appLaunchCountKey = "appLaunchCount"
    static let lastSessionDateKey = "lastSessionDateKey"
    static let streakCountKey = "streakCountKey"
    static let lastRatingDialogDateKey = "lastRatingDialogDate"
    static let hasRatedApp = "hasRatedApp"  // Only set when user taps "Rate on App Store"
    static let totalSessionListenTimeKey = "totalSessionListenTimeKey"
    static let totalSessionsCompletedKey = "totalSessionsCompletedKey"
    static let recentsSessionsKey = "recentsSessionsKey"
    static let favoriteSessionsKey = "favoriteSessionsKey"
    static let sleepReminderTime = "sleepReminderTime"
}

var Defaults: UserDefaults {
    UserDefaults.standard
}
