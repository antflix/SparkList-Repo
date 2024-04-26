import CoreML
import SwiftUI
import Vision
import ZoomImageViewer
//import FrameUp

import UniformTypeIdentifiers
struct ObjectDetectionResult {
	let objectClass: Int
	let confidence: Double
	let height: CGFloat
	let width: CGFloat
	let xCenter: CGFloat
	let yCenter: CGFloat
	let name: String
}
extension CGRect {
	func scaledAndFlipped(to size: CGSize) -> CGRect {
		// No scaling needed as the values seem to be in pixels already
		let scaledX = self.origin.x
		let scaledWidth = self.size.width
		
		// Flip the y-coordinate
		let flippedY = size.height - (self.origin.y + self.size.height)
		let scaledHeight = self.size.height
		
		return CGRect(x: scaledX, y: flippedY, width: scaledWidth, height: scaledHeight)
	}
}

struct ImagePicker: UIViewControllerRepresentable {
	@Binding var isPresented: Bool
	@Binding var selectedImage: UIImage?
	
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
		var parent: ImagePicker
		
		init(_ parent: ImagePicker) {
			self.parent = parent
		}
		
		func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
			if let image = info[.originalImage] as? UIImage {
				parent.selectedImage = image
			}
			parent.isPresented = false
		}
		
		func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
			parent.isPresented = false
		}
	}
	
	
}

// Import your CoreML model
struct OutletCounter: View {
	@State private var uiImage: UIImage?
	@State private var uploadedImage: UIImage?
	@State private var confidenceLevel: Double = 0.5
	@State private var tiles = [UIImage]()
	@State private var overlayImages = [UIImage]()
	@State private var results = [ObjectDetectionResult]()
	@State private var isShowingFullScreen = false
	@State private var uiImage3: UIImage? = nil
	@State private var adjustedImage: UIImage?
	@State private var uiImage2: UIImage? = nil
	@State private var classCounts: [Int: Int] = [:]
	let tileSize = CGSize(width: 640, height: 640)
	@State private var scale: CGFloat = 1.0
	@State private var showingImagePicker = false
	let classColors: [Int: Color] = [
		0: Color.red, // Red for class 0
		1: Color.green, // Green for class 1
		2: Color.blue, // Blue for class 2
		3: Color.yellow, // Yellow for class 3
		4: Color.purple, // Purple for class 4
		5: Color.orange, // Orange for class 5
		6: Color.pink, // Pink for class 6
		7: Color.brown, // Brown for class 7
		8: Color.mint, // Mint for class 8
		9: Color.indigo, // Indigo for class 9
		10: Color.cyan, // Cyan for class 10
		11: Color.teal, // Teal for class 11
		12: Color("button3"), // Burgundy for class 12
		13: Color("button2"), // Olive for class 13
		14: Color("Color 2"), // Magenta for class 14
		15: Color("button1"),// Violet for class 15
		16: Color.red,
		17: Color.green,
		18: Color.blue
	]
	let classNames = [
		0: "2x4", 1: "3-way Switch", 2: "Occupency Dimmer Switch", 3: "EMG 2x4", 4: "EMG Canlight", 5: "Occupency Sensor Switch", 6: "Canlight", 7: "Demo 2x2", 8: "Demo 2x4", 9: "Demo Canlight", 10: "Low Voltage Controlls Switch", 11: "Exit Sign", 12: "Linear", 13: "Ceiling Mounted Motion Sesnsor", 14: "Pendant Light", 15: "Line Voltage Switch", 16: "data", 17: "duplex", 18: "quad"	]
	
	var body: some View {
		GeometryReader { proxy in
			VStack {
				//				ForEach(classCounts.sorted(by: <), id: \.key) { key, value in
				//					Text("Class \(key): \(value) objects")
				//				}
				ForEach(classCounts.keys.sorted(), id: \.self) { key in // Iterate over sorted keys
					HStack {
						// Display the colored bounding box
						Rectangle()
							.fill(classColors[key] ?? Color.gray) // Use gray as default color if class is not found in dictionary
							.frame(width: 20, height: 20)
							.border(Color.black, width: 1)
						
						// Display the class name
						Text("\(classNames[key] ?? "Unknown"): ")
							.foregroundColor(.primary)
						
						// Display the count
						Text("\(classCounts[key] ?? 0)")
							.foregroundColor(.primary)
					}
				}
				ScrollView(.vertical, showsIndicators: true) {
					VStack {
						// Check if uiImage2 is available
						if let processedImage = adjustedImage {
							// Display the original image with bounding boxes
							Image(uiImage: processedImage)
								.resizable()
								.aspectRatio(contentMode: .fit)
								.scaledToFit()
								.onTapGesture {
									uiImage3 = adjustedImage
								}
						} else if let inputImage = adjustedImage {
							// Horizontal ScrollView inside the Vertical ScrollView
							ScrollView(.horizontal, showsIndicators: true) {
								HStack {
									let columns = Int(inputImage.size.width) / Int(tileSize.width)
									LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: columns), spacing: 0) {
										ForEach(overlayImages, id: \.self) { overlayImage in
											Image(uiImage: overlayImage)
												.resizable()
												.aspectRatio(contentMode: .fit)
												.scaledToFit()
												.clipped()
											
										}
									}
								}
							}
						}
					}
				}
				Slider(value: $confidenceLevel, in: 0...1, step: 0.1) {
					Text("Confidence Level")
				}
				Text("\(confidenceLevel)")
				Button("Detect Objects") {
					detectObjects()
					//
				}
				
				Button("Upload Image") {
					showingImagePicker = true
				}
				Button("Download Files") {
					downloadFiles()
				}
			}
			.sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
				ImagePicker(isPresented: $showingImagePicker, selectedImage: $uploadedImage)
			}
			
			
			
			.overlay(
				/// Auto rotating modifier is from FrameUp and is optional
//				AutoRotatingView {
					ZoomImageViewer(uiImage: $uiImage3)
//				}
			)
		}
		.onAppear {
			splitImage()
		}
	}
	
	
	
	func cropOrPadImageToTileSize(_ image: UIImage, tileSize: CGSize) -> UIImage? {
		guard let cgImage = image.cgImage else { return nil }
		
		let originalWidth = cgImage.width
		let originalHeight = cgImage.height
		
		let widthRemainder = originalWidth % Int(tileSize.width)
		let heightRemainder = originalHeight % Int(tileSize.height)
		
		let shouldPadWidth = widthRemainder > Int(tileSize.width) / 2
		let shouldPadHeight = heightRemainder > Int(tileSize.height) / 2
		
		let newWidth = shouldPadWidth ? originalWidth + (Int(tileSize.width) - widthRemainder) : originalWidth - widthRemainder
		let newHeight = shouldPadHeight ? originalHeight + (Int(tileSize.height) - heightRemainder) : originalHeight - heightRemainder
		
		let sizeChange = CGSize(width: newWidth, height: newHeight)
		UIGraphicsBeginImageContext(sizeChange)
		image.draw(in: CGRect(x: shouldPadWidth ? (Int(tileSize.width) - widthRemainder) / 2 : 0,
							  y: shouldPadHeight ? (Int(tileSize.height) - heightRemainder) / 2 : 0,
							  width: originalWidth,
							  height: originalHeight))
		let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return resizedImage
	}
	
	func loadImage() {
		guard let inputImage = uploadedImage else { return }
		uiImage = inputImage
		splitImage()
		// Process the new image
	}
	
	func splitImage() {
		
		guard let inputImage = uiImage else { return }
		
		// Adjust the image size before tiling
		if let adjustedImage = cropOrPadImageToTileSize(inputImage, tileSize: tileSize) {
			self.adjustedImage = adjustedImage
			uiImage = adjustedImage
			tiles = tileImage(adjustedImage, tileSize: tileSize)
		}
	}
	
	func tileImage(_ image: UIImage, tileSize: CGSize) -> [UIImage] {
		var tiles = [UIImage]()
		
		let cgImage = image.cgImage!
		
		let width = cgImage.width
		let height = cgImage.height
		//		print("image size: \(width) x \(height)")
		let tileWidth = Int(tileSize.width)
		let tileHeight = Int(tileSize.height)
		
		for y in stride(from: 0, to: height, by: tileHeight) {
			for x in stride(from: 0, to: width, by: tileWidth) {
				let tileRect = CGRect(x: x, y: y, width: tileWidth, height: tileHeight)
				let tileCGImage = cgImage.cropping(to: tileRect)!
				let tileUIImage = UIImage(cgImage: tileCGImage)
				
				tiles.append(tileUIImage)
			}
		}
		
		return tiles
	}
	
	func saveDataAsTextFile(data: String, filename: String, tile: UIImage, index: Int) {
		let filenamePath = getDocumentsDirectory().appendingPathComponent(filename)
		
		// Clear any data in the file
		try? "".write(to: filenamePath, atomically: true, encoding: .utf8)
		
		if let fileHandle = FileHandle(forWritingAtPath: filenamePath.path) {
			fileHandle.seekToEndOfFile()
			fileHandle.write(data.data(using: .utf8)!)
			fileHandle.closeFile()
		} else {
			try? data.write(to: filenamePath, atomically: true, encoding: .utf8)
		}
		
		let renderer = UIGraphicsImageRenderer(size: tile.size)
		let image = renderer.image { ctx in
			tile.draw(in: CGRect(origin: CGPoint.zero, size: tile.size))
		}
		
		let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("tiles\(index).png")
		if let data = image.pngData() {
			try? data.write(to: fileURL)
		}
	}
	func getDocumentsDirectory() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return paths[0]
	}
	func detectObjects() {
		//		print("detectObjects() called")
		
		results.removeAll()
		overlayImages.removeAll()
		let inputImageWidth = self.adjustedImage?.size.width ?? 0
		let inputImageHeight = self.adjustedImage?.size.height ?? 0
		
		if let data = adjustedImage?.pngData() {
			let filename = getDocumentsDirectory().appendingPathComponent("adjustedImage.png")
			try? data.write(to: filename)
		}
		let columns = Int(inputImageWidth / tileSize.width)
		
		for (index, tile) in tiles.enumerated() {
			//			print("Processing tile \(index)")
			var data = ""
			// Calculate tile's position in the grid
			let row = index / columns
			let column = index % columns
			// Calculate offset based on tile's position
			let xOffset = CGFloat(column) * tileSize.width
			let yOffset = inputImageHeight - CGFloat(row + 1) * tileSize.height
			guard let ciImage = CIImage(image: tile) else { continue }
			
			guard let model = try? VNCoreMLModel(for: wallsSeg().model) else { continue }
			//			print("Model loaded")
			let tilePosition = CGPoint(x: xOffset, y: yOffset)
			let tileSize = tile.size
			
			let request = VNCoreMLRequest(model: model) { [self] request, _ in
				guard let results = request.results as? [VNRecognizedObjectObservation] else { return }
				for observation in results {
					print(observation)
				}
				//								print("\(results)")
				//				if let observation = results.first {
				//					let labels = observation.labels
				//					for label in labels {
				//						print("Identifier: \(label.identifier), Confidence: \(label.confidence) \n")
				//					}
				//					print("/////////////\n\n\n")
				//				}
				let detections = results.compactMap { observation -> ObjectDetectionResult? in
					if observation.confidence >= Float(confidenceLevel) {
						let objectClass = observation.labels.first?.identifier ?? "0"
						let classString = String(objectClass)
						//						print(classString)
						//						print("Model's Bounding Box for tile \(index): \(observation.boundingBox)")
						let xCenterTile = observation.boundingBox.midX * tile.size.width
						let yCenterTile = observation.boundingBox.midY * tile.size.height
						
						
						// Adjust the center point to the coordinate system of the full image
						// Note: Vision framework's y-origin is at the bottom, so we "0need to invert the y-coordinate
						let adjustedXCenter = xOffset + xCenterTile
						let adjustedYCenter = yOffset + yCenterTile
						//						print("Calculated Coordinates for tile \(index): xCenter: \(adjustedXCenter), yCenter: \(adjustedYCenter)")
						//						print(observation.labels)
						
						let yCorrected = 1.0 - observation.boundingBox.midY
						let boxes = ("\(classString) \(observation.boundingBox.midX) \(yCorrected) \(observation.boundingBox.width) \(observation.boundingBox.height)\n")
						data += boxes
						print("\(classString) \(observation.boundingBox.midX) \(yCorrected) \(observation.boundingBox.width) \(observation.boundingBox.height)\nConfidence:\(observation.confidence)\n\n")
						//										print("detections loop: \(data)")
						//						print(tile.size.height)
						//						print(yOffset)
						//						print(tile.size.width)
						//						print(xOffset)
						//						print(row)
						//						print(column)
						let classIndex: [String: Int] = ["2x4": 0,
														 "3-way Switch": 1,
														 "Occupency Dimmer Switch": 2,
														 "EMG 2x4": 3,
														 "EMG Canlight": 4,
														 "Occupency Sensor Switch": 5,
														 "Canlight": 6,
														 "Demo 2x2": 7,
														 "Demo 2x4": 8,
														 "Demo Canlight": 9,
														 "Low Voltage Controlls Switch": 10,
														 "Exit Sign": 11,
														 "Linear": 12,
														 "Ceiling Mounted Motion Sesnsor": 13,
														 "Pendant Light": 14,
														 "Line Voltage Switch": 15,
														 "data": 16,
														 "duplex": 17,
														 "quad": 18]
						return ObjectDetectionResult(
							objectClass: classIndex[observation.labels.first?.identifier ?? "Unknown"] ?? 0,
							confidence: Double(observation.confidence),
							height: observation.boundingBox.height * tile.size.height,
							width: observation.boundingBox.width * tile.size.width,
							xCenter: adjustedXCenter,
							yCenter: adjustedYCenter,
							name: observation.labels.first?.identifier ?? "Unknown"
						)
					}
					return nil
				}
				//				let filename = "tiles\(index).txt"
				//				print("Tile: \(index)")
				//				print(data)
				//				saveDataAsTextFile(data: data, filename: filename, tile: tile, index: index)
				
				self.results.append(contentsOf: detections)
			}
			// Save the print stment information as a .txt file
			
			try? VNImageRequestHandler(ciImage: ciImage).perform([request])
		}
		var tileNumber2 = 1
		//		print("Tile2: \(tileNumber2)")
		tileNumber2 += 1
		// New code starts here - Draw bounding boxes on the original image
		guard let inputImage = adjustedImage, let cgInputImage = inputImage.cgImage else { return }
		let size = inputImage.size
		UIGraphicsBeginImageContextWithOptions(size, false, inputImage.scale)
		guard let context = UIGraphicsGetCurrentContext() else { return }
		
		context.draw(cgInputImage, in: CGRect(origin: .zero, size: size))
		
		for detection in results {
			let rect = CGRect(
				x: detection.xCenter - detection.width / 2,
				y: detection.yCenter - detection.height / 2,
				width: detection.width,
				height: detection.height
				
			)
			if let count = classCounts[detection.objectClass] {
				classCounts[detection.objectClass] = count + 1
			} else {
				classCounts[detection.objectClass] = 1
			}
			// Check the class of the detected object and set the bounding box color accordingly
			if detection.objectClass == 0 {
				context.setStrokeColor(UIColor.red.cgColor)
			} else if detection.objectClass == 1 {
				context.setStrokeColor(UIColor.blue.cgColor)
			} else {
				context.setStrokeColor(UIColor.green.cgColor) // default color if class is not 0 or 1
			}
			
			let color = classColors[detection.objectClass] ?? Color.gray
			let uiColor = UIColor(color).withAlphaComponent(0.5) // Adjust opacity here
			context.setStrokeColor(uiColor.cgColor)
			context.setFillColor(uiColor.cgColor)
			context.setLineWidth(2)
			context.addRect(rect)
			context.fill(rect) // Fill the rectangle
			
			context.strokePath()
			
		}
		
		let overlayedImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		DispatchQueue.main.async {
			//			print("uiImage2 dimensions: \(uiImage?.size.width) x \(uiImage?.size.height)")
			self.adjustedImage = overlayedImage // Update the UI with the new image
		}
	}
	
	
	func drawBoundingBox(on image: UIImage, box: CGRect) -> UIImage {
		
		UIGraphicsBeginImageContextWithOptions(image.size, false, 0.0)
		
		// Draw original image
		image.draw(at: CGPoint(x: 0, y: 0))
		
		// Get context
		let context = UIGraphicsGetCurrentContext()!
		
		// Change stroke color to green
		context.setStrokeColor(UIColor.green.cgColor)
		
		// Change line width to 3
		context.setLineWidth(3)
		
		// Draw bounding box
		context.addRect(box)
		context.strokePath()
		
		// Get overlay image
		let overlayImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		
		return overlayImage
	}
	
	
	
	
	
	
	func downloadFiles() {
		// Ensure this is run on a macOS target
#if targetEnvironment(macCatalyst)
		let folderURL = getDocumentsDirectory().appendingPathComponent("Documents") // The folder containing all your files
		
		let zipFileURL = getDocumentsDirectory().appendingPathComponent("YourFiles.zip")
		
		// Use a ZIP library to compress the folder. This is a placeholder - you'll need to replace it with actual ZIP library usage
		try? FileManager.default.zipItem(at: folderURL, to: zipFileURL, shouldKeepParent: false)
		
		// Present the save panel for the ZIP file
		presentSavePanel(for: zipFileURL)
#endif
	}
	
	func presentSavePanel(for fileURL: URL) {
		// Ensure this is run on a macOS target
#if targetEnvironment(macCatalyst)
		let savePanel = NSSavePanel()
		savePanel.canCreateDirectories = true
		savePanel.nameFieldStringValue = fileURL.lastPathComponent
		savePanel.allowedContentTypes = [.archive] // This sets the allowed file type to .zip
		
		savePanel.begin { result in
			if result == .OK, let url = savePanel.url {
				try? FileManager.default.moveItem(at: fileURL, to: url)
			}
		}
#endif
	}
	
	
}


