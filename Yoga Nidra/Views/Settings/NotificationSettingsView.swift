import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @State private var isNotificationsEnabled = false
    @State private var selectedTime = Date()
    @State private var showingTimePickerSheet = false
    
    var body: some View {
        Form {
            Section {
                Toggle("Enable Notifications", isOn: $isNotificationsEnabled)
                    .onChange(of: isNotificationsEnabled) { newValue in
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
                Text("Daily Reminders")
            } footer: {
                Text("We'll send you a gentle reminder to practice your meditation at your chosen time.")
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
                        .onChange(of: selectedTime) { newTime in
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
        // Cancel existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Time for Yoga Nidra"
        content.body = "Take a moment to relax and restore your energy."
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        var trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // If the time has already passed today, schedule for tomorrow
        if let scheduledDate = calendar.date(from: components),
           scheduledDate < Date() {
            if let tomorrowComponents = calendar.date(byAdding: .day, value: 1, to: scheduledDate)?.get(.hour, .minute) {
                trigger = UNCalendarNotificationTrigger(dateMatching: tomorrowComponents, repeats: true)
            }
        }
        
        let request = UNNotificationRequest(identifier: "dailyReminder",
                                          content: content,
                                          trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - Date Extension
extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
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
