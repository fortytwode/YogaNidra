
import Foundation

enum StroageKeys {
    static let usersCollectionKey = "users"
    static let isLaunchedBefore = "isLaunchedBefore"
    static let appLaunchCountKey = "appLaunchCount"
    static let lastSessionDateKey = "lastSessionDateKey"
    static let streakCountKey = "streakCountKey"
    static let lastRatingDialogDateKey = "lastRatingDialogDate"
    static let isAppRated = "isAppRated"
    static let totalSessionListenTimeKey = "totalSessionListenTimeKey"
    static let totalSessionsCompletedKey = "totalSessionsCompletedKey"
    static let recentsSessionsKey = "recentsSessionsKey"
    static let favoriteSessionsKey = "favoriteSessionsKey"
}

var Defaults: UserDefaults {
    UserDefaults.standard
}
