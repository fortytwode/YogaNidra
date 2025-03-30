import SwiftUI
import StoreKit

struct SleepReminderPromptView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var overlayManager: OverlayManager
    @EnvironmentObject var notificationSettingsManager: NotificationSettingsManager
    
    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                header
                buttons
            }
            .background {
                Image("rating-background")
                    .resizable()
                    .opacity(colorScheme == .dark ? 0.2: 0.2)
                    .clipped()
            }
            .background(colorScheme == .dark ? Color(white: 0.1) : .gray.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .background {
                RoundedRectangle(cornerRadius: 24)
                    .shadow(color: colorScheme == .dark ? .white.opacity(0.3) : .black, radius: 8, x: 4, y: 4)
            }
            .padding(.horizontal)
        }
    }
    
    var header: some View {
        VStack(spacing: 16) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 48))
                .foregroundColor(.purple)
                .modify {
                    if #available(iOS 18.0, *) {
                        $0.symbolEffect(.bounce)
                    }
                }
            
            Text("Would you like to be reminded for better sleep?")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
            
            VStack(spacing: 8) {
                Text("Take a moment to set up reminder.")
            }
            .font(.body)
            .multilineTextAlignment(.center)
            .foregroundColor(.primary.opacity(0.8))
            .lineSpacing(4)
        }
        .padding(.top, 32)
        .padding(.horizontal)
    }
    
    var buttons: some View {
        VStack(spacing: 12) {
            Button {
                setupReminder()
                overlayManager.hideOverlay()
            } label: {
                Text("Setup Reminder")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            
            Button {
                overlayManager.hideOverlay()
            } label: {
                Text("Maybe Later")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 32)
    }
    
    private func setupReminder() {
        notificationSettingsManager.checkNotificationStatus()
        notificationSettingsManager.requestNotificationPermission()
        let calendar = Calendar.current
        let date = calendar.date(bySettingHour: 22, minute: 0, second: 0, of: Date()) ?? .now
        notificationSettingsManager.selectedTime = date
        notificationSettingsManager.scheduleNotification(at: date)
    }
}
