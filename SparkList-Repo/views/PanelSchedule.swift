import SwiftUI
import Vision
import VisionKit
import UIKit
import Vision
import Vision
import SwiftUI
import UniformTypeIdentifiers
import UniformTypeIdentifiers

import UIKit
import Vision


extension UTType {
	static var customCSV: UTType {
		UTType(exportedAs: "com.antflix.sparklist.csv")
	}
}

struct PanelSchedule: View {
	@EnvironmentObject var dataManager: DataManager // Access DataManager passed via environmentObject
	
	@State private var selectedImage: UIImage?
	@State private var isImagePickerPresented = false
	@ObservedObject var viewModel = TextRecognitionViewModel()
	@State private var fileURL: URL?
	
	var body: some View {
		VStack {
			if let image = selectedImage {
				Image(uiImage: image)
					.resizable()
					.scaledToFit()
			}
			
			Button("Select Image") {
				isImagePickerPresented = true
			}
			.sheet(isPresented: $isImagePickerPresented) {
				PanelImagePicker(selectedImage: $selectedImage)
			}
			.onChange(of: selectedImage) { _ in
				if let selectedImage = selectedImage {
					viewModel.recognizeText(from: selectedImage)
				}
			}
			
			ScrollView {
				Text(viewModel.recognizedText)
					.padding()
			}
			
			Button("Generate and Share .csv") {
				generateCSV { url in
					fileURL = url
				}
			}
			
			// Ensure the ShareLink is only shown (or activated) if the fileURL is not nil
			if let fileURL = fileURL {
				ShareLink(item: fileURL, subject: Text("Here's my CSV file")) {
					Label("Share .csv", systemImage: "square.and.arrow.up")
				}
			}
		}
	}
	
	private func generateCSV(completion: @escaping (URL?) -> Void) {
		let fileName = "sample2.csv"
		let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
		let path = documentDirectory.appendingPathComponent(fileName)
		
		let csvText = viewModel.recognizedText
		
		do {
			try csvText.write(to: path, atomically: true, encoding: .utf8)
			completion(path)
		} catch {
			print("Failed to create file: \(error)")
			completion(nil)
		}
	}
}

class TextRecognitionViewModel: ObservableObject {
	@EnvironmentObject var dataManager: DataManager // Access DataManager passed via environmentObject
	
	@Published var recognizedText = "Select an image to start recognizing text."
	
	func recognizeText(from image: UIImage) {
		guard let cgImage = image.cgImage else { return }
		
		let requestHandler = VNImageRequestHandler(cgImage: cgImage)
		
		let request = VNRecognizeTextRequest { [weak self] request, error in
			guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
				self?.recognizedText = "Failed to recognize text."
				return
			}
			
			// Sort observations to maintain the top-to-bottom order in text recognition
			let sortedObservations = observations.sorted(by: { $0.topLeft.y > $1.topLeft.y })
			
			var column1Texts: [String] = []
			var column2Texts: [String] = []
			var column3Texts: [String] = []
			var column4Texts: [String] = []
			
			// Define thresholds to distinguish columns, these values might need adjustment
			let columnThreshold1 = 0.25
			let columnThreshold2 = 0.5
			let columnThreshold3 = 0.75
			
			// Separate the text into four columns based on their horizontal positions
			for observation in sortedObservations {
				if let candidate = observation.topCandidates(1).first {
					let midX = observation.boundingBox.midX
					if midX < columnThreshold1 {
						column1Texts.append(candidate.string)
					} else if midX < columnThreshold2 {
						column2Texts.append(candidate.string)
					} else if midX < columnThreshold3 {
						column3Texts.append(candidate.string)
					} else {
						column4Texts.append(candidate.string)
					}
				}
			}
			
			// Combine the columns into a single CSV-formatted string
			var csvText = ""
			let maxCount = max(column1Texts.count, column2Texts.count, column3Texts.count, column4Texts.count)
			for index in 0..<maxCount {
				let text1 = index < column1Texts.count ? column1Texts[index] : ""
				let text2 = index < column2Texts.count ? column2Texts[index] : ""
				let text3 = index < column3Texts.count ? column3Texts[index] : ""
				let text4 = index < column4Texts.count ? column4Texts[index] : ""
				csvText += "\"\(text1)\",\"\(text2)\",\"\(text3)\",\"\(text4)\"\n"
			}
			
			DispatchQueue.main.async {
				let csvFormattedText = self?.parseRecognizedText(recognizedText: csvText)
				
				self?.recognizedText = csvFormattedText ?? "Failed to format text."
				// Here you can add functionality to save csvText to a file.
			}
		}
		
		do {
			try requestHandler.perform([request])
		} catch {
			print("Unable to perform the requests: \(error).")
		}
	}
	
	private func generateCSV(completion: @escaping (URL?) -> Void) {
		let fileName = "sample.csv"
		let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
		
		let csvText =  recognizedText
		let csvFormattedText = parseRecognizedText(recognizedText: csvText)
		
		
		do {
			try csvFormattedText.write(to: path, atomically: true, encoding: String.Encoding.utf8)
			completion(path)
		} catch {
			print("Failed to create file: \(error)")
			completion(nil)
		}
	}
	func parseRecognizedText(recognizedText: String) -> String {
		// Split the recognized text by new lines
		let lines = recognizedText.split(separator: "\n")
		
		var csvText = ""
		
		for line in lines {
			// Use a regular expression to find matches for numbers followed by text
			let pattern = "(\\d+)\\s+(.*?)(?=\\d+|$)"
			let regex = try? NSRegularExpression(pattern: pattern, options: [])
			let matches = regex?.matches(in: String(line), options: [], range: NSRange(line.startIndex..., in: line))
			
			var lineComponents: [String] = []
			
			matches?.forEach { match in
				guard let numberRange = Range(match.range(at: 1), in: line),
					  let textRange = Range(match.range(at: 2), in: line) else { return }
				
				let number = line[numberRange]
				let text = line[textRange].trimmingCharacters(in: .whitespacesAndNewlines)
				
				lineComponents.append("\"\(number)\",\"\(text)\"")
			}
			
			csvText += lineComponents.joined(separator: ",") + "\n"
		}
		
		return csvText
	}
	
	// Usage
	
}

struct PanelImagePicker: UIViewControllerRepresentable {
	@Binding var selectedImage: UIImage?
	@Environment(\.presentationMode) private var presentationMode
	
	func makeUIViewController(context: Context) -> UIImagePickerController {
		let picker = UIImagePickerController()
		picker.delegate = context.coordinator
		return picker
	}
	
	func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
	
	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}
	
	class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
		let parent: PanelImagePicker
		
		init(_ parent: PanelImagePicker) {
			self.parent = parent
		}
		
		func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
			if let image = info[.originalImage] as? UIImage {
				parent.selectedImage = image
			}
			parent.presentationMode.wrappedValue.dismiss()
		}
	}
}
//func generateCSV(completion: @escaping (URL?) -> Void) {
//	let fileName = "sample.csv"
//	let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
//
//	let csvText = "Column1,Column2,Column3\nValue1,Value2,Value3"
//
//	do {
//		try csvText.write(to: path, atomically: true, encoding: String.Encoding.utf8)
//		completion(path)
//	} catch {
//		print("Failed to create file: \(error)")
//		completion(nil)
//	}
//}

// Wrapper for UIActivityViewController to use in SwiftUI
//struct ActivityView: UIViewControllerRepresentable {
//	var activityItems: [Any]
//	var applicationActivities: [UIActivity]? = nil
//
//	func makeUIViewController(context: Context) -> UIActivityViewController {
//		let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
//		return controller
//	}
//
//	func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
//}

//class CSVDocument: UIDocument {
//	var data: Data?
//
//	override func contents(forType typeName: String) throws -> Any {
//		return data ?? Data()
//	}
//
//	override func load(fromContents contents: Any, ofType typeName: String?) throws {
//		if let data = contents as? Data {
//			self.data = data
//		}
//	}
//}
//
//struct ShareSheet: UIViewControllerRepresentable {
//	var fileURL: URL
//	var data: Data?
//
//	func makeUIViewController(context: Context) -> UIActivityViewController {
//		let document = CSVDocument(fileURL: fileURL)
//		document.data = data
//
//		let controller = UIActivityViewController(activityItems: [document], applicationActivities: nil)
//		return controller
//	}
//
//	func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
//}


struct PanelSchedule_Previews: PreviewProvider {
	static var previews: some View {
		PanelSchedule()
	}
}

//func convertToCSV(data: [[String]]) -> String {
//	var csvString = ""
//	for row in data {
//		let rowString = row.map { "\"\($0.replacingOccurrences(of: "\"", with: "\"\""))\"" }
//			.joined(separator: ",")
//		csvString += rowString + "\n"
//	}
//	return csvString
//}
//
//// Define a SwiftUI view that includes a button to share a .csv file
//struct ShareSheetView: View {
//	// State variable to manage the presentation of the share sheet
//	@State private var isShareSheetPresented = false
//
//	// The URL of the .csv file to share
//	// Replace this with the actual URL of your .csv file
//	@State private var fileURL: URL?
//
//	var body: some View {
//		// A button that generates the .csv file and presents the share sheet
//		Button("Share .csv") {
//			generateCSV { url in
//				self.fileURL = url
//				self.isShareSheetPresented = true
//			}
//		}
//		.sheet(isPresented: $isShareSheetPresented, onDismiss: {
//			// Reset the fileURL when the sheet is dismissed
//			self.fileURL = nil
//		}) {
//			// Use UIActivityViewController to present the share sheet
//			ActivityView(activityItems: [fileURL!])
//		}
//	}
//
//	// Function to generate a .csv file and return its URL

//}
