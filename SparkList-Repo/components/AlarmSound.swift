//
//  AlarmSound.swift
//  SparkList
//
//  Created by User on 12/17/23.
//

import SwiftUI
import AVFoundation
struct AlarmSound: View {


    var body: some View {
        VStack {
            Text("Your App Content")
        }
        .onAppear {
            // Schedule a local notification at the desired time
            scheduleNotification()
        }
    }

   

    // Function to schedule a local notification
    func scheduleNotification() {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Time to turn in hours!"
        notificationContent.sound = .default // Use default notification sound

        // Set the desired time for the notification
        var dateComponents = DateComponents()
        dateComponents.hour = 20 // Set the hour here (24-hour format)
        dateComponents.minute = 0 // Set the minute here

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: "dailyAlarm", content: notificationContent, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully")
            }
        }
    }
}
#Preview {
    AlarmSound()
}
