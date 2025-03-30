import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    
    @EnvironmentObject var notificationSettingsManager: NotificationSettingsManager
    
    var body: some View {
        Form {
            Section {
                Toggle("Enable Notifications", isOn: $notificationSettingsManager.isNotificationsEnabled)
                    .onChange(of: notificationSettingsManager.isNotificationsEnabled) { _, newValue in
                        if newValue {
                            notificationSettingsManager.requestNotificationPermission()
                        } else {
                            // Cancel any scheduled notifications
                            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                        }
                    }
                
                if notificationSettingsManager.isNotificationsEnabled {
                    Button {
                        notificationSettingsManager.showingTimePickerSheet = true
                    } label: {
                        HStack {
                            Text("Reminder Time")
                            Spacer()
                            Text(notificationSettingsManager.selectedTime.formatted(date: .omitted, time: .shortened))
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
        .sheet(isPresented: $notificationSettingsManager.showingTimePickerSheet) {
            NavigationStack {
                Form {
                    DatePicker("Select Time",
                               selection: $notificationSettingsManager.selectedTime,
                              displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .onChange(of: notificationSettingsManager.selectedTime) { _, newTime in
                            notificationSettingsManager.scheduleNotification(at: newTime)
                        }
                }
                .navigationTitle("Choose Time")
                .navigationBarItems(trailing: Button("Done") {
                    notificationSettingsManager.showingTimePickerSheet = false
                })
            }
            .presentationDetents([.height(300)])
        }
        .onAppear {
            notificationSettingsManager.checkNotificationStatus()
        }
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
