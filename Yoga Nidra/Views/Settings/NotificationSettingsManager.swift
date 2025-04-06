
import SwiftUI
import UserNotifications

final class NotificationSettingsManager: ObservableObject {
    
    static var shared: NotificationSettingsManager { .init() }
    
    @MainActor @Published var isShowingSettingAlert = false
    @MainActor @Published var isNotificationsEnabled = false
    @MainActor @Published var showingTimePickerSheet = false
    @MainActor @Published var selectedTime: Date  = .now
    
    private init() {
        Task { @MainActor in
            selectedTime = (Defaults.value(forKey: StroageKeys.sleepReminderTime) as? Date) ?? .now
        }
    }
    
    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async { [weak self] in
                self?.isNotificationsEnabled = settings.authorizationStatus == .authorized
                self?.isShowingSettingAlert = settings.authorizationStatus != .authorized
            }
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
            DispatchQueue.main.async { [weak self] in
                self?.isNotificationsEnabled = success
                if success {
                    self?.scheduleNotification(at: self?.selectedTime ?? .now)
                }
            }
        }
    }
    
    func scheduleNotification(at time: Date) {
        Defaults.set(time, forKey: StroageKeys.sleepReminderTime)
        // Cancel existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Time to Sleep"
        content.body = "It is time to sleep now! Sleep well!"
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: "dailyReminder",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }
}
