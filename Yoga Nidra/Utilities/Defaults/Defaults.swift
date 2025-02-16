
import Foundation

enum StroageKeys {
    static let usersCollectionKey = "users"
    static let isLaunchedBefore = "isLaunchedBefore"
    static let appLaunchCountKey = "appLaunchCount"
    static let lastSessionDateKey = "lastSessionDateKey"
    static let streakCountKey = "streakCountKey"
    static let lastRatingDialogDateKey = "lastRatingDialogDate"
    static let totalSessionListenTimeKey = "totalSessionListenTimeKey"
    static let totalSessionsCompletedKey = "totalSessionsCompletedKey"
}

var Defaults: UserDefaults {
    UserDefaults.standard
}
