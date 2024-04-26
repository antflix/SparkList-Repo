import SwiftUI
struct AlarmSettingView: View {
	@EnvironmentObject var dataManager: DataManager

	var body: some View {
		VStack {
			Capsule()
				.frame(width: 40, height: 6)
				.foregroundColor(.secondary)
				.padding(.top, 5)
			Text("Daily Notification Schedule:")
				.font(.title)
				.foregroundStyle(Color("Color 1"))
			DatePicker("", selection: $dataManager.selectedTime, displayedComponents: .hourAndMinute)
				.datePickerStyle(WheelDatePickerStyle())
				.foregroundStyle(Color("Color 1")) // Use a wheel-style picker for time selection
			HStack {
				Button("Set Notification ") {
					dataManager.isAlarmSet = true

					dataManager.scheduleAlarm(at: dataManager.selectedTime, soundName: dataManager.alarmNoise)
				}.buttonStyle(PlainButtonStyle())
					.padding()
					.background(Color.green)
					.foregroundColor(.white)
					.cornerRadius(8)
				Button("Clear Notification") {
					dataManager.cancelAlarm() // Function to cancel the notification
					dataManager.isAlarmSet = false
				}.buttonStyle(PlainButtonStyle())
					.padding()
					.background(Color.red)
					.foregroundColor(.white)
					.cornerRadius(8)
			}
			Toggle("Persistent Mode", isOn: $dataManager.persistentMode)
				.onChange(of: dataManager.persistentMode) { newValue in
					UserDefaults.standard.set(newValue, forKey: "persistentMode")
					print("persistent mode has changed to \(dataManager.persistentMode)")
					UserDefaults.standard.synchronize()
				}
				.padding()
			Spacer()
			if dataManager.isAlarmSet {
				Text("Alarm is set for \(formattedTime(dataManager.selectedTime))")
					.font(.callout) // Adjust the font size and style
					.foregroundColor(.green) // Use a subdued color for the text
					.italic() // Make it italic to indicate a status message
					.padding(.top) // Add some top padding
			} else {
				Text("Alarm is not set")
					.font(.callout) // Adjust the font size and style
					.foregroundColor(.red) // Use a subdued color for the text
					.italic() // Make it italic to indicate a status message
			}
		}
		.padding()

	}

	// Function to format time for display
	private func formattedTime(_ time: Date) -> String {
		let formatter = DateFormatter()
		formatter.timeStyle = .short
		return formatter.string(from: time)
	}
}
