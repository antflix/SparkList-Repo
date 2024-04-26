//
//  DeviceFinderAPI.swift
//  SparkList
//
//  Created by Anthony on 4/16/24.
//

import SwiftUI
import SwiftyJSON

import ZoomImageViewer

struct CategoryDetail {
    let name: String
    var count: Int
    let color: UIColor
}

// class DetectionData: ObservableObject {
//	var predictions: [ObjectP@corediction] = []
//	@Published var selectedCategories: Set<Int> = []
//	@Published var scoreThreshold: Double = 0.5 // Default threshold
// }
struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

struct DeviceFinderAPI: View {
    //	@State private var image: UIImage? = UIImage(named: "123.png")
    @State private var address: String = "http://localhost:5004/predict"
    @State private var predictions: [ObjectPrediction] = []
    @State private var displayImage: UIImage?
    @State private var classCounts: [String: Int] = [:]
    @State private var scale: CGFloat = 1.0
    @State private var lastScaleValue: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var categoryColors: [String: UIColor] = [:]
    @State private var usedColors: [UIColor] = []
    @State private var isShowingFullScreen = false
    @State private var uiImage: UIImage? = nil
    @State private var inputImage: UIImage? = nil
    @State private var scoreThreshold: Double = 0.5 // Default threshold
    @State private var showingActionSheet = false
    @State private var showingImagePicker = false
	@State private var fullImage: UIImage?

    @State private var selectedImage: UIImage?
    @State private var selectedClass: String? = nil
    let mainColors: [UIColor] = [
        .red, .blue, .green, .purple, .orange, .yellow, .magenta, .cyan,
    ]

    var body: some View {
        GeometryReader { geometry in
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                ZStack(alignment: .topTrailing) { // Overlay content on the image
                    //												  // Display the image if available
                    //					if let displayImage = inputImage {
                    //						Image(uiImage: displayImage)
                    //							//f.resizable()
                    //							.scaledToFit()
                    //						// ... other modifiers ...
                    //					} else {
                    //						Text("Image not available")
                    //					}
                    /////////////////////////////           UPLOAD IMAGE            /////////////////////////////////////////////
                    VStack {
                        Button(action: {
                            self.showingActionSheet = true
                        }) {
                            Image(systemName: "camera")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .shadow(radius: 3)
                        }
                        .actionSheet(isPresented: $showingActionSheet) {
                            ActionSheet(
                                title: Text("Select Action"),
                                buttons: [
                                    .default(Text("Take Photo")) {
                                        //										classIndexCounts = [:]  // To hold the count of each class index
                                        //										allBoundingBoxes = []
                                        if let inputImage = self.uiImage { // Assuming `uiImage` is your input image
                                            uploadImage()
                                            displayImage = inputImage
                                            //											runInference(on: tiles, for: inputImage) { processedImage in
                                            //												// `processedImage` is the image with overlays
                                            //												// Use this image in your UI
                                            //												self.adjustedImage = processedImage
                                            //												showingCeilingCounts = true
                                        }
                                    },
                                    .default(Text("Upload Image")) {
                                        showingImagePicker = true
                                    },
                                    .cancel(),
                                ])
                        }
                        .padding()

                        Button("Draw Bounding Boxes") {
                            print("Button tapped") // This should appear in the console when the button is tapped
                            if let drawnImage = uiImage {
                                self.displayImage = drawBoundingBoxes(on: drawnImage, predictions: predictions)
                            } else {
                                print("drawnImage is nil") // This will indicate if inputImage is nil
                            }
                        }
                        .padding()
                        .background(Color.green)
                        .foregroundColor(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        Spacer()
                        // Display the image
                        ZStack(alignment: .topTrailing) {
                            if let displayImage = displayImage {
                                Image(uiImage: displayImage)
                                    .resizable()
                                    .scaledToFit()
                                    .scaleEffect(scale)
                                    .onTapGesture {
                                        fullImage = displayImage
                                    }
                                    .offset(x: offset.width, y: offset.height)
                                    .gesture(
                                        MagnificationGesture().onChanged { value in
                                            let delta = value / self.lastScaleValue
                                            self.lastScaleValue = value
                                            self.scale *= delta
                                        }
                                        .onEnded { _ in
                                            self.lastScaleValue = 1.0
                                        }
                                    )
                                    .simultaneousGesture(
                                        DragGesture().onChanged { value in
                                            let delta = CGSize(
                                                width: value.translation.width + self.lastOffset.width,
                                                height: value.translation.height + self.lastOffset.height)
                                            self.offset = delta
                                        }
                                        .onEnded { _ in
                                            self.lastOffset = self.offset
                                        }
                                    )
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                            } else {
                                Text("Image not available")
                            }
                            if classCounts != [:] {
                                VStack {
                                    List(classCounts.keys.sorted(), id: \.self) { key in
                                        HStack {
                                            Rectangle()
                                                .fill(Color(getColor(forCategory: key))) // Assuming you have a function to determine color
                                                .frame(width: 20, height: 20) // Size of the color square
                                                .cornerRadius(5) // Optional: adds rounded corners to the square

                                            Text("\(key): \(classCounts[key] ?? 0)")
                                        }
                                        .onTapGesture {
                                            self.selectedClass = key
                                            self.redrawBoundingBoxes(for: key)
                                        }
                                    }
                                    HStack {
                                        Rectangle()
                                            .fill() // Assuming you have a function to determine color
                                            .frame(width: 20, height: 20) // Size of the color square
                                            .cornerRadius(5) // Optional: adds rounded corners to the square

                                        Text("All")
                                    }
                                    .onTapGesture {
										selectedClass = nil
                                        if let drawnImage = uiImage {
                                            self.displayImage = drawBoundingBoxes(on: drawnImage, predictions: predictions)
                                        } else {
                                            print("drawnImage is nil") // This will indicate if inputImage is nil
                                        }
                                    }
                                }
                                .background(BlurView(style: .dark).opacity(0.1)) // Use BlurView here
                                .frame(width: 200, height: 300)
                                .cornerRadius(10)
                                .position(x: geometry.size.width - 100, y: 150)
                            }
                            Slider(value: $scoreThreshold, in: 0 ... 1, step: 0.01)
                                .padding()
                                .onChange(of: scoreThreshold) { _ in
                                    // Call function to re-draw bounding boxes with the new threshold
									if let baseImage = self.uiImage { // Assuming `uiImage` holds the base image without bounding boxes
										if selectedClass != nil{
											self.displayImage = drawBoundingBoxes(on: baseImage, predictions: self.predictions)
										}
										else {
											self.redrawBoundingBoxes(for: selectedClass)

										}
									}
                                }
                        }
                    }

                    // List to show class counts, overlaid on the bottom right of the ZStack
                }
                .sheet(isPresented: $showingImagePicker, onDismiss: uploadImage) {
                    ImagePicker(isPresented: $showingImagePicker, selectedImage: $uiImage)
                }
            }
        }
        .overlay(
            /// Auto rotating modifier is from FrameUp and is optional

            ZoomImageViewer(uiImage: $fullImage)
        )
		.onAppear {
			// Disable the interactive pop gesture in the navigation controller
			self.disableInteractivePopGesture()
		}
		.onChange(of: scale) { newScale in
			if newScale > 1 {
				// Disable the interactive pop gesture
				self.disableInteractivePopGesture()
			} else {
				// Enable the interactive pop gesture
				self.enableInteractivePopGesture()
			}
		}
    }

    func uploadImage() {
        print("METHOD: uploadImage()")
		if let selectedImage = self.uiImage {
			self.displayImage = selectedImage
		}
		guard let url = URL(string: address) else {
            showAlert(message: "Invalid server URL")
            return
        }
        guard let imageToUpload = uiImage else {
            showAlert(message: "Image not found")
            return
        }
        guard let imageData = imageToUpload.jpegData(compressionQuality: 0.9) else {
            showAlert(message: "Failed to process image")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue(
            "multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append(
            "Content-Disposition: form-data; name=\"image\"; filename=\"img2.jpg\"\r\n".data(
                using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        //		let task = URLSession.shared.uploadTask(with: request, from: body) { data, _, error in
        //			guard let data = data else {
        //				print("No data in response: \(error?.localizedDescription ?? "Unknown error")")
        //				return
        //			}
        //
        //			do {
        //				// First, decode the data into a string
        //				let jsonResponseString = try JSONDecoder().decode(String.self, from: data)
        //				// Convert the string back into Data
        //				guard let jsonData = jsonResponseString.data(using: .utf8) else {
        //					DispatchQueue.main.async {
        //						print("Failed to convert JSON string back to Data")
        //					}
        //					return
        //				}
        //				// Now, decode your actual structure
        //				let decodedResponse = try JSONDecoder().decode(
        //					[ObjectPredictionContainer].self, from: jsonData)
        //				DispatchQueue.main.async {
        //					// Update UI or state with the decoded response
        //					self.predictions = decodedResponse.map { $0.ObjectPrediction }
        //				}
        //				//				print("Decoded response: \(decodedResponse)")
        //			} catch {
        //				print("Failed to decode response: \(error)")
        //			}
        //		}

        let task = URLSession.shared.uploadTask(with: request, from: body) { data, response, error in
            guard let data = data else {
                print("No data in response: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            // Check server response code
            if let httpResponse = response as? HTTPURLResponse,
               !(200 ... 299).contains(httpResponse.statusCode) {
                print("Server returned status code: \(httpResponse.statusCode)")
                return
            }

            // Attempt to decode the data into a string
            guard let jsonResponseString = String(data: data, encoding: .utf8) else {
                print("Failed to convert Data to String")
                return
            }

            // Convert the string back into Data
            guard let jsonData = jsonResponseString.data(using: .utf8) else {
                DispatchQueue.main.async {
                    print("Failed to convert JSON string back to Data")
                }
                return
            }

            //			// Temporary debugging using JSONSerialization
            //			if let jsonDebug = try? JSONSerialization.jsonObject(with: jsonData, options: []) {
            //				print("Parsed with JSONSerialization: \(jsonDebug)")
            //			} else {
            //				print("Failed to parse with JSONSerialization")
            //			}
            //			print(jsonResponseString)
            // Parse JSON data using SwiftyJSON
            let json = JSON(jsonData)
            //			print(json)
            let objectPredictions = json.arrayValue.map { item -> ObjectPrediction in
                ObjectPrediction(
                    id: item["ObjectPrediction"]["category"]["Category"]["id"].intValue,
                    bbox: item["ObjectPrediction"]["bbox"]["BoundingBox"].stringValue,
                    w: item["ObjectPrediction"]["bbox"]["w"].doubleValue,
                    h: item["ObjectPrediction"]["bbox"]["h"].doubleValue,
                    score: item["ObjectPrediction"]["score"]["PredictionScore"].doubleValue,
                    categoryID: item["ObjectPrediction"]["category"]["Category"]["id"].intValue,
                    categoryName: item["ObjectPrediction"]["category"]["Category"]["name"].stringValue
                )
            }

            DispatchQueue.main.async {
                self.predictions = objectPredictions
                // Print the entire array of predictions
                //				print("All predictions:", self.predictions)
                //				var counts: [String: Int] = [:]
                //				objectPredictions.forEach { prediction in
                //					counts[prediction.categoryName, default: 0] += 1
                //				}
                //				classCounts = counts
                // Check if the array is not empty and print the first element
                if let firstPrediction = self.predictions.first {
                    print("First prediction category name:", firstPrediction.categoryName)
                    print("First prediction bounding box:", firstPrediction.bbox)
                } else {
                    print("No predictions found")
                }
            }
        }
        task.resume()
    }

    func getCategoryCounts(categoryName: String) -> Int {
        if let count = classCounts[categoryName] {
            classCounts[categoryName] = count + 1
            return count + 1 // Return the incremented count
        } else {
            classCounts[categoryName] = 1
            return 1 // Return the initialized count
        }
    }

    func drawBoundingBoxes(on image: UIImage, predictions: [ObjectPrediction]) -> UIImage? {
        print(
            "METHOD: drawBoundingBoxes(on image: UIImage, predictions: [PredictionDetails]) -> UIImage?")
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        image.draw(at: .zero) // Draw the base image
        var count = 0
        classCounts = [:]
        // Draw each bounding box
//        if selectedClass == nil {
            for prediction in predictions where prediction.score >= scoreThreshold {
                let categoryName = prediction.categoryName

                let bbox = parseBoundingBox(prediction.bbox)
                let rect = CGRect(x: bbox.x, y: bbox.y, width: bbox.width, height: bbox.height)

                // Increment category count or initialize it

                // Get the current count for this category
                let count = getCategoryCounts(categoryName: categoryName)
                print("drawBB")
                let categoryColor = getColor(forCategory: categoryName)
                context.setStrokeColor(categoryColor.cgColor)
                context.setLineWidth(2)
                context.addRect(rect)
                context.strokePath()

                // Draw the count number and category name near the bounding box
                drawText(
                    categoryName: categoryName, count: count, at: CGPoint(x: bbox.x, y: bbox.y), in: context)
            }
//        } else {
//            redrawBoundingBoxes(for: selectedClass)
//        }

        // Debugging output
        print("Category counts:", classCounts)
        // Retrieve the edited image
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        // Update classCounts on the main thread
        DispatchQueue.main.async {
            self.classCounts = classCounts
            print("!!!!!!\(self.classCounts)")
        }
        return newImage
    }

    func redrawBoundingBoxes(for selectedClass: String?) {
        // Filter predictions for the selected class
        let filteredPredictions =
            (selectedClass == nil)
                ? predictions
                : predictions.filter { prediction in
                    prediction.categoryName == selectedClass
                }

        // Redraw the image with the filtered bounding boxes
        if let uiImage = uiImage {
            displayImage =
                selectedClass == nil
                    ? drawBoundingBoxes(on: uiImage, predictions: filteredPredictions)
                    : drawFilteredBoundingBoxes(on: uiImage, filteredPredictions: filteredPredictions)
        }
    }

    func drawFilteredBoundingBoxes(on image: UIImage, filteredPredictions: [ObjectPrediction])
        -> UIImage? {
        print(
            "METHOD: drawBoundingBoxes(on image: UIImage, predictions: [PredictionDetails]) -> UIImage?")
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        image.draw(at: .zero) // Draw the base image

        // Draw each bounding box
		for prediction in filteredPredictions where prediction.score >= scoreThreshold  {
            let categoryName = prediction.categoryName
            let count = getCategoryCounts(categoryName: categoryName)
            let bbox = parseBoundingBox(prediction.bbox)
            let rect = CGRect(x: bbox.x, y: bbox.y, width: bbox.width, height: bbox.height)

            let categoryColor = getColor(forCategory: categoryName)
            context.setStrokeColor(categoryColor.cgColor)
            context.setLineWidth(2)
            context.addRect(rect)
            context.strokePath()

            // Draw the count number and category name near the bounding box
            drawText(
                categoryName: categoryName, count: count, at: CGPoint(x: bbox.x, y: bbox.y), in: context)
        }

        // Debugging output
        print("Category counts:", classCounts)
        // Retrieve the edited image
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        // Update classCounts on the main thread
        DispatchQueue.main.async {
            self.classCounts = classCounts
            print("!!!!!!\(self.classCounts)")
        }
        return newImage
    }

    func getColor(forCategory category: String) -> UIColor {
        print("METHOD: getColor(forCategory category: String) -> UIColor ")
        if let color = categoryColors[category] {
            return color
        } else {
            // Assign a color from mainColors if available
            let availableColors = mainColors.filter { !usedColors.contains($0) }
            if let newColor = availableColors.first {
                usedColors.append(newColor)
                categoryColors[category] = newColor
                return newColor
            }
            print("drawBB")
            // If all main colors are used, generate a random color
            let randomColor = generateRandomColor()
            categoryColors[category] = randomColor
            return randomColor
        }
    }

    func generateRandomColor() -> UIColor {
        print("METHOD: generateRandomColor() -> UIColor")
        let red = CGFloat.random(in: 0 ... 1)
        let green = CGFloat.random(in: 0 ... 1)
        let blue = CGFloat.random(in: 0 ... 1)
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }

    //	{0: '2x4', 1: '3-way Switch', 2: 'Canlight', 3: 'Ceiling Mounted Motion Sesnsor', 4: 'Demo 2x2', 5: 'Demo 2x4', 6: 'Demo Canlight', 7: 'EMG 2x4', 8: 'EMG Canlight', 9: 'Exit Sign', 10: 'Line Voltage Switch', 11: 'Linear', 12: 'Low Voltage Controlls Switch', 13: 'Occupency Dimmer Switch', 14: 'Occupency Sensor Switch', 15: 'Pendant Light', 16: 'data', 17: 'duplex', 18: 'quad'}
    //	{0: 'Data Box', 1: 'Dedicated Outlet', 2: 'Duplex Outlet', 3: 'Floor Box', 4: 'Furniture Feed', 5: 'Quad Outlet', 6: 'TV Box'}

    // Other functions like uploadImage, drawBoundingBoxes, etc., remain the same

    func drawText(categoryName: String, count: Int, at point: CGPoint, in context: CGContext) {
        print(
            "METHOD: drawText(categoryName: String, count: Int, at point: CGPoint, in context: CGContext)"
        )
        let text = "\(count) - \(categoryName)"
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left

        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 12),
            .paragraphStyle: paragraphStyle,
            .foregroundColor: UIColor.black,
        ]

        let attributedString = NSAttributedString(string: text, attributes: attrs)
        attributedString.draw(at: CGPoint(x: point.x, y: point.y - 15)) // Adjust y position to draw above the bbox
    }

    func parseBoundingBox(_ boundingBox: String) -> (
        x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat
    ) {
        print(
            "METHOD: parseBoundingBox(_ boundingBox: String) -> (x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat)"
        )
        let components = boundingBox.trimmingCharacters(in: CharacterSet(charactersIn: " ()"))
            .split(separator: ",")
            .map { substring -> CGFloat in
                let number = Double(substring.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
                return CGFloat(number)
            }
        if components.count == 4 {
            let x = components[0]
            let y = components[1]
            let x2 = components[2]
            let y2 = components[3]
            //			print("Before: x: \(x) y: \(y) y2: \(x2) x2: \(y2)")
            //			print("Width before: \(max(x2 - x, 0)) Height before: \(max(y2 - y, 0))")
            return (x: x, y: y, width: max(x2 - x, 0), height: max(y2 - y, 0))
        } else {
            // Return zeros if the components aren't as expected to avoid crashing
            return (x: 0, y: 0, width: 0, height: 0)
        }
    }
	private func disableInteractivePopGesture() {
		// Access the UINavigationController and disable the interactivePopGestureRecognizer
		if let windowScene = UIApplication.shared.connectedScenes
			.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
		   let window = windowScene.windows.first,
		   let navigationController = window.rootViewController as? UINavigationController {
			navigationController.interactivePopGestureRecognizer?.isEnabled = false
		}
	}

	private func enableInteractivePopGesture() {
		// Access the UINavigationController and enable the interactivePopGestureRecognizer
		if let windowScene = UIApplication.shared.connectedScenes
			.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
		   let window = windowScene.windows.first,
		   let navigationController = window.rootViewController as? UINavigationController {
			navigationController.interactivePopGestureRecognizer?.isEnabled = true
		}
	}
    func showAlert(message: String) {
        // Method to show an alert or handle the error visually in your app
        print(message)
    }

    //	func handleAPIResponse(data: Data) {
    //		print("METHOD: handleAPIResponse(data: Data)")
    //		do {
    //			let decodedResponse = try JSONDecoder().decode([ObjectPredictionContainer].self, from: data)
    //			DispatchQueue.main.async {
    //				for prediction in decodedResponse.map({ $0.ObjectPrediction }) {
    //					let categoryName = prediction.category.Category.name
    //					if self.predictionsByCategory[categoryName] == nil {
    //						self.predictionsByCategory[categoryName] = []
    //					}
    //					self.predictionsByCategory[categoryName]?.append(prediction)
    //				}
    //			}
    //			print("Predictions by category: \(predictionsByCategory)")
    //		} catch {
    //			print("Failed to decode response: \(error)")
    //		}
    //	}
    //
}

//
//
// "ObjectPrediction": {
//	"bbox": {
//		"BoundingBox": str((bbox.minx, bbox.miny, bbox.maxx, bbox.maxy)),
//		"w": bbox.maxx - bbox.minx,
//		"h": bbox.maxy - bbox.miny
//	},
//	"mask": obj_pred.mask,
//	"score": {
//		"PredictionScore": obj_pred.score.value
//	},
//	"category": {
//		"Category": {
//			"id": obj_pred.category.id,
//			"name": obj_pred.category.name
//		}
//	}
// }

//	func overlayView(uiImage: UIImage, geometry: GeometryProxy) -> some View {
//		print("overlayView(uiImage: UIImage, geometry: GeometryProxy) -> some View")
//		let imageScale = min(geometry.size.width / uiImage.size.width, geometry.size.height / uiImage.size.height)
//		let offsetX = (geometry.size.width - (uiImage.size.width * imageScale)) / 2
//		let offsetY = (geometry.size.height - (uiImage.size.height * imageScale)) / 2
//
//		return ForEach(predictionsByCategory.keys.sorted(), id: \.self) { category in
//			ForEach(predictionsByCategory[category]!, id: \.self) { prediction in
//				let bbox = parseBoundingBox(prediction.bbox.BoundingBox)
//				if bbox.width > 0 && bbox.height > 0 {
//					Rectangle()
//						.stroke(getColor(forCategory: category), lineWidth: 2)
//						.frame(width: bbox.width * imageScale, height: bbox.height * imageScale)
//						.offset(x: (bbox.x * imageScale) + offsetX, y: (bbox.y * imageScale) + offsetY)
//				}
//			}
//		}
//	}
struct ObjectPrediction: Identifiable, Codable {
    let id: Int
    var bbox: String
    var w: Double
    var h: Double
    var score: Double
    var categoryID: Int
    var categoryName: String
}

// Encapsulate each prediction
struct ObjectPredictionContainer: Codable, Hashable {
    let ObjectPrediction: PredictionDetails
}

// Details of each prediction
struct PredictionDetails: Codable, Hashable {
    let bbox: BoundingBox
    let mask: String?
    let score: PredictionScore
    let category: CategoryDetails

    static func == (lhs: PredictionDetails, rhs: PredictionDetails) -> Bool {
        return lhs.category.Category.name == rhs.category.Category.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(category.Category.name)
    }
}

// Bounding box information
struct BoundingBox: Codable, Hashable {
    let BoundingBox: String
    let w: Double
    let h: Double
}

// Score of the prediction
struct PredictionScore: Codable, Hashable {
    let PredictionScore: Double
}

// Category information nested within another "Category" key
struct CategoryDetails: Codable, Hashable {
    let Category: Category
}

// Actual category data
struct Category: Codable, Hashable {
    let id: Int
    let name: String
}
