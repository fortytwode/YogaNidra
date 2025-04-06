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
            Spacer()
            DatePicker(
                "Select bed time",
                selection: $selectedTime,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            Spacer()
            Text("Would you like to be reminded of your bed time?")
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
            notificationSettingsManager.selectedTime = selectedTime
            notificationSettingsManager.scheduleNotification(at: selectedTime)
            nextPage()
        }
    }
}

#Preview {
    SleepReminderView {}
}
