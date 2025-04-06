//
//  SleepReminderView.swift
//  Yoga Nidra
//
//  Created by Nishchal Visavadiya on 06/04/25.
//

import SwiftUI

struct SleepReminderView: View {
    
    let nextPage: () -> Void
    @State var selectedTime: Date = Date.todayAt10PM()
    @EnvironmentObject var notificationSettingsManager: NotificationSettingsManager
    
    var body: some View {
        VStack {
            Text("What is your ideal bed time?")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.top, 10)
                
            Text("Research shows that consistent bedtimes result in relaxed, restored sleep.")
                .font(.title3)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.top, 8)
                
            Spacer()
            ZStack {
                // Add a semi-transparent background behind the picker for better contrast
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.5))
                    .frame(height: 250)
                    .padding(.horizontal, -10)
                
                DatePicker(
                    "Select bed time",
                    selection: $selectedTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .accentColor(.white)
                .colorScheme(.dark) // More reliable than environment modifier
                .contentShape(Rectangle()) // Improve touch target
                .padding(.vertical, 10)
            }
            Spacer()
            Text("On the next screen, you can choose to be reminded to complete a bedtime Yoga Nidra session.")
                .font(.title3)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .fontWeight(.semibold)
                .textShadowEffect()
            Button {
                setupReminder()
            } label: {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 16)
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
        }
        .padding()
        .background(
            ZStack {
                Image("northern-lights")
                    .resizable()
                    .scaledToFill()
                
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.3),
                        Color.black.opacity(0.5)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .ignoresSafeArea()
        )
    }
    
    private func setupReminder() {
        Task {
            try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            print("Setting reminder for: \(timeString(from: selectedTime))")
            notificationSettingsManager.selectedTime = selectedTime
            notificationSettingsManager.scheduleNotification(at: selectedTime)
            nextPage()
        }
    }
    
    // Helper function to format the time for display
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

#Preview {
    SleepReminderView {}
}
