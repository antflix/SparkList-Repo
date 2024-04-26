//
//  SwiftUIView.swift
//  SparkList
//
//  Created by Anthony on 2/25/24.
//

import CoreML
//import FrameUp
import SwiftUI
import UIKit
import UniformTypeIdentifiers
import Vision
import ZoomImageViewer

extension UIColor {
  convenience init(_ color: Color) {
    let uiColor = UIColor(color)
    self.init(cgColor: uiColor.cgColor)
  }
}


private extension CGRect {
	func touches(_ other: CGRect) -> Bool {
		return self.maxX == other.minX || self.minX == other.maxX ||
		self.maxY == other.minY || self.minY == other.maxY
	}
}


struct ModelConfiguration {
  var classIndex: [String: Int]
  var classNames: [Int: String]
  var maxClasses: Int
  var modelName: String
}



let ceilingsConfig = ModelConfiguration(
  classIndex: [
    "2x2": 0,
    "2x4": 1,
    "3-way Switch": 2,
    "Canlight": 3,
    "Ceiling Mounted Motion Sensor": 4,
    "Demo 2x2": 5,
    "Demo 2x4": 6,
    "Demo Canlight": 7,
    "EMG 2x2": 8,
    "EMG 2x4": 9,
    "EMG Canlight": 10,
    "Exit Sign": 11,
    "Line Voltage Switch": 12,
    "Linear": 13,
    "Low Voltage Controlls Switch": 14,
    "Occupency Dimmer Switch": 15,
    "Line Voltage Occupency Sensor": 16,
    "Pendant Light": 17,
  ],
  classNames: [
    0: "2x2", 1: "2x4", 2: "3-way Switch", 3: "Canlight", 4: "Ceiling Mounted Motion Sensor",
    5: "Demo 2x2", 6: "Demo 2x4", 7: "Demo Canlight", 8: "EMG 2x2", 9: "EMG 2x4",
    10: "EMG Canlight", 11: "Exit Sign", 12: "Line Voltage Switch", 13: "Linear",
    14: "Low Voltage Controlls Switch", 15: "Occupancy Dimmer Switch", 16: "Occupancy Sensor",
    17: "Pendant Light",
  ],
  maxClasses: 18,
  modelName: "newCeilingSeg"
)
let wallsConfig = ModelConfiguration(
  classIndex: [
    "Data Box": 0,
    "Dedicated Outlet/GFCI": 1,
    "Duplex Outlet": 2,
    "Floor Box": 3,
    "Furniture Feed": 4,
    "Quad Outlet": 5,
    "TV Box": 6,
  ],
  classNames: [
    0: "Data Box", 1: "Dedicated Outlet", 2: "Duplex Outlet", 3: "Floor Box", 4: "Furniture Feed",
    5: "Quad Outlet", 6: "TV Box",
  ],
  maxClasses: 7,
  modelName: "wallsSeg"
)

struct imagePicker: UIViewControllerRepresentable {
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
    var parent: imagePicker

    init(_ parent: imagePicker) {
      self.parent = parent
    }

    func imagePickerController(
      _ picker: UIImagePickerController,
      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
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
struct LightCounter: View {
	@State private var uiImage: UIImage?
	@State private var uploadedImage: UIImage?
	@State private var confidenceLevel: Double = 0.5
	@State private var tiles = [UIImage]()
	@State private var overlayImages = [UIImage]()
	@State private var results = [ObjectDetectionResult]()
	@State private var uiImage3: UIImage? = nil
	@State private var adjustedImage: UIImage?
	@State private var inputImage: UIImage?
	@State private var finalImage: UIImage?
	@State private var currentConfiguration: ModelConfiguration = wallsConfig  // Default to model 1
	@State private var classCounts: [Int: Int] = [:]
	let tileSize = CGSize(width: 640, height: 640)
	@State private var showingImagePicker = false
	@State private var showingWallCounts = false
	@State private var showingCeilingCounts = true
	@State private var shouldFillBoundingBox: Bool = false
	@State private var showingActionSheet = false
	@State private var showingDetectActionSheet = false
	@State private var showingSidePanel = false
	@State private var countsText: String = ""
	@State private var allBoundingBoxes = [[(CGRect, Int, Float)]]()
	// This will hold bounding boxes for all tiles
	@State private var imageBoxes = [(CGRect, Int, Float)]()  // This will hold bounding boxes for all tiles
	@State private var finalBoundingBoxes = [(CGRect, Int, Float)]()  // This will hold bounding boxes for all tiles

	@State private var classIndexToDisplay: Int?
	@State private var newCountsText: String = ""
	@State private var classIndexCounts: [Int: Int] = [:]  // To hold the count of each class index
	@State private var classIndexCount: [Int: Int] = [:]  // Dictionary to keep track of each classIndex count
	@State private var finalClassCounts = [Int: Int]()
	@State private var boundingBoxCountPerClass: [Int: Int] = [:]

	let classColors: [Int: UIColor] = [
		0: #colorLiteral(red: 1, green: 0.2705882353, blue: 0.2274509804, alpha: 1),  // Red for class 0
		1: #colorLiteral(red: 1, green: 0.2527923882, blue: 1, alpha: 1),  // Green for class 1
		2: #colorLiteral(red: 0.1960784314, green: 0.8431372549, blue: 0.2941176471, alpha: 1),  // Blue for class 2
		3: #colorLiteral(red: 1, green: 1, blue: 0, alpha: 1),  // Yellow for class 3
		4: #colorLiteral(red: 0.2243782282, green: 0.8433842063, blue: 1, alpha: 0.8470588235),  // Purple for class 4
		5: #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1),  // Orange for class 5
		6: #colorLiteral(red: 0.8887704015, green: 0.5829154849, blue: 0.2983494401, alpha: 1),  // Pink for class 6
		7: #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1),  // Brown for class 7
		8: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1),
		9: #colorLiteral(red: 1, green: 0.2156862745, blue: 0.3725490196, alpha: 1),  // Indigo for class 9
		10: #colorLiteral(red: 0.368627451, green: 0.3607843137, blue: 0.9019607843, alpha: 1),  // Cyan for class 10
		11: #colorLiteral(red: 0.4491128325, green: 0.8120071888, blue: 0.5515192747, alpha: 1),  // Teal for class 11
		12: #colorLiteral(red: 0.7610196471, green: 0.3490822315, blue: 0.2630789876, alpha: 1),  // Burgundy for class 12
		13: #colorLiteral(red: 0.3601351678, green: 0.6613553166, blue: 0.8676148057, alpha: 1),  // Olive for class 13
		14: #colorLiteral(red: 0.9431194663, green: 0.8038152456, blue: 0.3371029794, alpha: 1),  // Magenta for class 14
		15: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1),  // Violet for class 15
		16: #colorLiteral(red: 0.7610196471, green: 0.3490822315, blue: 0.2630789876, alpha: 1),
		17: #colorLiteral(red: 0.5807225108, green: 0.066734083, blue: 0, alpha: 1),
		18: #colorLiteral(red: 0.3084011078, green: 0.5618229508, blue: 0, alpha: 1),
		
		// Define more colors for the rest of your classes
		// ...
	]
	//	let classIndex: [String: Int] = ["2x4": 0,
	//									 "3-way Switch": 1,
	//									 "Occupency Dimmer Switch": 2,
	//									 "EMG 2x4": 3,
	//									 "EMG Canlight": 4,
	//									 "Occupency Sensor Switch": 5,
	//									 "Canlight": 6,
	//									 "Demo 2x2": 7,
	//									 "Demo 2x4": 8,
	//									 "Demo Canlight": 9,
	//									 "Low Voltage Controlls Switch": 10,
	//									 "Exit Sign": 11,
	//									 "Linear": 12,
	//									 "Ceiling Mounted Motion Sesnsor": 13,
	//									 "Pendant Light": 14,
	//									 "Line Voltage Switch": 15,
	//									 "data": 16,
	//									 "duplex": 17,
	//									 "quad": 18]
	//	let classNames = [
	//		0: "2x2", 1: "2x4", 2: "3-way Switch", 3: "Canlight", 4: "Ceiling Mounted Motion Sensor", 5: "Demo 2x2", 6: "Demo 2x4", 7: "Demo Canlight", 8: "EMG 2x2", 9: "EMG 2x4", 10: "EMG Canlight", 11: "Exit Sign", 12: "Line Voltage Switch", 13: "Linear", 14: "Low Voltage Controlls Switch", 15: "Occupancy Dimmer Switch", 16: "Occupancy Sensor", 17: "Pendant Light"	]
	var body: some View {
		GeometryReader { proxy in
			ZStack(alignment: .bottomTrailing) {
				Text(countsText)
					.padding()
				
				// Background image (floorplan)
				Spacer()
				ScrollView(.vertical, showsIndicators: true) {
					VStack {
						Spacer()
						// Check if uiImage2 is available
						if let processedImage = adjustedImage {
							// Display the original image with bounding boxes
							Image(uiImage: processedImage)
								.resizable()
								.scaledToFit()
								.onTapGesture {
									uiImage3 = adjustedImage
								}
						} else if let inputImage = adjustedImage {
							// Horizontal ScrollView inside the Vertical ScrollView
							ScrollView(.horizontal, showsIndicators: true) {
								HStack {
									let columns = Int(inputImage.size.width) / Int(tileSize.width)
									LazyVGrid(
										columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: columns),
										spacing: 0
									) {
										ForEach(overlayImages, id: \.self) { overlayImage in
											Image(uiImage: overlayImage)
												.resizable()
												.scaledToFit()
										}
									}
								}
							}
						}
					}
					
				}
				
				///////////////////////////////         SHOW DEVICE COUNTS           ////////////////////////////////
				VStack {
					HStack {
						Spacer()
						if showingCeilingCounts {
							ScrollView(.vertical, showsIndicators: true) {
								VStack(alignment: .leading, spacing: 10) {
									ForEach(Array(finalClassCounts.keys.sorted()), id: \.self) { index in
										if let className = currentConfiguration.classNames[index],
										   let uiColor = classColors[index]
										{
											HStack {
												Rectangle()
													.fill(Color(uiColor))  // Ensure this conversion is correct
													.frame(width: 20, height: 20)
													.border(Color.black, width: 1)
												
												Text("\(className): \(finalClassCounts[index, default: 0])")
													.foregroundColor(.white)  // Adjust text color as needed.
											}
											.onTapGesture {
												// Filter boundingBoxes to only include those with the selected classIndex
												let filteredBoundingBoxes = [finalBoundingBoxes].map { boxes in
													boxes.filter { $0.1 == index }  // Assuming $0.1 is the classIndex in each boundingBox tuple
												}.filter { !$0.isEmpty }  // Remove empty arrays to keep the structure clean
												
												// Now call overlayMasksOnImage with the filtered bounding boxes
												DispatchQueue.main.async {
													boundingBoxCountPerClass = [:]
													loadImage()
													let finalImage = overlayMasksOnImage(
														originalImage: adjustedImage!, boundingBoxes: [finalBoundingBoxes],
														imageViewSize: adjustedImage!.size, classIndexToDisplay: index)
													self.adjustedImage = finalImage
												}
											}
											
										}
									}
								}
								.padding()
								.background(Color.black.opacity(0.5))
								.cornerRadius(10)
							}
							.frame(width: 200, alignment: .top)  // Adjust width as needed
							.padding(.top, proxy.safeAreaInsets.top)  // Adjust for safe area
							.padding(.trailing, 20)  // Right padding
						}
					}
					Spacer()  // Pushes the content to the top
				}
				
				///////////////////////////////              UPLOAD IMAGE/ TAKE PHOTO         //////////////////
				HStack {
					VStack {
						Spacer()
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
										classIndexCounts = [:]  // To hold the count of each class index
										allBoundingBoxes = []
										currentConfiguration = ceilingsConfig
										if let inputImage = self.uiImage {  // Assuming `uiImage` is your input image
											runInference(on: tiles, for: inputImage) { processedImage in
												// `processedImage` is the image with overlays
												// Use this image in your UI
												self.adjustedImage = processedImage
												showingCeilingCounts = true
											}
										}
									},
									.default(Text("Upload Image")) {
										showingImagePicker = true
									},
									.cancel(),
								])
						}
						.padding()
					}
					Spacer()
					///////////////////////////////              UPLOAD IMAGE/ TAKE PHOTO         //////////////////
					VStack {
						Spacer()
						Button(action: {
							self.showingDetectActionSheet = true
						}) {
							Image(systemName: "magnifyingglass")
								.padding()
								.background(Color.blue)
								.foregroundColor(.white)
								.clipShape(Circle())
								.shadow(radius: 3)
						}
						.actionSheet(isPresented: $showingDetectActionSheet) {
							ActionSheet(
								title: Text("Select Action"),
								buttons: [
									.default(Text("Detect Ceilings")) {
										classIndexCounts = [:]
										// To hold the count of each class index
										allBoundingBoxes = []
										currentConfiguration = ceilingsConfig
										if let inputImage = self.uiImage {  // Assuming `uiImage` is your input image
											runInference(on: tiles, for: inputImage) { processedImage in
												// `processedImage` is the image with overlays
												// Use this image in your UI
												self.adjustedImage = processedImage
												showingCeilingCounts = true
											}
										}
									},
									.default(Text("Detect Walls")) {
										classIndexCounts = [:]  // To hold the count of each class index
										allBoundingBoxes = []
										currentConfiguration = wallsConfig
										
										if let inputImage = self.uiImage {  // Assuming `uiImage` is your input image
											runInference(on: tiles, for: inputImage) { processedImage in
												// `processedImage` is the image with overlays
												// Use this image in your UI
												self.adjustedImage = processedImage
												showingCeilingCounts = true
											}
										}
									},
									.cancel(),
								])
						}
						.padding()
					}
				}
				// Sliders and Buttons at the bottom
				//			  VStack {
				//				  Slider(value: $confidenceLevel, in: 0...1, step: 0.1) {
				//					  Text("Confidence Level")
				//				  }
				//				  .padding()
				
				//            HStack {
				//              Toggle("Fill Bounding Box", isOn: $shouldFillBoundingBox)
				//                .padding()
				//              Button("Detect Ceilings") {
				////                classIndexCounts = [:]  // To hold the count of each class index
				////                allBoundingBoxes = []
				////                currentConfiguration = ceilingsConfig
				////                if let inputImage = self.uiImage {  // Assuming `uiImage` is your input image
				////                  runInference(on: tiles, for: inputImage) { processedImage in
				////                    // `processedImage` is the image with overlays
				////                    // Use this image in your UI
				////                    self.adjustedImage = processedImage
				////                    showingCeilingCounts = true
				////                  }
				////                }
				//              }
				//              Button("Detect Walls") {
				////                classIndexCounts = [:]  // To hold the count of each class index
				////                allBoundingBoxes = []
				////                currentConfiguration = wallsConfig
				////
				////                if let inputImage = self.uiImage {  // Assuming `uiImage` is your input image
				////                  runInference(on: tiles, for: inputImage) { processedImage in
				////                    // `processedImage` is the image with overlays
				////                    // Use this image in your UI
				////                    self.adjustedImage = processedImage
				////                    showingCeilingCounts = true
				////                  }
				////                }
				//
				//                //								detectObjects()
				//                //								showingWallCounts = true
				//                //								showingCeilingCounts = false
				//              }
				//
				//              Button("Upload Image") {
				////                showingImagePicker = true
				//              }
				//
				//              //							Button("Download Files") {
				//              //								drawBoundingBoxes(yourDesiredClass: 17)
				//              //							}
				//            }
				//            .padding()
				//          }
				//          .background(Color.white.opacity(0.8))  // Semi-transparent background for controls
				//          .cornerRadius(10)
				//			  }
				
				///////////////////
				
				.overlay(
					Button(action: {
						showingSidePanel.toggle()
						showingWallCounts.toggle()
						showingCeilingCounts.toggle()
					}) {
						Image(systemName: showingWallCounts ? "eye.slash" : "eye")
							.padding()
							.background(Color.white.opacity(0.8))
							.clipShape(Circle())
							.shadow(radius: 3)
					}
						.padding(.top, proxy.safeAreaInsets.top)
						.padding(.trailing, 20),
					alignment: .topTrailing
				)
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
			.gesture(
				DragGesture().onEnded { value in
					if value.translation.height < 0 {  // Corrected: This is actually a swipe up
						withAnimation {
							self.showingSidePanel = true
						}
					} else if value.translation.height > 0 {  // Corrected: This is a swipe down
						withAnimation {
							self.showingSidePanel = false
						}
					}
				})
			
			if showingSidePanel {
				sidepanel
					.frame(height: proxy.size.height * 0.25)
					.transition(.move(edge: .bottom))
					.offset(y: showingSidePanel ? proxy.size.height * 0.75 : proxy.size.height)  // Adjust offset for bottom quarter
			}
		}
		.onAppear {
			loadImage()  // Assuming this function is responsible for preparing the image.
		}
	}
	var sidepanel: some View {
		VStack {
			Toggle("Fill Bounding Box", isOn: $shouldFillBoundingBox)
				.onChange(of: shouldFillBoundingBox) { newValue in
					// Call the method to redraw your bounding boxes when the toggle changes
					DispatchQueue.main.async {
						boundingBoxCountPerClass = [:]
						loadImage()
						let finalImage = overlayMasksOnImage(
							originalImage: adjustedImage!, boundingBoxes: [finalBoundingBoxes],
							imageViewSize: adjustedImage!.size, classIndexToDisplay: nil)
						self.adjustedImage = finalImage
					}
				}
			Text("Confidence Level")
			Slider(value: $confidenceLevel, in: 0...1, step: 0.01).padding()
			
			//				HStack {
			//					Spacer()
			//
			//					ScrollView(.vertical, showsIndicators: true) {
			//						VStack(alignment: .leading, spacing: 10) {
			//							ForEach(Array(classIndexCounts.keys.sorted()), id: \.self) { index in
			//								if let className = currentConfiguration.classNames[index],
			//								   let uiColor = classColors[index]
			//								{
			//									HStack {
			//										Rectangle()
			//											.fill(Color(uiColor))  // Ensure this conversion is correct
			//											.frame(width: 20, height: 20)
			//											.border(Color.black, width: 1)
			//
			//										Text("\(className): \(classIndexCounts[index, default: 0])")
			//											.foregroundColor(.white)  // Adjust text color as needed.
			//									}
			//									.onTapGesture {
			//										// Filter boundingBoxes to only include those with the selected classIndex
			//										let filteredBoundingBoxes = allBoundingBoxes.map { boxes in
			//											boxes.filter { $0.1 == index }  // Assuming $0.1 is the classIndex in each boundingBox tuple
			//										}.filter { !$0.isEmpty }  // Remove empty arrays to keep the structure clean
			//
			//										// Now call overlayMasksOnImage with the filtered bounding boxes
			//										DispatchQueue.main.async {
			//											loadImage()
			//											let finalImage = overlayMasksOnImage(
			//												originalImage: adjustedImage!, boundingBoxes: filteredBoundingBoxes,
			//												imageViewSize: adjustedImage!.size, classIndexToDisplay: index)
			//											self.adjustedImage = finalImage
			//										}
			//									}
			//
			//								}
			//							}
			//						}
			//						.padding()
			//						.background(Color.black.opacity(0.5))
			//						.cornerRadius(10)
			//					}
			//				}.background(Color("Color 7").opacity(0.8))
			
		}
		.background(Color("Color 7").opacity(0.8))
		.padding()
		.cornerRadius(10)
		.shadow(radius: 5)
	}
	

	// Loads the selected image and prepares it for processing
	func loadImage() {
		print("loadImage()")
		guard let inputImage = uploadedImage else { return }
		uiImage = inputImage
		splitImage()
	}
	
	
	
	
	// Splits the input image into smaller tiles for processing
	func splitImage() {
		print("splitImage()")
		guard let inputImage = uiImage else { return }
		// Adjusts the image size to match the tile size and updates the UI
		if let adjustedImage = cropOrPadImageToTileSize(inputImage, tileSize: tileSize) {
			self.adjustedImage = adjustedImage
			uiImage = adjustedImage
			// Splits the adjusted image into tiles with a specified overlap
			tiles = tileImage(uiImage!, tileSize: tileSize, overlap: 0.20).map { $0.0 }
		}
	}
	

	
	
	
	// Adjusts the size of the input image to match the tile size by cropping or padding
	func cropOrPadImageToTileSize(_ image: UIImage, tileSize: CGSize) -> UIImage? {
		print("croporpadimagetoTileSize")
		guard let cgImage = image.cgImage else { return nil }
		// Calculates the new dimensions for the image based on the tile size
		let originalWidth = cgImage.width
		let originalHeight = cgImage.height
		let widthRemainder = originalWidth % Int(tileSize.width)
		let heightRemainder = originalHeight % Int(tileSize.height)
		
		// Always add padding if the image is not the exact size needed
		let newWidth = originalWidth + (Int(tileSize.width) - widthRemainder)
		let newHeight = originalHeight + (Int(tileSize.height) - heightRemainder)
		print(newWidth)
		print(newHeight)
		let sizeChange = CGSize(width: newWidth, height: newHeight)
		
		// Resizes the image by drawing it onto a new context with the calculated dimensions
		UIGraphicsBeginImageContext(sizeChange)
		// Fill the background with a neutral color
		let context = UIGraphicsGetCurrentContext()
		context?.setFillColor(UIColor.white.cgColor) // Set to white or any neutral color
		context?.fill(CGRect(origin: .zero, size: sizeChange))
		
		// Draw the image on top of the neutral background
		image.draw(
			in: CGRect(
				x: (Int(tileSize.width) - widthRemainder) / 2,
				y: (Int(tileSize.height) - heightRemainder) / 2,
				width: originalWidth,
				height: originalHeight))
		
		let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return resizedImage
	}
	
	
	
	
	
	// Splits the input image into smaller tiles with a specified overlap
	func tileImage(_ image: UIImage, tileSize: CGSize, overlap: CGFloat) -> [(UIImage, CGRect)] {
		print("tileImage")
		var tiles = [(UIImage, CGRect)]()
		let cgImage = image.cgImage!
		let width = cgImage.width
		let height = cgImage.height
		let tileWidth = Int(tileSize.width)
		let tileHeight = Int(tileSize.height)
		let overlapWidth = Int(CGFloat(tileWidth) * overlap)
		let overlapHeight = Int(CGFloat(tileHeight) * overlap)
		// Iterates over the image, cropping it into tiles based on the specified overlap
		for y in stride(from: 0, to: height, by: tileHeight - overlapHeight) {
			for x in stride(from: 0, to: width, by: tileWidth - overlapWidth) {
				let tileRect = CGRect(x: x, y: y, width: tileWidth, height: tileHeight)
				if let tileCGImage = cgImage.cropping(to: tileRect) {
					let tileUIImage = UIImage(cgImage: tileCGImage)
					tiles.append((tileUIImage, tileRect))
				}
			}
		}
		return tiles
	}
	//
	//  func tileImage(_ image: UIImage, tileSize: CGSize) -> [UIImage] {
	//    print("tileImage()")
	//
	//    var tiles = [UIImage]()
	//
	//    let cgImage = image.cgImage!
	//
	//    let width = cgImage.width
	//    let height = cgImage.height
	//    //		print("image size: \(width) x \(height)")
	//    let tileWidth = Int(tileSize.width)
	//    let tileHeight = Int(tileSize.height)
	//
	//    for y in stride(from: 0, to: height, by: tileHeight) {
	//      for x in stride(from: 0, to: width, by: tileWidth) {
	//        let tileRect = CGRect(x: x, y: y, width: tileWidth, height: tileHeight)
	//        let tileCGImage = cgImage.cropping(to: tileRect)!
	//        let tileUIImage = UIImage(cgImage: tileCGImage)
	//
	//        tiles.append(tileUIImage)
	//      }
	//    }
	//
	//    return tiles
	//  }
	
	///////////////////////////////////////      LIGHTS     //////////////////////////////////

	
	
	
	// Assuming findAllBoundingBoxesAboveThreshold and nonMaximumSuppression are implemented elsewhere
	// Assuming generateUniqueColors is implemented elsewhere
	// Assuming overlayMasksOnImage is implemented elsewhere
	// Runs inference on the input images using a Core ML model and processes the results
	func runInference(
		on inputImages: [UIImage], for originalImage: UIImage, completion: @escaping (UIImage?) -> Void
	) {
		print("runInference")
		// Selects the appropriate Core ML model based on the current configuration
		let modelToUse: VNCoreMLModel
		switch currentConfiguration.modelName {
			case "newCeilingSeg":
				guard let model = try? VNCoreMLModel(for: newCeilingSeg().model) else {
					fatalError("Failed to load newCeilingSeg model")
				}
				modelToUse = model
			case "wallsSeg":
				guard let model = try? VNCoreMLModel(for: wallsSeg().model) else {
					fatalError("Failed to load wallsSeg model")
				}
				modelToUse = model
			default:
				fatalError("Unknown model name: \(currentConfiguration.modelName)")
		}
		// Proceed with inference using modelToUse
		let model = modelToUse
		let tileSize = CGSize(width: 640, height: 640)
		let overlapPercentage: CGFloat = 0.20  // Assuming 20% overlap, define this according to your usage
		let overlapOffset = tileSize.width * overlapPercentage
		let strideLength = tileSize.width - overlapOffset  // The actual stride length between tiles
		let originalWidth = originalImage.size.width
		let originalHeight = originalImage.size.height

		let tilesPerRow = Int(ceil(originalWidth / strideLength))  // Use ceil to round up to ensure covering the entire width
		let dispatchGroup = DispatchGroup()
		let iouThreshold: Float = 0.5  // Adjust as necessary
		for (index, tileImage) in inputImages.enumerated() {
			dispatchGroup.enter()
			let request = VNCoreMLRequest(model: model) { request, error in
				defer { dispatchGroup.leave() }  // Ensures we leave the group whether we exit early or not
				guard error == nil, let results = request.results as? [VNCoreMLFeatureValueObservation],
					  let var_1505 = results.first(where: { $0.featureName == "var_1505" })?.featureValue
					.multiArrayValue,
					  let p = results.first(where: { $0.featureName == "p" })?.featureValue.multiArrayValue
				else {
					print("Error during the request or failed to process image")
					return
				}
				// Define your boxesForTile with an appropriate structure to include classIndex
				var boxesForTile: [[(CGRect, Int, Float)]] = Array(
					repeating: [], count: currentConfiguration.maxClasses)
				
				for classIndex in 0..<currentConfiguration.maxClasses {
					let boxesForClass = findAllBoundingBoxesAboveThreshold(
						for: var_1505, threshold: Float(confidenceLevel), classIndex: classIndex)
					let filteredBoxesForClass = nonMaximumSuppression(
						boxes: boxesForClass, iouThreshold: iouThreshold)
					boxesForTile[classIndex] = filteredBoxesForClass
				}
				let row = index / tilesPerRow
				let column = index % tilesPerRow
				let xOffset = CGFloat(column) * strideLength
				// yOffset calculations remain unchanged
				// Adjust yOffset calculation to handle the last row correctly
				let isLastRow = row == (inputImages.count / tilesPerRow) - (inputImages.count % tilesPerRow == 0 ? 1 : 0)
				let lastRowHeight = CGFloat(isLastRow ? (Int(originalHeight) % Int(tileSize.height)) : Int(tileSize.height))
				let yOffset = CGFloat(row) * (tileSize.height - overlapOffset) + (isLastRow ? (tileSize.height - lastRowHeight) : 0)
				
				// ... (existing code inside the loop)
				var adjustedBoxesForTile: [(CGRect, Int, Float)] = []
				for classBoxes in boxesForTile {
					for (box, classIndex, confidence) in classBoxes {
						var adjustedBox = box
						adjustedBox.origin.x += xOffset
						adjustedBox.origin.y += yOffset
						adjustedBoxesForTile.append((adjustedBox, classIndex, confidence))
						
						classIndexCounts[classIndex, default: 0] += 1
					}
				}
//				imageBoxes.append(contentsOf: adjustedBoxesForTile)

				allBoundingBoxes.append(contentsOf: [adjustedBoxesForTile])
			}
			let handler = VNImageRequestHandler(cgImage: tileImage.cgImage!, options: [:])
			DispatchQueue.global(qos: .userInitiated).async {
				do {
					try handler.perform([request])
				} catch {
					print("Failed to perform request:", error)
					dispatchGroup.leave()  // Don't forget to leave the group in case of failure
				}
			}
		}
		
		dispatchGroup.notify(queue: .main) {
			// This block is executed after all requests have been processed
			newCountsText = classIndexCounts.sorted(by: { $0.key < $1.key })
				.map { (index, count) -> String in
					let className = currentConfiguration.classNames[index] ?? "Unknown Class (\(index))"
					return "\(className): \(count)"
				}.joined(separator: "\n")
			print(newCountsText)
//			let flat = nonMaximumSuppression(boxes: allBoundingBoxes, iouThreshold: 0.5)
//			print("nonMaxSup has run")
			// Previously applied class-specific NMS
			let flattenedBoundingBoxes = allBoundingBoxes.flatMap { $0.compactMap { $0 } }
//			let finalBoxesAfterNMS = nonMaximumSuppressionPerClass(
//				boxes: flattenedBoundingBoxes, iouThreshold: 0.5)
//			print("nonMaxPerClass has run")
//			// New post-NMS filtering step
//			let strictIouThreshold: Float = 0.5  // More stringent IoU threshold
//			let finalFilteredBoxes = postNMSFiltering(
//				boxes: finalBoxesAfterNMS, strictIouThreshold: strictIouThreshold)
//			print("postNMS has run")
//			
			finalBoundingBoxes = mergeTouchingOrOverlappingBoxes(ofSameClass: flattenedBoundingBoxes)
			print("mergeTouchingorOverlap has run")
			// Initialize a dictionary to hold the count of objects per class index
			
			// Iterate through the filtered boxes and increment the count for each class index
			for (_, classIndex, _) in finalBoundingBoxes {
				finalClassCounts[classIndex, default: 0] += 1
			}
			
			// Now `finalClassCounts` contains the object count per class after filtering
			// You can print or process `finalClassCounts` as needed
			newCountsText = finalClassCounts.sorted(by: { $0.key < $1.key })
				.map { (index, count) -> String in
					
					let className = currentConfiguration.classNames[index] ?? "Unknown Class (\(index))"
					return "\(className): \(count)"
				}.joined(separator: "\n")
			print(newCountsText)
			// Now, `finalFilteredBoxes` contains the bounding boxes after all filtering steps
			let finalImage = overlayMasksOnImage(
				originalImage: originalImage, boundingBoxes: [finalBoundingBoxes],
				imageViewSize: originalImage.size, classIndexToDisplay: nil)
			completion(finalImage)
			// Directly use `originalImage`, as there is no need for optional unwrapping
			//			let boundingBoxesGrouped: [[(CGRect, Int, Float)]] = allBoundingBoxes// Wrap in another array to match expected type
			//			let finalImage = overlayMasksOnImage(originalImage: originalImage, boundingBoxes: boundingBoxesGrouped, imageViewSize: originalImage.size, classIndexToDisplay: nil)
			//			completion(finalImage)
			print("Final image ready. Bounding boxes overlay completed.")
		}
	}
	
	
	
	
	
	// Finds all bounding boxes above a certain confidence threshold for a given class index
	func findAllBoundingBoxesAboveThreshold(
		for var1504: MLMultiArray, threshold: Float, classIndex: Int
	) -> [(CGRect, Int, Float)] {
//		print("findAllBoundingBoxesAboveThreshold")
		var boundingBoxes: [(CGRect, Int, Float)] = []
		let objectsCount = var1504.shape[2].intValue
		for j in 0..<objectsCount {
			let classProbabilityKey = [0, 4 + classIndex, j] as [NSNumber]  // Adjust index for class-specific probability
			let classProbability = var1504[classProbabilityKey].floatValue
			if classProbability >= threshold {
				let probabilityKey = [0, 4, j] as [NSNumber]
				let probability = var1504[probabilityKey].floatValue
				let xKey = [0, 0, j] as [NSNumber]
				let yKey = [0, 1, j] as [NSNumber]
				let widthKey = [0, 2, j] as [NSNumber]
				let heightKey = [0, 3, j] as [NSNumber]
				let boxWidth = var1504[widthKey].floatValue
				let boxHeight = var1504[heightKey].floatValue
				let boxX = var1504[xKey].floatValue - (boxWidth / 2)
				let boxY = var1504[yKey].floatValue - (boxHeight / 2)
				let boundingBox = CGRect(
					x: CGFloat(boxX), y: CGFloat(boxY), width: CGFloat(boxWidth), height: CGFloat(boxHeight))
				// Storing the bounding box along with its class-specific probability
				boundingBoxes.append((boundingBox, classIndex, classProbability))
			}
		}
		return boundingBoxes
	}
	
	
	
	
	// Applies non-maximum suppression to filter out overlapping bounding boxes
	func nonMaximumSuppression(boxes: [(CGRect, Int, Float)], iouThreshold: Float) -> [(
		CGRect, Int, Float
	)] {
print("nonMaximumSuppression()")
		let sortedBoxes = boxes.sorted { $0.1 > $1.1 }  // Sort by probability in descending order
		var selectedBoxes = [(CGRect, Int, Float)]()
		for (box, index, score) in sortedBoxes {
			var shouldSelect = true
			for (selectedBox, _, _) in selectedBoxes {
				let iou = calculateIoU(boxA: box, boxB: selectedBox)
				if iou > iouThreshold {
					shouldSelect = false
					break
				}
			}
			if shouldSelect {
				selectedBoxes.append((box, index, score))
			}
		}
		return selectedBoxes
	}
	
	
	
	// Calculates the Intersection over Union (IoU) between two bounding boxes
	func calculateIoU(boxA: CGRect, boxB: CGRect) -> Float {
		let intersectionRect = boxA.intersection(boxB)
		let intersectionArea = intersectionRect.width * intersectionRect.height
		let unionArea = boxA.width * boxA.height + boxB.width * boxB.height - intersectionArea
		return Float(intersectionArea / unionArea)
	}
	
	
	
	// Applies non-maximum suppression per class to filter out overlapping bounding boxes for each class
	func nonMaximumSuppressionPerClass(boxes: [(CGRect, Int, Float)], iouThreshold: Float) -> [(
		CGRect, Int, Float
	)] {
		print("nonMaxSupPerClass")
		var resultsByClass = [Int: [(CGRect, Int, Float)]]()
		// Group boxes by class
		for box in boxes {
			let classIndex = box.1
			resultsByClass[classIndex, default: []].append(box)
		}
		// Apply NMS per class
		var finalResults = [(CGRect, Int, Float)]()
		for (_, boxesInClass) in resultsByClass {
			let selectedBoxes = nonMaximumSuppression(boxes: boxesInClass, iouThreshold: iouThreshold)
			finalResults.append(contentsOf: selectedBoxes)
		}
		return finalResults
	}
	
	
	
	
	
	// Filters bounding boxes after non-maximum suppression using a stricter IoU threshold
	func postNMSFiltering(boxes: [(CGRect, Int, Float)], strictIouThreshold: Float) -> [(
		CGRect, Int, Float
	)] {
		print("postNMSFiltering")
		var filteredBoxes = boxes
		var index = 0
		while index < filteredBoxes.count {
			let currentBox = filteredBoxes[index]
			filteredBoxes = filteredBoxes.enumerated().filter { (idx, box) -> Bool in
				if idx <= index { return true }  // Skip already checked boxes
				let iou = calculateIoU(boxA: currentBox.0, boxB: box.0)
				return iou <= strictIouThreshold
			}.map { $0.element }
			index += 1
		}
		return filteredBoxes
	}
	
	
	
	
	
	
	
	// Overlays masks on the original image based on the bounding boxes and class index to display
	func overlayMasksOnImage(
		originalImage: UIImage, boundingBoxes: [[(CGRect, Int, Float)]], imageViewSize: CGSize,
		classIndexToDisplay: Int?
	) -> UIImage {
		boundingBoxCountPerClass = [:]

		print("overlayMasksOnImage accessed")
		let renderer = UIGraphicsImageRenderer(size: imageViewSize)
		let boundingBoxesWithData: [BoundingBoxData] = boundingBoxes.flatMap { $0 }.map { tuple in
			BoundingBoxData(boundingBox: tuple.0, classIndex: tuple.1, confidence: tuple.2)
		}
		
		let sortedBoundingBoxes = boundingBoxesWithData.sorted {
			if $0.boundingBox.origin.y != $1.boundingBox.origin.y {
				return $0.boundingBox.origin.y < $1.boundingBox.origin.y
			} else {
				return $0.boundingBox.origin.x < $1.boundingBox.origin.x
			}
		}
		for (index, boxData) in sortedBoundingBoxes.enumerated() {
			print("Box \(index): \(boxData.boundingBox), Class: \(boxData.classIndex)")
		}
		
		let finalImage = renderer.image { context in
			originalImage.draw(
				in: CGRect(x: 0, y: 0, width: imageViewSize.width, height: imageViewSize.height))
			print(boundingBoxes)
			
			// Iterate through sorted bounding boxes and draw them
			// Inside overlayMasksOnImage function
			// Inside overlayMasksOnImage function
			for boundingBoxData in sortedBoundingBoxes {
				// Debug print to check the current count for the class
				let currentCount = boundingBoxCountPerClass[boundingBoxData.classIndex, default: 0]
				print("Class \(boundingBoxData.classIndex) current count: \(currentCount)")
				
				drawBoundingBox(
					context: context,
					boundingBox: boundingBoxData.boundingBox,
					classIndex: boundingBoxData.classIndex
				)
				
				// Increment the count after drawing
				boundingBoxCountPerClass[boundingBoxData.classIndex] = currentCount + 1
			}
		
		}
		return finalImage
	}
	
	func mergeTouchingOrOverlappingBoxes(ofSameClass boxes: [(CGRect, Int, Float)]) -> [(CGRect, Int, Float)] {
		var mergedBoxes = [(CGRect, Int, Float)]()
		var usedIndices = Set<Int>()
		
		for (i, boxInfo) in boxes.enumerated() {
			guard !usedIndices.contains(i) else { continue }
			var (currentBox, classIndex, confidence) = boxInfo
			var mergeOccurred = false
			
			repeat {
				mergeOccurred = false
				for (j, otherBoxInfo) in boxes.enumerated() where i != j && !usedIndices.contains(j) && otherBoxInfo.1 == classIndex {
					let (otherBox, _, _) = otherBoxInfo
					if currentBox.intersects(otherBox) || currentBox.touches(otherBox) {
						currentBox = currentBox.union(otherBox)
						confidence = max(confidence, otherBoxInfo.2) // Take the highest confidence
						usedIndices.insert(j)
						mergeOccurred = true
					}
				}
			} while mergeOccurred
			
			usedIndices.insert(i)
			mergedBoxes.append((currentBox, classIndex, confidence))
		}
		
		return mergedBoxes
	}
	
	// Draws a bounding box on the image context with a specified class color and count
	func drawBoundingBox(
		context: UIGraphicsImageRendererContext, boundingBox: CGRect, classIndex: Int
	) {
//		print("drawBoundingBoxes accessed")

		guard let uiColor = classColors[classIndex] else { return }
		let currentCount = boundingBoxCountPerClass[classIndex, default: 0]
		// Increment the count for the current classIndex
		boundingBoxCountPerClass[classIndex] = currentCount + 1


		// Get the current count for classIndex
		
		var slightlyOpaqueUIColor = uiColor.withAlphaComponent(1.0)  // Adjust the alpha component as needed
		
		context.cgContext.setShouldAntialias(true)
		context.cgContext.setStrokeColor(uiColor.cgColor)
		// Set the slightly opaque color as the fill color based on the shouldFillBoundingBox state
		if shouldFillBoundingBox {
			context.cgContext.setFillColor(slightlyOpaqueUIColor.cgColor)
			slightlyOpaqueUIColor = uiColor.withAlphaComponent(1.0)
		} else {
			slightlyOpaqueUIColor = uiColor.withAlphaComponent(1.0)  // Adjust the alpha component as needed
			
			// If not filling, set a clear fill color
			context.cgContext.setFillColor(UIColor.clear.cgColor)
		}
		context.cgContext.setLineWidth(1.0)
		context.cgContext.addRect(boundingBox)
		context.cgContext.drawPath(using: .fillStroke)
		
		let textAttributes: [NSAttributedString.Key: Any] = [
			.font: UIFont.systemFont(ofSize: 12),
			.foregroundColor: UIColor.black
			
		]
		let countString = "\(currentCount + 1)" // Increment before drawing
		let textHeight: CGFloat = 20
		// Define the width of the text rectangle, you might want to adjust this based on the expected text width
		let textWidth: CGFloat = 30
		
		// Set the textRect to the left of the boundingBox
		let textRect = CGRect(
			x: boundingBox.origin.x, // Position the text at the x origin of the boundingBox
			y: boundingBox.origin.y - textHeight, // Position the text above the boundingBox
			width: textWidth,
			height: textHeight
		)
		let attributedString = NSAttributedString(string: countString, attributes: textAttributes)
		attributedString.draw(in: textRect)
	}
	struct BoundingBoxData {
		let boundingBox: CGRect
		let classIndex: Int
		let confidence: Float
		// Add other properties if necessary
		
		init(boundingBox: CGRect, classIndex: Int, confidence: Float) {
			self.boundingBox = boundingBox
			self.classIndex = classIndex
			self.confidence = confidence
		}
	}
//
//	
//
//	
//	1. **`loadImage()`**
//	- Calls `splitImage()`
//	- Returns: Nothing (`Void`)
//	- Usage: This function does not directly return a value. It sets the `uiImage` state variable and calls `splitImage()` for further processing.
//		
//		
//		
//		2. **`splitImage()`**
//		- Calls `cropOrPadImageToTileSize(_ tileSize:)`
//		- Calls `tileImage(_: tileSize: overlap:)`
//		- Returns: Nothing (`Void`)
//		- Usage: This function does not directly return a value. It sets the `tiles` state variable with the array of tiled UIImage objects for inference.
//			
//			
//			
//			// Adjusts the size of the input image to match the tile size by cropping or padding
//			func cropOrPadImageToTileSize(_ image: UIImage, tileSize: CGSize) -> UIImage? {
//				- No function calls to others within its code.
//				- Returns: An optional `UIImage` (`UIImage?`)
//				- Usage: It adjusts the `uiImage` to match the tile size and returns the modified image, which is then set to the `adjustedImage` state variable and used for tiling.
//																																												
//																																												
//																																												
//																																												// Splits the input image into smaller tiles with a specified overlap
//																																												func tileImage(_ image: UIImage, tileSize: CGSize, overlap: CGFloat) -> [(UIImage, CGRect)] {
//					- No function calls to others within its code.
//					- Returns: An array of tuples, each containing a `UIImage` and its corresponding `CGRect` (`[(UIImage, CGRect)]`)
//					- Usage: It produces an array of tiles and their positions from the adjusted image. The tiles (`UIImage`) are used as input for the `runInference` function.
//																																						
//																																						
//																																						
//																																						// Runs inference on the input images using a Core ML model and processes the results
//																																						func runInference(on inputImages: [UIImage], for originalImage: UIImage, completion: @escaping (UIImage?) -> Void)
//																																						- Calls `findAllBoundingBoxesAboveThreshold(for: threshold: classIndex:)`
//																																						- Calls `nonMaximumSuppression(boxes: iouThreshold:)`
//																																						- Calls `nonMaximumSuppressionPerClass(boxes: iouThreshold:)`
//																																						- Calls `postNMSFiltering(boxes: strictIouThreshold:)`
//																																						- Calls `overlayMasksOnImage(originalImage: boundingBoxes: imageViewSize: classIndexToDisplay:)`
//																																						- Returns: Nothing directly. The result is passed through a completion handler: (`(UIImage?) -> Void`)
//																																						- Usage: Runs the model inference on the input tiles and processes the results to overlay on the original image, then calls the completion handler with the final image containing the overlaid bounding boxes.
//																																						
//																																						
//																																						
//																																						// Finds all bounding boxes above a certain confidence threshold for a given class index
//																																						func findAllBoundingBoxesAboveThreshold(for var1504: MLMultiArray, threshold: Float, classIndex: Int) -> [(CGRect, Int, Float)] {
//						- No function calls to others within its code.
//						- Returns: An array of tuples, each containing a `CGRect`, an `Int` class index, and a `Float` confidence (`[(CGRect, Int, Float)]`)
//						- Usage: Finds all bounding boxes with a confidence above a threshold for a given class index and returns them to be used in non-maximum suppression within `runInference`.
//																									
//																									
//																									
//																									// Applies non-maximum suppression to filter out overlapping bounding boxes
//																									func nonMaximumSuppression(boxes: [(CGRect, Int, Float)], iouThreshold: Float) -> [(CGRect, Int, Float)] {
//							- Calls `calculateIoU(boxA: boxB:)`
//							- Returns: An array of tuples, each containing a `CGRect`, an `Int` class index, and a `Float` confidence (`[(CGRect, Int, Float)]`)
//							- Usage: Filters bounding boxes to remove overlaps and returns the filtered list to be used in `runInference` for further processing.
//																																				
//																																				
//																																				
//																																				
//																																				// Calculates the Intersection over Union (IoU) between two bounding boxes
//																																				func calculateIoU(boxA: CGRect, boxB: CGRect) -> Float {
//								// Placeholder for the implementation of IoU calculation
//								// ...
//							}	- No function calls to others within its code.
//							- Returns: A `Float` representing the Intersection over Union value
//							- Usage: Called by `nonMaximumSuppression` and `postNMSFiltering` to calculate the IoU between two bounding boxes to determine if they overlap.
//																																								
//																																								
//																																								
//																																								// Applies non-maximum suppression per class to filter out overlapping bounding boxes for each class
//																																								func nonMaximumSuppressionPerClass(boxes: [(CGRect, Int, Float)], iouThreshold: Float) -> [(CGRect, Int, Float)] {
//								- Calls `nonMaximumSuppression(boxes: iouThreshold:)`
//								- Returns: An array of tuples, each containing a `CGRect`, an `Int` class index, and a `Float` confidence (`[(CGRect, Int, Float)]`)
//								- Usage: Groups bounding boxes by class and applies non-maximum suppression to each group. The result is used in `runInference` to remove overlaps before overlaying the boxes on the original image.
//								
//								
//								
//								
//								
//								// Filters bounding boxes after non-maximum suppression using a stricter IoU threshold
//								func postNMSFiltering(boxes: [(CGRect, Int, Float)], strictIouThreshold: Float) -> [(CGRect, Int, Float)] {	- Calls `calculateIoU(boxA: boxB:)`
//									- Returns: An array of tuples, each containing a `CGRect`, an `Int` class index, and a `Float` confidence (`[(CGRect, Int, Float)]`)
//									- Usage: Applies additional filtering after non-maximum suppression using a stricter IoU threshold. The result is used in `runInference` to produce the final set of bounding boxes for overlay.
//																																																								
//																																																								
//																																																								
//																																																								
//																																																								// Overlays masks on the original image based on the bounding boxes and class index to display
//																																																								func overlayMasksOnImage(originalImage: UIImage, boundingBoxes: [[(CGRect, Int, Float)]], imageViewSize: CGSize, classIndexToDisplay: Int?) -> UIImage {
//										- Calls `drawBoundingBox(context: boundingBox: classIndex:)`
//										- Returns: A `UIImage`
//										- Usage: Uses the final filtered bounding boxes to draw overlays on the original image and returns the final image with overlays. This image is used as the completion result in `runInference`.
//										
//										
//										
//										
//										// Draws a bounding box on the image context with a specified class color and count
//										func drawBoundingBox(context: UIGraphicsImageRendererContext, boundingBox: CGRect, classIndex: Int) {	- No function calls to others within its code.
//											- Returns: Nothing (`Void`)
//											- Usage: Called by `overlayMasksOnImage` to actually draw each bounding box onto the image context.
//											
//											
//											
//											
//	func randomColor() -> UIColor {
//		print("randomColor()")
//		
//		// Generates random colors by randomizing the RGB components.
//		let red = CGFloat.random(in: 0...1)
//		let green = CGFloat.random(in: 0...1)
//		let blue = CGFloat.random(in: 0...1)
//		return UIColor(red: red, green: green, blue: blue, alpha: 2.0)
//	}
//	
//	func generateUniqueColors(count: Int) -> [UIColor] {
//		print("generate unique colors")
//		var colors: [UIColor] = []
//		for _ in 0..<count {
//			let color = randomColor()
//			colors.append(color)
//		}
//		return colors
//	}
//	
//	
//	// Converts UIColor to SwiftUI Color
//	func convertToColor(_ uiColor: UIColor) -> Color {
//		print("convertToColor")
//		
//		return Color(uiColor)
//	}
//	
//	
//	Certainly! Below is the list of functions within the `LightCounter` struct, along with their return types and how the main function, `runInference`, uses the returned objects:
//	
//	1. **`loadImage()`**
//	- Returns: Nothing (`Void`)
//	- Usage: This function does not directly return a value. It sets the `uiImage` state variable and calls `splitImage()` for further processing.
//		
//		2. **`splitImage()`**
//		- Returns: Nothing (`Void`)
//		- Usage: This function does not directly return a value. It sets the `tiles` state variable with the array of tiled UIImage objects for inference.
//			
//			3. **`cropOrPadImageToTileSize(_:tileSize:)`**
//			- Returns: An optional `UIImage` (`UIImage?`)
//			- Usage: It adjusts the `uiImage` to match the tile size and returns the modified image, which is then set to the `adjustedImage` state variable and used for tiling.
//				
//				4. **`tileImage(_:tileSize:overlap:)`**
//				- Returns: An array of tuples, each containing a `UIImage` and its corresponding `CGRect` (`[(UIImage, CGRect)]`)
//				- Usage: It produces an array of tiles and their positions from the adjusted image. The tiles (`UIImage`) are used as input for the `runInference` function.
//					
//					5. **`runInference(on:for:completion:)`**
//					- Returns: Nothing directly. The result is passed through a completion handler: (`(UIImage?) -> Void`)
//					- Usage: Runs the model inference on the input tiles and processes the results to overlay on the original image, then calls the completion handler with the final image containing the overlaid bounding boxes.
//					
//					6. **`findAllBoundingBoxesAboveThreshold(for:threshold:classIndex:)`**
//					- Returns: An array of tuples, each containing a `CGRect`, an `Int` class index, and a `Float` confidence (`[(CGRect, Int, Float)]`)
//					- Usage: Finds all bounding boxes with a confidence above a threshold for a given class index and returns them to be used in non-maximum suppression within `runInference`.
//						
//						7. **`nonMaximumSuppression(boxes:iouThreshold:)`**
//						- Returns: An array of tuples, each containing a `CGRect`, an `Int` class index, and a `Float` confidence (`[(CGRect, Int, Float)]`)
//						- Usage: Filters bounding boxes to remove overlaps and returns the filtered list to be used in `runInference` for further processing.
//							
//							8. **`calculateIoU(boxA:boxB:)`**
//							- Returns: A `Float` representing the Intersection over Union value
//							- Usage: Called by `nonMaximumSuppression` and `postNMSFiltering` to calculate the IoU between two bounding boxes to determine if they overlap.
//								
//								9. **`nonMaximumSuppressionPerClass(boxes:iouThreshold:)`**
//								- Returns: An array of tuples, each containing a `CGRect`, an `Int` class index, and a `Float` confidence (`[(CGRect, Int, Float)]`)
//								- Usage: Groups bounding boxes by class and applies non-maximum suppression to each group. The result is used in `runInference` to remove overlaps before overlaying the boxes on the original image.
//								
//								10. **`postNMSFiltering(boxes:strictIouThreshold:)`**
//								- Returns: An array of tuples, each containing a `CGRect`, an `Int` class index, and a `Float` confidence (`[(CGRect, Int, Float)]`)
//								- Usage: Applies additional filtering after non-maximum suppression using a stricter IoU threshold. The result is used in `runInference` to produce the final set of bounding boxes for overlay.
//									
//									11. **`overlayMasksOnImage(originalImage:boundingBoxes:imageViewSize:classIndexToDisplay:)`**
//									- Returns: A `UIImage`
//									- Usage: Uses the final filtered bounding boxes to draw overlays on the original image and returns the final image with overlays. This image is used as the completion result in `runInference`.
//									
//									12. **`drawBoundingBox(context:boundingBox:classIndex:)`**
//									- Returns: Nothing (`Void`)
//									- Usage: Called by `overlayMasksOnImage` to actually draw each bounding box onto the image context.
//									
//									Each of these functions plays a role in processing the image, detecting objects, and ultimately overlaying the detection results back onto the original image. The `runInference` function orchestrates these steps by calling the appropriate sub-functions and handling their returned values to construct the final image with detection overlays.
}
  //
  //	private func drawBoundingBox(
  //		context: UIGraphicsImageRendererContext, boundingBox: CGRect,
  //		classIndex: Int, objectOrder: Int
  //	) {
  //
  //		// Existing code to set up the bounding box appearance
  //		guard let uiColor = classColors[classIndex] else { return }
  //		print("drawBoundingBoxes accessed")
  //
  //		var slightlyOpaqueUIColor = uiColor.withAlphaComponent(1.0)  // Adjust the alpha component as needed
  //
  //		context.cgContext.setShouldAntialias(true)
  //		context.cgContext.setStrokeColor(uiColor.cgColor)
  //		// Set the slightly opaque color as the fill color based on the shouldFillBoundingBox state
  //		if shouldFillBoundingBox {
  //			context.cgContext.setFillColor(slightlyOpaqueUIColor.cgColor)
  //			slightlyOpaqueUIColor = uiColor.withAlphaComponent(1.0)
  //		} else {
  //			slightlyOpaqueUIColor = uiColor.withAlphaComponent(1.0)  // Adjust the alpha component as needed
  //
  //			// If not filling, set a clear fill color
  //			context.cgContext.setFillColor(UIColor.clear.cgColor)
  //		}
  //		context.cgContext.setLineWidth(1.0)
  //		context.cgContext.addRect(boundingBox)
  //		context.cgContext.drawPath(using: .fillStroke)
  //	}
  
 

//	func overlayMasksOnImage(originalImage: UIImage, boundingBoxes: [[(CGRect, Int, Float)]], imageViewSize: CGSize, classIndexToDisplay: Int?) -> UIImage {
//		let renderer = UIGraphicsImageRenderer(size: imageViewSize)
//		// Assuming generateUniqueColors(count:) returns an array with a color for each class
//		let classColors = generateUniqueColors(count: 18) // Adjust the count based on your actual number of classes
//		print(classIndexToDisplay as Any)
//		let finalImage = renderer.image { context in
//			originalImage.draw(in: CGRect(x: 0, y: 0, width: imageViewSize.width, height: imageViewSize.height))
//
//			for boxes in boundingBoxes {
//				for (boundingBox, classIndex, _) in boxes {
//					// Filter by classIndexToDisplay if it is not nil
//					print(classIndexToDisplay as Any)
//					if let classIndexToDisplay = classIndexToDisplay, classIndexToDisplay != classIndex {
//						continue
//					}
//					print(classIndex)
//
//					// Directly check if classIndex is within bounds of classColors array
//					if classIndex >= 0, classIndex < classColors.count {
//						let color = classColors[classIndex] // Access the color directly using classIndex
//						context.cgContext.setShouldAntialias(true)
//						context.cgContext.setStrokeColor(color.cgColor)
//						context.cgContext.setLineWidth(2.0)
//						context.cgContext.addRect(boundingBox)
//						context.cgContext.drawPath(using: .stroke)
//					}
//				}
//			}
//		}
//
//		return finalImage
//	}

// Example usage:
// Assuming you've already processed your images and have a set of bounding boxes (allBoundingBoxes),
// and you want to display only bounding boxes for class index 2 on the finalImage:

// Adjust your SwiftUI view to use finalImage where you currently use processedImage or inputImage

struct swiftUIView: View {
  var body: some View {
    Text( /*@START_MENU_TOKEN@*/"Hello, World!" /*@END_MENU_TOKEN@*/)
  }
}

#Preview{
  swiftUIView()
}

