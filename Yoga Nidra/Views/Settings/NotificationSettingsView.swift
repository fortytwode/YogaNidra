import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @State private var isNotificationsEnabled = false
    @State private var showingTimePickerSheet = false
    @State private var selectedTime: Date
    
    init() {
        _selectedTime = State(wrappedValue: (Defaults.value(forKey: StroageKeys.sleepReminderTime) as? Date) ?? .now)
    }
    
    var body: some View {
        Form {
            Section {
                Toggle("Enable Notifications", isOn: $isNotificationsEnabled)
                    .onChange(of: isNotificationsEnabled) { _, newValue in
                        if newValue {
                            requestNotificationPermission()
                        } else {
                            // Cancel any scheduled notifications
                            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                        }
                    }
                
                if isNotificationsEnabled {
                    Button {
                        showingTimePickerSheet = true
                    } label: {
                        HStack {
                            Text("Reminder Time")
                            Spacer()
                            Text(selectedTime.formatted(date: .omitted, time: .shortened))
                                .foregroundColor(.gray)
                        }
                    }
                }
            } header: {
                Text("Sleep Reminders")
            } footer: {
                Text("We'll send you a gentle reminder to sleep at your chosen time each day.")
            }
        }
        .navigationTitle("Notifications")
        .sheet(isPresented: $showingTimePickerSheet) {
            NavigationStack {
                Form {
                    DatePicker("Select Time",
                              selection: $selectedTime,
                              displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .onChange(of: selectedTime) { _, newTime in
                            scheduleNotification(at: newTime)
                        }
                }
                .navigationTitle("Choose Time")
                .navigationBarItems(trailing: Button("Done") {
                    showingTimePickerSheet = false
                })
            }
            .presentationDetents([.height(300)])
        }
        .onAppear {
            checkNotificationStatus()
        }
    }
    
    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                isNotificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { success, error in
            DispatchQueue.main.async {
                isNotificationsEnabled = success
                if success {
                    scheduleNotification(at: selectedTime)
                }
            }
        }
    }
    
    private func scheduleNotification(at time: Date) {
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

// MARK: - Preview Provider
struct NotificationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NotificationSettingsView()
        }
    }
}
