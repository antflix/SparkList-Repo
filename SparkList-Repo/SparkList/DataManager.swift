//
//  DataManager.swift
//  project1
//
//  Created by User on 11/24/23.
//
import CoreML
import SwiftUI
import UIKit
import Vision
import SwiftyJSON
import Contacts
import Foundation
import SwiftUI
// Class managing global variables
class DataManager: ObservableObject {
	static let shared = DataManager()
	@Published var bracketBoxDuplex: String = ""
	@Published var gfci: String = ""
	@Published var cutin: String = ""
	@Published var surfaceMounted: String = ""
	@Published var controlled: String = ""
	@Published var scaled: String = ""
	@Published var quadBracketBox: String = ""
	@Published var quadGFCI: String = ""
	@Published var quadCutIn: String = ""
	@Published var quadSurfaceMounted: String = ""
	@Published var quadControlled: String = ""
	@Published var employeeNames: [String] = []
	@Published var boxTotal: String = ""

	
	@Published var wire3FurnitureFeed: String = ""
	@Published var wire2FurnitureFeed: String = ""
	@Published var bracketBoxData: String = ""
	@Published var cutInData: String = ""
	
	@Published var homerunLength: String = "" {
		didSet {
			calculateMCTotal()
		}
	}
	
	@Published var homerunQuantity: String = "" {
		didSet {
			calculateMCTotal()
		}
	}
	@Published var mcTotal: String = ""
	
	@Published var lineVoltageDimmingSwitch: String = ""
	@Published var lineVoltageDimmingCutin: String = ""
	
	@Published var lvCat5Switch: String = ""
	@Published var lvCat5Cutin: String = ""
	
	@Published var lineVoltageSwitch: String = ""
	@Published var lineVoltageCutIn: String = ""
	
	@Published var twoGangSwitch: String = ""
	@Published var twoGangCutinSwitch: String = ""
	@Published var lvTwoGangSwitch: String = ""
	@Published var lvTwoGangCutinSwitch: String = ""

	@Published var inFloorDevice: String = ""
	@Published var in6FloorDevice: String = ""
	@Published var singlePole277V40AInstahot: String = ""
	@Published var pole208V40AInstahot: String = ""
	@Published var singlePole277V30AInstahot: String = ""
	
	
	
	
	


	// Published variables storing various data
	@Published var selectedJobID: String = ""
	@Published var selectedJobName: String = ""
	@Published var allSMSs: String = ""
	@Published var allSMSBodies: [String] = []
	@Published var employeeData: [String: String] = [:]
	@Published var isDarkMode: Bool
	@Published var persistentMode: Bool = UserDefaults.standard.bool(forKey: "persistentMode") // Retrieve persistent mode status
	@Published var selectedTime: Date {
		didSet {
			UserDefaults.standard.set(selectedTime, forKey: "selectedTime")
		}
	}
	@Published var jsonBodiesLocal: [(id: UUID, jsonBody: [String: Any])] = []

	@Published var jsonBodies: [(id: UUID, jsonBody: [String: Any])] = []
	@Published var alarmNoise: String = "customAlarm-2.mp3"
	@Published var selectedContacts: [CNContact] = []
	@Published var isAlarmSet: Bool = UserDefaults.standard.bool(forKey: "isAlarmSet")
	@Published var themeColor: Color = .blue // Default theme colo
	init() {
		self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
		//         self.selectedContact = DataManager.loadContact()
		//         self.selectedPhoneNumber = DataManager.loadPhoneNumber()
//		self.selectedTime = UserDefaults.standard.object(forKey: "selectedTime") as? Date ?? Date()
		if let savedTime = UserDefaults.standard.object(forKey: "selectedTime") as? Date {
			// If selectedTime has a value, set isAlarmSet to true and schedule the alarm
			self.selectedTime = savedTime
			self.isAlarmSet = true
			print("in if statement")
			scheduleAlarm(at: selectedTime, soundName: alarmNoise)
		} else {
			print("in else statement")
			persistentMode = false
			self.persistentMode = false
			UserDefaults.standard.set(false, forKey: "persistentMode")
			self.isAlarmSet = false
			isAlarmSet = false
			UserDefaults.standard.set(false, forKey: "isAlarmSet")
			UserDefaults.standard.synchronize()
			self.selectedTime = Date()
			cancelAlarm()
		}
		
		self.selectedContacts = retrieveSelectedContacts()
		

	}
	func updateDarkMode(colorScheme: ColorScheme) {
		if colorScheme == .dark {
			isDarkMode = true
		} else {
			isDarkMode = false
		}
	}
	// Dictionary to hold employee hours data
	func calculateTotal() {
		let bracketBoxDuplexInt = Int(bracketBoxDuplex) ?? 0
		let gfciInt = Int(gfci) ?? 0
		let cutinInt = Int(cutin) ?? 0
		let surfaceMountedInt = Int(surfaceMounted) ?? 0
		let controlledInt = Int(controlled) ?? 0
		
		let total = bracketBoxDuplexInt + gfciInt + cutinInt + surfaceMountedInt + controlledInt
		
		boxTotal = String(total)
	}
	// Method to set hours for a given employee name
	func saveEmployeeHours(name: String, hours: String) {
		employeeData[name] = hours
	}

	// Method to get hours for a given employee name from the dictionary
	func hoursForEmployee(_ employeeName: String) -> String {
		return employeeData[employeeName] ?? ""
	}
	func clearEmployeeHours() {
		employeeData = [:]
		dataManager.selectedJobID = ""
	}
	func calculateMCTotal() {
		if let homerunLengthInt = Int(homerunLength), let homerunQuantityInt = Int(homerunQuantity) {
			let mcTotalInt = homerunQuantityInt * (homerunLengthInt / 2)
			mcTotal = String(mcTotalInt)
		} else {
			// Handle conversion error here
			mcTotal = "Error: Invalid input"
		}
	}
	func scheduleAlarm(at time: Date, soundName: String) {
		print("daily alarm function")
		print("isAlarmSet: \(isAlarmSet)")

		print(#function)
		if isAlarmSet {
		let center = UNUserNotificationCenter.current()
		UserDefaults.standard.set(time, forKey: "selectedTime")
		let content = UNMutableNotificationContent()
		content.title = "Turn In Time!!"
	content.body = "It's time to turn in time!"
		content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundName))
		let calendar = Calendar.current
		let nowComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
		let now = calendar.date(from: nowComponents)!
		let scheduledTimeComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: time)
		var scheduledTime = calendar.date(from: scheduledTimeComponents)!

		if now > scheduledTime {
			// If the time has already passed for today, schedule for the next day
			scheduledTime = calendar.date(byAdding: .day, value: 1, to: scheduledTime)!
		}

		let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.hour, .minute], from: scheduledTime), repeats: true)

		let request = UNNotificationRequest(identifier: "dailyAlarm", content: content, trigger: trigger)

		center.add(request) { error in
			if let error = error {
				print("Error scheduling daily notification: \(error.localizedDescription)")
			} else {
				print("dailyAlarm scheduled for \(dataManager.selectedTime)")
			}
		}
			UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
				for request in requests {
					if request.identifier == "dailyAlarm" {
						print("dailyAlarm has been verified as activated")
					}

				}
			}
		}
	}
	func clearSMS() {
		dataManager.allSMSBodies.removeLast()

	}
	
	func persistentAlarm(soundName: String) {
		print("persistent alarm function")
		print("isAlarmSet: \(isAlarmSet)")

		if isAlarmSet {
			let center = UNUserNotificationCenter.current()

			let content = UNMutableNotificationContent()
			content.title = "WARNING!!"
			content.body = "Alarm will continue until you turn your time in!"
			content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundName))
			let calendar = Calendar.current
			let nowComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
			let now = calendar.date(from: nowComponents)!
			let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)

			let request = UNNotificationRequest(identifier: "persistentAlarm", content: content, trigger: trigger)

			center.add(request) { error in
				if let error = error {
					print("Error scheduling persistent notification: \(error.localizedDescription)")
				} else {
					print("Persistent notification scheduled successfully, starting at \(now)")
				}
			}

			UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
				for request in requests {
					if request.identifier == "persistentAlarm" {
						print("persistentAlarm has been verified as activated")
					}

				}
			}
		}
	}
	func stopPersistentAlarm() {
		UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["persistentAlarm"])
		print("cancel persistence alarm")
	}
	func cancelAlarm() {
		UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
		UserDefaults.standard.set(false, forKey: "isAlarmSet")
		UserDefaults.standard.synchronize()
		print("cancel all alarms")
	}
	func fetchEmployeeNames() {
		guard let url = URL(string: "https://api.antflix.net/get_employees") else {
			print("Invalid URL")
			return
		}

		URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
			if let data = data {
				let json = JSON(data)
				var names: [String] = []
				for (key, _) in json {
					names.append(key)
				}
				// Sort the names if needed.
				names.sort()

				DispatchQueue.main.async {
					// Updatde employeeNames on the main thread.
					self?.employeeNames = names
				}
			} else if let error = error {
				print("Error fetching employees: \(error.localizedDescription)")
			}
		}.resume()
	}

	// Array holding employee names

	func clearAllSMSData() {
		allSMSs = "" // Clear the string
		allSMSBodies = [] // Clear the array

	}


	func saveSelectedContacts() {
		let contactIdentifiers = self.selectedContacts.map { $0.identifier }
		UserDefaults.standard.set(contactIdentifiers, forKey: "selectedContactsKey")
	}
	func retrieveSelectedContacts() -> [CNContact] {
		print("retrieved contacts called")
		guard let identifiers = UserDefaults.standard.object(forKey: "selectedContactsKey") as? [String] else {
			return []
		}
		
		let store = CNContactStore()
		var contacts: [CNContact] = []
		
		// Request access to the contact store
		let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
		guard authorizationStatus == .authorized else {
			// Handle lack of permissions here
			print("Not authorized to access contacts")
			return []
		}
		
		// Use predicates to fetch contacts in batches
		let predicate = CNContact.predicateForContacts(withIdentifiers: identifiers)
		let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
		
		do {
			contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
		} catch {
			print("Error fetching contacts: \(error)")
		}
		
		return contacts
	}

	let deviceCategories: [String: [String]] = [
		"Single Gang Category": ["Standard Bracket Box", "GFCI","Cut-In",
								 "Surface Mounted",
								 "Controlled",
								 "Scaled" ],
		"Two Gang Category": ["Quad Bracket Box",
							  "Quad GFCI",
							  "Quad Cut-in",
							  "Quad Surface Mounted",
							  "Quad Controlled"],
		"Switches": ["Line-Voltage Dimming Switch",
					 "Line-Voltage Dimming Cut-in",
					 "LV/Cat5 Switch",
					 "LV/Cat5 Cut-in",
					 "Line-Voltage Switch",
					 "Line-Voltage Cut-in",
					 "2-Gang Switch",
					 "2-Gang Cut-In Switch",
					 "2-Gang LV/Cat5 Switch",
					 "2-Gang LV/Cat5 Cut-In Switch"
		],
		"Miscilaneous": ["3wire Furniture Feed",
						 "4wire Furniture Feed",
						 "Bracket Box Data",
						 "Homerun Quantity",
						 "Longest HR Length",
						 "Cut-in Data",
						 "6in Floor Device",
						 "4in Floor Device",
						 "Single-Pole 277V 40A Instahot",
						 "2-Pole 208V 40A Instahot",
						 "Single-Pole 277V 30A Instahot"
			
		]
		// Add other categories
	]
	@Published var allMaterials: [String] = ["Single Gang Mud Ring",
								  "Two Gang Mud Ring",
								  "4-Square Bracket Box",
								  "Deep 4-Square Bracket Box",
								  "4-Square Box",
								  "Deep 4-Square Box",
								  "4-Square Cover",
								  "Cut-In Box",
								  "Drywall Clamps",
								  "NVent Caddy Mounting Slider Bracket",
								  "12/2 LV MC",
								  "12/3 LV MC",
								  "12/2 HV MC",
								  "12/3 HV MC",
								  "10/2 HV MC",
								  "8/3 LV MC",
								  "18/2 LV Dimmer Cable",
								  "Single Barrel MC Connector",
								  "Double Barrel MC Connector",
								  "Ground Stinger",
								  "Tek Screws",
								  "1/2\" Panhead Selftapper",
								  "Mac-2 Straps",
								  "Red Heads",
								  "Red/Yellow Wire Nuts",
								  "Blue/Orange Wire Nuts",
								  "Big Blue Wire Nuts",
								  "Jet Line",
								  "3/4” Snap-In Bushings",
								  "1\" Snap-In Bushings",
								  "Single Gang LV1s",
								  "10ft Pieces of 2\" EMT **May need adjusting per floor device specs**",
								  "2\" EMT Coupling **May need adjusting per floor device specs**",
								  "2\" EMT to Flex Change Over **May need adjusting per floor device specs**",
								  "2\" 90° Elbow **May need adjusting per floor device specs**",
								  "10ft Pieces of 2\" Flex **May need adjusting per floor device specs**",
								  "2\" Insulating Push On Conduit Bushing **May need adjusting per floor device specs**",
								  "2\" Min Strap **May need adjusting per floor device specs**",
								  "Tube of Fire Cock **May need adjusting per floor device specs**",
								  "1/4\" Toggle Bolts",
								  "1/2\" EMT",
								  "1/2\" EMT Connectors",
								  "1/2\" One Hole Strap",
								  "#12 THHN Black Wire",
								  "#12 THHN White Wire",
								  "#12 THHN Green Wire",
								  "Standard Outlet",
								  "Decora Outlet",
								  "GFCI Outlet",
								  "Half-Duplex Controlled Standard Outlet",
								  "Half-Duplex Controlled Decora Outlet",
								  "Full-Duplex Controlled Standard Outlet",
								  "Full-Duplex Controlled Decora Outlet",
								  "Single-Pole Motor Rated 30A Switch",
								  "Two-Pole Motor Rated 40A Switch",
								  "Single Gang Standard Outlet Cover Plate",
								  "Single Gang Decora Outlet Cover Plate",
								  "Two Gang Standard Outlet Cover Plate",
								  "Two Gang Decora Outlet Cover Plate",
								  "4-Square Industrial Switch Cover Plate",
								  "Single Gang Standard Industrial Cover Plug Plate",
								  "Single Gang Decora Industrial Cover Plug Plate",
								  "2 Gang Standard Industrial Cover Plug Plate",
								  "2 Gang Decora Industrial Cover Plug Plate",
								  "3/4\" MC Connector",
								  "Two Gang Stainless Steel Blank Plate",
								  "90 Degree 1/2\" Flex Connector",
								  "4\" Floor Device ***Per Print***",
								  "6\" Floor Device ***Per Print***",
								  "Floor Device to Flex Converter ***Per Print***",
								  "Multifunction Clip w/ nut or bolt",
								  "KX Straps",
								  "Ceiling Wires"]
		static let defaultMaterialRequirements: [String: [String: Int]] = [
			"Standard Bracket Box": [
				"4-Square Bracket Box": 1,
				"Single Gang Mud Ring": 1,
				"Ground Stinger": 1,
				"Tek Screws": 7,
				"Mac-2 Straps": 4,
				"Red/Yellow Wire Nuts": 3,
				"Red Heads": 2,
				"Double Barrel MC Connector": 1,
				"12/2 LV MC": 35,
				"Outlet": 1,//need to add outlet type
				"Single Gang Outlet Cover Plate": 1,//need to add outlet type
//				"KX Straps": 2,
//				"Ceiling Wire": 2
			],
			"GFCI": [
				"4-Square Bracket Box": 1,
				"Single Gang Mud Ring": 1,
				"Ground Stinger": 1,
				"Tek Screws": 10,
				"Mac-2 Straps": 4,
				"Red/Yellow Wire Nuts": 1,
				"Red Heads": 2,
				"Single Barrel MC Connector": 1,
				"NVent Caddy Mounting Slider Bracket": 1,
				"12/2 LV MC": 30,
				"GFCI Outlet": 1,
//				"KX Straps": 2,
			],
			"Cut-In"  : [
				"Ground Stinger": 1,
				"Tek Screws": 10,
				"Mac-2 Straps": 4,
				"Red/Yellow Wire Nuts": 1,
				"Red Heads": 2,
				"Single Barrel MC Connector": 1,
				"12/2 LV MC": 30,
				"KX Straps": 2,
				"Outlet": 1, //need to add outlet type
				"Single Gang Outlet Cover Plate": 1,// need to add outlet type
				"Cut-In Box": 1,
				"Drywall Clamps": 1,
				"4-Square Bracket Box": 1,
			],
			"Surface Mounted": [
				"4-Square Box": 2,
				"Single Gang Industrial Cover Plug Plate": 1,//need to add outlet type
				"4-Square Cover": 1,
				"Ground Stinger": 2,
				"1/4” Toggle Bolts": 6,
				"1/2\" EMT": 10,
				"1/2\" EMT Connectors": 2,
				"1/2\" One Hole Strap": 2,
				"Double Barrel MC Connector": 2,
				"Red Heads": 2 ,
				"Red/Yellow Wire Nuts": 6,
				"Mac-2 Straps": 1,
				"KX Straps": 2,
				"#12 THHN Black Wire": 15,
				"#12 THHN White Wire": 15,
				"#12 THHN Green Wire": 15,
				"Outlet": 1,//need to add outlet type
			],

			"Controlled": [
				"Deep 4-Square Bracket Box": 2,
				"Single Gang Mud Ring": 1,
				"Ground Stinger": 2,
				"Tek Screws": 10,
				"Mac-2 Straps": 3,
				"Red/Yellow Wire Nuts": 4,
				"Red Heads": 2,
				"Double Barrel MC Connector": 1,
				"Single Barrel MC Connector": 2,
				"NVent Caddy Mounting Slider Bracket": 2,
				"12/3 LV MC": 35,
				"Half-Duplex Controlled Outlet": 1,//need to add outlet type
				"Single Gang Outlet Cover Plate": 1//need to add outlet type
			],
			"Scaled": [
				"NVent Caddy Mounting Slider Bracket": 1,
				"Tek Screws": 4,
			],
			"Quad Bracket Box": [
				"4-Square Bracket Box": 1,
				"Single Gang Mud Ring": 1,
				"Ground Stinger": 1,
				"Tek Screws": 10,
				"Mac-2 Straps": 4,
				"Red/Yellow Wire Nuts": 1,
				"Red Heads": 2,
				"Double Barrel MC Connector": 1,
				"12/2 LV MC": 30,
				"Outlet": 2, //need to add outlet type
				"Two Gang Outlet Cover Plate": 1,//need to add outlet type
//				"KX Straps": 2,

			],
			"Quad GFCI": [
				"4-Square Bracket Box": 1,
				"Single Gang Mud Ring": 1,
				"Ground Stinger": 1,
				"Tek Screws": 10,
				"Mac-2 Straps": 4,
				"Red/Yellow Wire Nuts": 1,
				"Red Heads": 2,
				"Double Barrel MC Connector": 1,
				"NVent Caddy Mounting Slider Bracket": 1,
				"12/2 LV MC": 30,
				"GFCI Outlet": 2,
				"Two Gang Decora Outlet Cover Plate": 1, //need to add outlet type
//				"KX Straps": 2
			],
			"Homerun Quantity": [
				"Deep 4-Square Bracket Box": 1,
				"Ground Stinger": 1,
				"Double Barrel MC Connector": 2,
				"Single Barrel MC Connector": 2,
				"Tek Screws": 5,
				"Red Heads": 2,
				"Red/Yellow Wire Nuts": 1,
				"4-Square Cover": 1,
				"Mac-2 Straps": 4,
				"Ceiling Wires": 1,
				"KX Straps": 2,
			],

			"Quad Cut-in"  : [
				
				"Ground Stinger": 1,
				"Mac-2 Straps": 4,
				"Red/Yellow Wire Nuts": 1,
				"Red Heads": 2,
				"Double Barrel MC Connector": 1,
				"Single Barrel MC Connector": 2,
				"12/2 LV MC": 30,
				"KX Straps": 2,
				"Outlet": 2,//need to add outlet type
				"Two Gang Outlet Cover Plate": 1,//need to add outlet type
				"Cut-In Box": 2,
				"Drywall Clamps": 1
			],
			"Quad Surface Mounted" :[
				
				"4-Square Box": 2,
				"2 Gang Industrial Cover Plug Plate": 1,//need to add outlet type
				"4-Square Cover": 1,
				"Ground Stinger": 2,
				"1/4” Toggle Bolts": 6,
				"1/2\" EMT": 10,
				"1/2\" EMT Connectors": 2,
				"1/2\" One Hole Strap": 2,
				"Double Barrel MC Connector": 2,
				"Red Heads": 2 ,
				"Red/Yellow Wire Nuts": 6,
				"KX Straps": 2,
				"#12 THHN Black Wire": 15,
				"#12 THHN White Wire": 15,
				"#12 THHN Green Wire": 15,
				"Outlet": 2,//need to add outlet type
			],
			"Quad Controlled": [
				
				"Deep 4-Square Bracket Box": 2,
				"Two Gang Mud Ring": 1,
				"Ground Stinger": 1,
				"Tek Screws": 10,
				"Mac-2 Straps": 4,
				"Red/Yellow Wire Nuts": 5,
				"Red Heads": 4,
				"Double Barrel MC Connector": 1,
				"NVent Caddy Mounting Slider Bracket": 3,
				"Outlet": 1,//need to add outlet type
				"12/3 LV MC": 35,
				"Full-Duplex Controlled Outlet": 1,//need to add outlet type
				"Two Gang Outlet Cover Plate": 1//need to add outlet type
				
			],
			"3wire Furniture Feed": [
				
				"4-Square Bracket Box": 1,
				"Two Gang Mud Ring": 1,
				"Ground Stinger": 1,
				"Tek Screws": 10,
				"Mac-2 Straps": 4,
				"Red/Yellow Wire Nuts": 8,
				"Red Heads": 1,
				"Single Barrel MC Connector": 1,
				"12/3 LV MC": 30,
				"Two Gang Stainless Steel Blank Plate": 1,
				"90 Degree 1/2\" Flex Connector": 1,
			],
			"4wire Furniture Feed": [
				
				"4-Square Bracket Box": 1,
				"Two Gang Mud Ring": 1,
				"Ground Stinger": 1,
				"Tek Screws": 10,
				"Mac-2 Straps": 4,
				"Red/Yellow Wire Nuts": 8,
				"Red Heads": 4,
				"Double Barrel MC Connector": 2,
				"12/3 LV MC": 30,
				"Two Gang Stainless Steel Blank Plate": 1,
				"90 Degree 1/2\" Flex Connector": 1,
				"NVent Caddy Mounting Slider Bracket": 1,
			],
			"Bracket Box Data": [
				
				"4-Square Bracket Box": 1,
				"Single Gang Mud Ring": 1,
				"Tek Screws": 4,
				"Jet Line": 10,
				"3/4” Snap-In Bushings": 1,
				"1\" Snap-In Bushings": 1,
			],
			"Cut-in Data": [
				
				"LV1s": 1,
				"Jet Line": 10,
			],
			"Line-Voltage Dimming Switch": [
				
				"12/3 HV MC": 10,
				"Ground Stinger": 1,
				"Single Barrel MC Connector": 1,
				"Deep 4-Square Bracket Box": 1,
				"Double Barrel MC Connector": 2,
				"Red Heads": 5,
				"Red/Yellow Wire Nuts": 8,
				"18/2 LV Dimmer Cable": 15,
				"Blue/Orange Wire Nuts": 2,
				"4-Square Cover": 1,
				"Cut-In Box": 1,
				"Drywall Clamps": 1
			],
			"Line-Voltage Dimming Cut-In": [
				
				"4-Square Bracket Box": 1,
				"Single Gang Mud Ring": 1,
				"12/3 HV MC": 10,
				"Mac-2 Straps": 3,
				"Ground Stinger": 1,
				"Single Barrel MC Connector": 1,
				"Deep 4-Square Bracket Box": 1,
				"Double Barrel MC Connector": 2,
				"Red Heads": 1,
				"Tek Screws": 6,
				"Red/Yellow Wire Nuts": 3,
				"18/2 LV Dimmer Cable": 15,
				"Blue/Orange Wire Nuts": 2,
			],
			"LV/Cat5 Switch": [
				
				"4-Square Bracket Box": 1,
				"Single Gang Mud Ring": 1,
				"Jet Line": 10,
				"3/4” Snap-In Bushings": 1,
				"Deep 4-Square Bracket Box": 1,
				"Double Barrel MC Connector": 2,
				"Tek Screws": 6,
				"KX Straps": 4,
				"4-Square Cover": 1,
				"Ground Stinger": 1,
				"Red/Yellow Wire Nuts": 1,
				"12/2 HV MC": 15,
				"Ceiling Wires": 1,
			],
			"Lv/Cat5 Cut-in": [
				
				"Jet Line": 10,
				"LV1s": 1,
				"Deep 4-Square Bracket Box": 1,
				"Double Barrel MC Connector": 2,
				"Tek Screws": 3,
				"KX Straps": 4,
				"4-Square Cover": 1,
				"Ground Stinger": 1,
				"Red/Yellow Wire Nuts": 5,
				"12/2 HV MC": 15,
				"Ceiling Wires": 1,
			],
			"Line-Voltage Switch": [
				
				"4-Square Bracket Box": 1,
				"Single Gang Mud Ring": 1,
				"12/3 HV MC": 10,
				"Mac-2 Straps": 3,
				"Ground Stinger": 2,
				"Deep 4-Square Bracket Box": 1,
				"Double Barrel MC Connector": 2,
				"Single Barrel MC Connector": 1,
				"Red Heads": 1,
				"Tek Screws": 6,
				"Red/Yellow Wire Nuts": 3,
				
			],
			"Line-Voltage Cut-in": [
				"12/3 HV MC": 10,
				"Ground Stinger": 2,
				"Deep 4-Square Bracket Box": 1,
				"4-Square Cover": 1,
				"Double Barrel MC Connector": 2,
				"Single Barrel MC Connector": 1,
				"Red Heads": 5,
				"Red/Yellow Wire Nuts": 8,
				"Cut-In Box": 1,
				"Drywall Clamps": 1
			],
			"2-Gang Switch": [
				"4-Square Bracket Box": 2,
				"Two Gang Mud Ring": 1,
				"12/3 HV MC": 20,
				"Mac-2 Straps": 3,
				"Ground Stinger": 4,
				"Deep 4-Square Bracket Box": 2,
				"Double Barrel MC Connector": 4,
				"Single Barrel MC Connector": 2,
				"Red Heads": 6,
				"Tek Screws": 12,
				"Red/Yellow Wire Nuts": 9,
				

			],
			"2-Gang Cut-In Switch": [
				"12/4 HV MC": 20,
				"Ground Stinger": 2,
				"Deep 4-Square Bracket Box": 2,
				"4-Square Cover": 2,
				"Double Barrel MC Connector": 4,
				"Single Barrel MC Connector": 4,
				"Red Heads": 10,
				"Red/Yellow Wire Nuts": 16,
				"Cut-In Box": 2,
				"Drywall Clamps": 2
			],
			"2-Gang LV/Cat5 Switch": [
				"4-Square Bracket Box": 2,
				"Two Gang Mud Ring": 1,
				"Jet Line": 10,
				"3/4” Snap-In Bushings": 1,
				"Deep 4-Square Bracket Box": 1,
				"Double Barrel MC Connector": 4,
				"Tek Screws": 12,
				"KX Straps": 8,
				"4-Square Cover": 2,
				"Ground Stinger": 1,
				"Red/Yellow Wire Nuts": 2,
				"12/2 HV MC": 30,
				"Ceiling Wires": 2,
			],
			"2-Gang LV/Cat5 Cut-In Switch": [
				"Jet Line": 20,
				"LV2s": 1,
				"Deep 4-Square Bracket Box": 2,
				"Double Barrel MC Connector": 4,
				"Tek Screws": 6,
				"KX Straps": 4,
				"4-Square Cover": 2,
				"Ground Stinger": 2,
				"Red/Yellow Wire Nuts": 10,
				"12/2 HV MC": 30,
				"Ceiling Wires": 2,
			],
			"6in Floor Device": [
				"10ft Pices of 2\" EMT **May need adjusting per floor device specs**": 1,
				"2\" EMT Coupling **May need adjusting per floor device specs**": 1,
				"2\" EMT to Flex Change Over **May need adjusting per floor device specs**": 2,
				"2\" 90° Elbow **May need adjusting per floor device specs**": 1,
				"10ft Pieces of 2\" Flex **May need adjusting per floor device specs**": 1,
				"2\" Insulating Push On Conduit Bushing **May need adjusting per floor device specs**": 1,
				"2\" Min Strap **May need adjusting per floor device specs**": 5,
				"Tube of Fire Cock **May need adjusting per floor device specs**": 1,
				"Jet Line": 30,
				"Multifuction Clip w/ nut or bolt": 2,
				"6\" Floor Device ***Per Print***": 1,
				"Floor Device to Flex Converter ***Per Print***": 10,
				"1/2\" Panhead Selftapper": 5,
				"Mac-2 Straps": 3,
				"Red/Yellow Wire Nuts": 8,
				"Red Heads": 2,
				"Single Barrel MC Connector": 2,
				"12/2 LV MC": 30,
				"4-Square Bracket Box": 1,
				"4-Square Cover": 1,
				"KX Straps": 5,
				
			],
			"4in Floor Device": [
				
				"Tube of Fire Cock **May need adjusting per floor device specs**": 1,
				"4\" Floor Device ***Per Print***": 1,
				"Mac-2 Straps": 3,
				"Red/Yellow Wire Nuts": 8,
				"Red Heads": 2,
				"Single Barrel MC Connector": 2,
				"12/2 LV MC": 30,
				"4-Square Bracket Box": 1,
				"4-Square Cover": 1,
				"KX Straps": 5,
			],
			"Single-Pole 277V 40A Instahot": [
				"3/4\" MC Connector": 4,
				"Deep 4-Square Box": 1,
				"4-Square Industrial Switch Cover Plate": 1,
				"1/2\" One Hole Strap": 3,
				"Big Blue Wire Nuts": 4,
				"Single-Pole Motor Rated 30A Switch": 1,
				"8/2 HV MC": 30,
			],
			"Single-Pole 277V 30A Instahot": [
				"3/4\" MC Connector": 4,
				"Deep 4-Square Box": 1,
				"4-Square Industrial Switch Cover Plate": 1,
				"1/2\" One Hole Strap": 3,
				"Big Blue Wire Nuts": 4,
				"Single-Pole Motor Rated 30A Switch": 1,
				"10/2 HV MC": 30,
			],
			"2-pole 208V 40A Instahot": [
				"3/4\" MC Connector": 4,
				"Deep 4-Square Box": 1,
				"4-Square Industrial Switch Cover Plate": 1,
				"1/2\" One Hole Strap": 3,
				"Big Blue Wire Nuts": 4,
				"Two-Pole Motor Rated 40A Switch": 1,
				"8/3 LV MC": 30,
			]
		]
	@Published var materialKeys:[String: [String]] = [
		"Standard Bracket Box": [
			"4-Square Bracket Box",
			"Single Gang Mud Ring",
			"Ground Stinger",
			"Tek Screws",
			"Mac-2 Straps",
			"Red/Yellow Wire Nuts",
			"Red Heads",
			"Double Barrel MC Connector",
			"12/2 LV MC",
			"KX Straps",
			"Outlet",
			"Single Gang Outlet Cover Plate"
		],
		"GFCI": [
			"4-Square Bracket Box",
			"Single Gang Mud Ring",
			"Ground Stinger",
			"Tek Screws",
			"Mac-2 Straps",
			"Red/Yellow Wire Nuts",
			"Red Heads",
			"Single Barrel MC Connector",
			"NVent Caddy Mounting Slider Bracket",
			"12/2 LV MC",
			"KX Straps",
			"GFCI Outlet"
		],
		"Cut-In": [
			"4-Square Bracket Box",
			"Ground Stinger",
			"Tek Screws",
			"Mac-2 Straps",
			"Red/Yellow Wire Nuts",
			"Red Heads",
			"Single Barrel MC Connector",
			"NVent Caddy Mounting Slider Bracket",
			"12/2 LV MC",
			"KX Straps",
			"Outlet",
			"Single Gang Outlet Cover Plate",
			"Cut-In Box",
			"Drywall Clamps"
		],
		"Surface Mounted": [
			"4-Square Box",
			"Single Gang Industrial Cover Plug Plate",
			"4-Square Cover",
			"Ground Stinger",
			"1/4” Toggle Bolts",
			"1/2\" EMT",
			"1/2\" EMT Connectors",
			"1/2\" One Hole Strap",
			"Double Barrel MC Connector",
			"Red Heads",
			"Red/Yellow Wire Nuts",
			"Mac-2 Straps",
			"KX Straps",
			"#12 THHN Black Wire",
			"#12 THHN White Wire",
			"#12 THHN Green Wire",
			"Outlet"
		],
		"Controlled": [
			"Deep 4-Square Bracket Box",
			"Single Gang Mud Ring",
			"Ground Stinger",
			"Tek Screws",
			"Mac-2 Straps",
			"Red/Yellow Wire Nuts",
			"Red Heads",
			"Double Barrel MC Connector",
			"Single Barrel MC Connector",
			"NVent Caddy Mounting Slider Bracket",
			"12/2 LV MC",
			"12/3 LV MC",
			"Half-Duplex Controlled Outlet",
			"Single Gang Outlet Cover Plate"
		],
		"Scaled": [
			"NVent Caddy Mounting Slider Bracket",
			"Tek Screws"
		],
		"Quad Bracket Box": [
			"4-Square Bracket Box",
			"Single Gang Mud Ring",
			"Ground Stinger",
			"Tek Screws",
			"Mac-2 Straps",
			"Red/Yellow Wire Nuts",
			"Red Heads",
			"Double Barrel MC Connector",
			"12/2 LV MC",
			"KX Straps",
			"Outlet",
			"Two Gang Outlet Cover Plate"
		],
		"Quad GFCI": [
			"4-Square Bracket Box",
			"Single Gang Mud Ring",
			"Ground Stinger",
			"Tek Screws",
			"Mac-2 Straps",
			"Red/Yellow Wire Nuts",
			"Red Heads",
			"Double Barrel MC Connector",
			"NVent Caddy Mounting Slider Bracket",
			"12/2 LV MC",
			"KX Straps",
			"GFCI Outlet",
			"Two Gang Outlet Cover Plate"
		],
		"Quad Cut-in": [
			"Ground Stinger",
			"Mac-2 Straps",
			"Red/Yellow Wire Nuts",
			"Red Heads",
			"Double Barrel MC Connector",
			"Single Barrel MC Connector",
			"12/2 LV MC",
			"KX Straps",
			"Outlet",
			"Two Gang Outlet Cover Plate",
			"Cut-In Box",
			"Drywall Clamps"
		],
		"Quad Surface Mounted": [
			"4-Square Box",
			"2 Gang Industrial Cover Plug Plate",
			"4-Square Cover",
			"Ground Stinger",
			"1/4” Toggle Bolts",
			"1/2\" EMT",
			"1/2\" EMT Connectors",
			"1/2\" One Hole Strap",
			"Double Barrel MC Connector",
			"Red Heads",
			"Red/Yellow Wire Nuts",
			"KX Straps",
			"#12 THHN Black Wire",
			"#12 THHN White Wire",
			"#12 THHN Green Wire",
			"Outlet"
		],
		"Quad Controlled": [
			"Deep 4-Square Bracket Box",
			"Two Gang Mud Ring",
			"Ground Stinger",
			"Tek Screws",
			"Mac-2 Straps",
			"Red/Yellow Wire Nuts",
			"Red Heads",
			"Double Barrel MC Connector",
			"Single Barrel MC Connector",
			"NVent Caddy Mounting Slider Bracket",
			"12/2 LV MC",
			"12/3 LV MC",
			"Full-Duplex Controlled Outlet",
			"Single Gang Outlet Cover Plate"
		],
		"3wire Furniture Feed": [
			
			"4-Square Bracket Box",
			"Two Gang Mud Ring",
			"Ground Stinger",
			"Tek Screws",
			"Mac-2 Straps",
			"Red/Yellow Wire Nuts",
			"Red Heads",
			"Single Barrel MC Connector",
			"12/3 LV MC",
			"Two Gang Stainless Steel Blank Plate",
			"90 Degree 1/2\" Flex Connector"
		],
		"4wire Furniture Feed": [
			
			"4-Square Bracket Box",
			"Two Gang Mud Ring",
			"Ground Stinger",
			"Tek Screws",
			"Mac-2 Straps",
			"Red/Yellow Wire Nuts",
			"Red Heads",
			"Double Barrel MC Connector",
			"12/3 LV MC",
			"Two Gang Stainless Steel Blank Plate",
			"90 Degree 1/2\" Flex Connector",
			"NVent Caddy Mounting Slider Bracket"
		],
		"Bracket Box Data": [
			"4-Square Bracket Box",
			"Single Gang Mud Ring",
			"Tek Screws",
			"Jet Line",
			"3/4” Snap-In Bushings",
			"1\" Snap-In Bushings"
		],
		"Cut-in Data": [
			"LV1s",
			"Jet Line"
		],
		"Line-Voltage Dimming Switch": [
			"12/3 HV MC",
			"Ground Stinger",
			"Single Barrel MC Connector",
			"Deep 4-Square Bracket Box",
			"Double Barrel MC Connector",
			"Red Heads",
			"Red/Yellow Wire Nuts",
			"18/2 LV Dimmer Cable",
			"Blue/Orange Wire Nuts",
			"4-Square Cover",
			"Cut-In Box",
			"Drywall Clamps"
		],
		"Line-Voltage Dimming Cut-In": [
			"4-Square Bracket Box",
			"Single Gang Mud Ring",
			"12/3 HV MC",
			"Mac-2 Straps",
			"Ground Stinger",
			"Single Barrel MC Connector",
			"Deep 4-Square Bracket Box",
			"Double Barrel MC Connector",
			"Red Heads",
			"Tek Screws",
			"Red/Yellow Wire Nuts",
			"18/2 LV Dimmer Cable",
			"Blue/Orange Wire Nuts"
		],
		"LV/Cat5 Switch": [
			"4-Square Bracket Box",
			"Single Gang Mud Ring",
			"Jet Line",
			"3/4” Snap-In Bushings",
			"Deep 4-Square Bracket Box",
			"Double Barrel MC Connector",
			"Tek Screws",
			"KX Straps",
			"4-Square Cover",
			"Ground Stinger",
			"Red/Yellow Wire Nuts",
			"12/2 HV MC",
			"Ceiling Wires"
		],
		"Lv/Cat5 Cut-in": [
			"Jet Line",
			"LV1s",
			"Deep 4-Square Bracket Box",
			"Double Barrel MC Connector",
			"Tek Screws",
			"KX Straps",
			"4-Square Cover",
			"Ground Stinger",
			"Red/Yellow Wire Nuts",
			"12/2 HV MC",
			"Ceiling Wires"
		],
		"Line-Voltage Switch": [
			"4-Square Bracket Box",
			"Single Gang Mud Ring",
			"12/3 HV MC",
			"Mac-2 Straps",
			"Ground Stinger",
			"Deep 4-Square Bracket Box",
			"Double Barrel MC Connector",
			"Single Barrel MC Connector",
			"Red Heads",
			"Tek Screws",
			"Red/Yellow Wire Nuts"
		],
		"Line-Voltage Cut-in": [
			"12/3 HV MC",
			"Ground Stinger",
			"Deep 4-Square Bracket Box",
			"4-Square Cover",
			"Double Barrel MC Connector",
			"Single Barrel MC Connector",
			"Red Heads",
			"Red/Yellow Wire Nuts",
			"Cut-In Box",
			"Drywall Clamp"
		],
		"2-Gang Switch": [
			"Two Gang Mud Ring"
		],
		"2-Gang Cut-In Switch": [
			"Cut-In Box"
		],
		"6in Floor Device": [
			"10ft Pices of 2\" EMT **May need adjusting per floor device specs**",
			"2\" EMT Coupling **May need adjusting per floor device specs**",
			"2\" EMT to Flex Change Over **May need adjusting per floor device specs**",
			"2\" 90° Elbow **May need adjusting per floor device specs**",
			"10ft Pieces of 2\" Flex **May need adjusting per floor device specs**",
			"2\" Insulating Push On Conduit Bushing **May need adjusting per floor device specs**",
			"2\" Min Strap **May need adjusting per floor device specs**",
			"Tube of Fire Cock **May need adjusting per floor device specs**",
			"Jet Line",
			"Multifuction Clip w/ nut or bolt",
			"6\" Floor Device ***Per Print***",
			"Floor Device to Flex Converter ***Per Print***",
			"1/2\" Panhead Selftapper",
			"Mac-2 Straps",
			"Red/Yellow Wire Nuts",
			"Red Heads",
			"Single Barrel MC Connector",
			"12/2 LV MC",
			"4-Square Bracket Box",
			"4-Square Cover",
			"KX Straps"
		],
		"4in Floor Device": [
			"Tube of Fire Cock **May need adjusting per floor device specs**",
			"4\" Floor Device ***Per Print***",
			"Mac-2 Straps",
			"Red/Yellow Wire Nuts",
			"Red Heads",
			"Single Barrel MC Connector",
			"12/2 LV MC",
			"4-Square Bracket Box",
			"4-Square Cover",
			"KX Straps"
		],
		"Single-Pole 277V 40A Instahot": [
			"3/4\" MC Connector",
			"Deep 4-Square Box",
			"4-Square Industrial Switch Cover Plate",
			"1/2\" One Hole Strap",
			"Big Blue Wire Nuts",
			"Single-Pole Motor Rated 30A Switch",
			"8/2 HV MC"
		],
		"Single-Pole 277V 30A Instahot": [
			"3/4\" MC Connector",
			"Deep 4-Square Box",
			"4-Square Industrial Switch Cover Plate",
			"1/2\" One Hole Strap",
			"Big Blue Wire Nuts",
			"Single-Pole Motor Rated 30A Switch",
			"10/2 HV MC"
		],
		"2-pole 208V 40A Instahot": [
			"3/4\" MC Connector",
			"Deep 4-Square Box",
			"4-Square Industrial Switch Cover Plate",
			"1/2\" One Hole Strap",
			"Big Blue Wire Nuts",
			"Two-Pole Motor Rated 40A Switch",
			"8/3 LV MC"
		]
		
		
	]
	
		
	
}

//
//    func saveSelectedNumbers() {
//        UserDefaults.standard.set(selectedPhoneNumber, forKey: "CustomPhoneNumber")
//        UserDefaults.standard.set(selectedPhoneNumber2, forKey: "CustomPhoneNumber2")
//    }
//    
//    func clearSelectedNumbers() {
//        selectedPhoneNumber = ""
//        selectedPhoneNumber2 = ""
//        UserDefaults.standard.removeObject(forKey: "CustomPhoneNumber")
//        UserDefaults.standard.removeObject(forKey: "CustomPhoneNumber2")
//    }
//    func clearFirstContact() {
//        selectedContactName = ""
//        selectedContactPhoneNumber = ""
//        UserDefaults.standard.removeObject(forKey: "SelectedContact1")
//    }
//    func clearSecondContact() {
//        selectedContactName2 = ""
//        selectedContactPhoneNumber2 = ""
//        UserDefaults.standard.removeObject(forKey: "SelectedContact2")
//
//        
//    }
    //
    //
    //
    //    @Published var selectedContact: CNContact {
    //           didSet {
    //               // Save to UserDefaults when selectedContact changes
    //               saveContact()
    //           }
    //       }
    //
    //       @Published var selectedPhoneNumber: String {
    //           didSet {
    //               // Save to UserDefaults when selectedPhoneNumber changes
    //               savePhoneNumber()
    //           }
    //       }
    //
    //
    //      // Function to save selectedContact to UserDefaults
    //      private func saveContact() {
    //          // Convert selectedContact to Data
    //          if let encoded = try? NSKeyedArchiver.archivedData(withRootObject: selectedContact, requiringSecureCoding: false) {
    //              UserDefaults.standard.set(encoded, forKey: "SelectedContact")
    //          }
    //      }
    //
    //      // Function to save selectedPhoneNumber to UserDefaults
    //      private func savePhoneNumber() {
    //          UserDefaults.standard.set(selectedPhoneNumber, forKey: "CustomPhoneNumber")
    //      }
    //
    //      // Function to load selectedContact from UserDefaults
    //      private static func loadContact() -> CNContact {
    //          guard let contactData = UserDefaults.standard.object(forKey: "SelectedContact") as? Data,
    //                let contact = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(contactData) as? CNContact
    //          else {
    //              return CNContact() // Return a default value if no saved data exists
    //          }
    //          return contact
    //      }
    //
    //      // Function to load selectedPhoneNumber from UserDefaults
    //      private static func loadPhoneNumber() -> String {
    //          return UserDefaults.standard.string(forKey: "CustomPhoneNumber") ?? ""
    //      }
    //  }
