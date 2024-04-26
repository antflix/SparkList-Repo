import SwiftUI
import ContactsUI

struct ContactPickerViewController: UIViewControllerRepresentable {
	@EnvironmentObject var dataManager: DataManager
	
	func makeCoordinator() -> Coordinator {
		Coordinator(dataManager: dataManager)
	}
	func makeUIViewController(context: Context) -> CNContactPickerViewController {
		let picker = CNContactPickerViewController()
		picker.delegate = context.coordinator
		return picker
	}

	func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}

	class Coordinator: NSObject, CNContactPickerDelegate {
		var dataManager: DataManager
		
		init(dataManager: DataManager) {
			self.dataManager = dataManager
		}
		
		func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
			// Check if the contact is already selected
			if !dataManager.selectedContacts.contains(where: { $0.identifier == contact.identifier }) {
				dataManager.selectedContacts.append(contact)
				
				// Save the contacts immediately upon selection
				dataManager.saveSelectedContacts()
			}
		}
	}
}


