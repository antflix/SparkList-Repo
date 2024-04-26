//
//  lightsLocator.swift
//  SparkList
//
//
//  ContentView.swift
//  SegmentModelTest
//
//  Created by Anthony on 3/23/24.
//

import CoreML
import SwiftUI
import UIKit
import Vision

struct lightsLocator: View {
	@State private var processedImage: UIImage? = nil

	var body: some View {
		VStack {
			Image(systemName: "globe")
				.imageScale(.large)
				.foregroundStyle(.tint)
			Text("Hello, world!")
			Button(action: {
				if let image = UIImage(named: "ceilings") {
					runInference(on: image, completion: { processedImage in
						// Handle your processed image here
					})
				} else {
					print("Failed to load the image")
				}			}) {
				Text("Run Inference")
					.bold()
			}
			.padding()
			.background(Color(UIColor.systemBackground))  // Supports both light and dark mode
			.foregroundColor(Color(UIColor.label))  // Supports both light and dark mode
			.cornerRadius(8)
			
			if let imageToDisplay = processedImage {
				Image(uiImage: imageToDisplay)
					.resizable()
					.scaledToFit()
			}
		}
	}
	
	func runInference(on inputImage: UIImage, completion: @escaping (UIImage?) -> Void) {
		// Ensure the model is properly loaded
		guard let model = try? VNCoreMLModel(for: newCeilingSeg().model) else {
			fatalError("Failed to load ML model")
		}
		
		let request = VNCoreMLRequest(model: model) { request, error in
			guard error == nil, let results = request.results as? [VNCoreMLFeatureValueObservation],
				  let var_1505 = results.first(where: { $0.featureName == "var_1505" })?.featureValue.multiArrayValue,
				  let p = results.first(where: { $0.featureName == "p" })?.featureValue.multiArrayValue else {
				print("Error during the request or failed to process image")
				completion(nil)
				return
			}
			let maxClasses = 18 // Adjust based on your needs
			var allBoundingBoxes: [[(CGRect, Float)]] = Array(repeating: [], count: maxClasses)
			let iouThreshold: Float = 0.5 // Adjust as necessary
			
			for classIndex in 0..<maxClasses {
				// Assuming `var_1505` is your model output and contains information for bounding boxes across all classes
				let boxesForClass = findAllBoundingBoxesAboveThreshold(for: var_1505, threshold: 0.1, classIndex: classIndex)
				// Apply NMS to each class's bounding boxes
				let filteredBoxesForClass = nonMaximumSuppression(boxes: boxesForClass, iouThreshold: iouThreshold)
				allBoundingBoxes[classIndex] = filteredBoxesForClass
			}
			
			// Proceed with further processing, such as drawing bounding boxes
			// Here you can aggregate all filtered bounding boxes if necessary or keep them separate by class
			DispatchQueue.main.async {
				var finalBoxes: [(CGRect, Float)] = []
				for classBoxes in allBoundingBoxes {
					finalBoxes.append(contentsOf: classBoxes)
				}
				let finalImage = self.overlayMasksOnImage(originalImage: inputImage, boundingBoxes: allBoundingBoxes, imageViewSize: CGSize(width: 640, height: 640))
				completion(finalImage)
			}
		}
		
		// Execute the model request with the provided image
		guard let cgImage = inputImage.cgImage else {
			print("Unable to get CGImage from input image.")
			completion(nil)
			return
		}
		let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
		DispatchQueue.global(qos: .userInitiated).async {
			do {
				try handler.perform([request])
			} catch {
				print("Failed to perform request:", error)
				completion(nil)
			}
		}
	}
	func findAllBoundingBoxesAboveThreshold(for var1504: MLMultiArray, threshold: Float, classIndex: Int) -> [(CGRect, Float)] {
		var boundingBoxes: [(CGRect, Float)] = []
		
		let objectsCount = var1504.shape[2].intValue
		for j in 0..<objectsCount {
			let classProbabilityKey = [0, 4 + classIndex, j] as [NSNumber] // Adjust index for class-specific probability
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
				
				let boundingBox = CGRect(x: CGFloat(boxX), y: CGFloat(boxY), width: CGFloat(boxWidth), height: CGFloat(boxHeight))
				
				// Storing the bounding box along with its class-specific probability
				boundingBoxes.append((boundingBox, classProbability))
			}
		}
		
		return boundingBoxes
	}
	func colorForClassIndex(_ index: Int) -> UIColor {
		let colors: [UIColor] = [
			.red, .green, .blue, .cyan, .orange, .magenta, .orange, .purple, .brown, .black, .lightGray, .blue, .cyan
			// Add more colors as needed, repeating if necessary
		]
		return colors[index % colors.count] // Cycle through colors if there are more classes than colors
	}
	
	func overlayMasksOnImage(originalImage: UIImage, boundingBoxes: [[(CGRect, Float)]], imageViewSize: CGSize) -> UIImage {
		let renderer = UIGraphicsImageRenderer(size: imageViewSize)
		
		let finalImage = renderer.image { context in
			originalImage.draw(in: CGRect(x: 0, y: 0, width: imageViewSize.width, height: imageViewSize.height))
			
			for (classIndex, boxes) in boundingBoxes.enumerated() {
				let color = colorForClassIndex(classIndex).cgColor
				
				context.cgContext.setShouldAntialias(true)
				context.cgContext.setStrokeColor(color)
				context.cgContext.setLineWidth(2.0)
				
				for (boundingBox, _) in boxes {
					context.cgContext.addRect(boundingBox)
				}
				context.cgContext.drawPath(using: .stroke)
			}
		}
		
		return finalImage
	}
	
	
	func nonMaximumSuppression(boxes: [(CGRect, Float)], iouThreshold: Float) -> [(CGRect, Float)] {
		let sortedBoxes = boxes.sorted { $0.1 > $1.1 } // Sort by probability in descending order
		var selectedBoxes = [(CGRect, Float)]()
		
		for (box, score) in sortedBoxes {
			var shouldSelect = true
			for (selectedBox, _) in selectedBoxes {
				let iou = calculateIoU(boxA: box, boxB: selectedBox)
				if iou > iouThreshold {
					shouldSelect = false
					break
				}
			}
			if shouldSelect {
				selectedBoxes.append((box, score))
			}
		}
		
		return selectedBoxes
	}
	
	func calculateIoU(boxA: CGRect, boxB: CGRect) -> Float {
		let intersectionRect = boxA.intersection(boxB)
		let intersectionArea = intersectionRect.width * intersectionRect.height
		let unionArea = boxA.width * boxA.height + boxB.width * boxB.height - intersectionArea
		return Float(intersectionArea / unionArea)
	}
	
}


// Assuming the model and bounding box extraction logic is correct
//			guard let boundingBox = self.findBoundingBoxAndBestMask(for: var_1505) else {
//				print("Failed to find a bounding box")
//				return
//			}
// Assuming the model and bounding box extraction logic is correct

// You need to determine how to select the bestMaskIndex based on your model's specifics
//			let bestMaskIndex = 0 // This should be dynamically determined

////			let maskProbabilities = self.extractMask(from: p, within: boundingBox, imageViewSize: CGSize(width: 640, height: 640), bestMaskIndex: bestMaskIndex)

//			let maskImage = self.drawMask(maskProbabilities: maskProbabilities, imageViewSize: CGSize(width: 640, height: 640))

// Make sure you're on the main thread when updating the UI



//	func findBoundingBoxAndBestMask(for var1504: MLMultiArray) -> CGRect? {
//		guard var1504.shape.count == 3 else {
//			print("Invalid shape for var_1504")
//			return nil
//		}
//
//		let objectsCount = var1504.shape[2].intValue
//		var maxProb: Float = 0
//		var boundingBox: CGRect = .zero
//		var probMaxIdx: Int = 0
//
//		for j in 0..<objectsCount - 1 {
//			let key = [0, 4, j] as [NSNumber]
//			let nextKey = [0, 4, j + 1] as [NSNumber]
//
//			// Ensure the keys are valid to access the MLMultiArray
//			let currentProb = var1504[key].floatValue
//			let nextProb = var1504[nextKey].floatValue
//
//
//			for j in 0..<objectsCount - 1 {
//				let key = [0, 4, j] as [NSNumber]
//				let nextKey = [0, 4, j + 1] as [NSNumber]
//
//				// Directly access the float values without optional binding
//				let currentProb = var1504[key].floatValue
//				let nextProb = var1504[nextKey].floatValue
//
//				if currentProb < nextProb {
//					if maxProb < nextProb {
//						probMaxIdx = j + 1
//						let xKey = [0, 0, probMaxIdx] as [NSNumber]
//						let yKey = [0, 1, probMaxIdx] as [NSNumber]
//						let widthKey = [0, 2, probMaxIdx] as [NSNumber]
//						let heightKey = [0, 3, probMaxIdx] as [NSNumber]
//
//						maxProb = nextProb
//						let boxWidth = var1504[widthKey].floatValue
//						let boxHeight = var1504[heightKey].floatValue
//						let boxX = var1504[xKey].floatValue - (boxWidth / 2)
//						let boxY = var1504[yKey].floatValue - (boxHeight / 2)
//
//						boundingBox = CGRect(
//							x: CGFloat(boxX), y: CGFloat(boxY), width: CGFloat(boxWidth), height: CGFloat(boxHeight)
//						)
//					}
//				}
//			}
//		}
//
//    if maxProb > 0 {
//      // Bounding box with the highest probability found
//      return boundingBox
//    } else {
//      // No valid bounding box found
//      return nil
//    }
//  }
//
//  func sigmoid(z: Float) -> Float {
//    return 1.0 / (1.0 + exp(-z))
//  }

//  func extractMask(
//    from masks: MLMultiArray, within boundingBox: CGRect, imageViewSize: CGSize, bestMaskIndex: Int,
//    maskProbThreshold: Float = 0.5
//  ) -> [[Float]] {
//    let maskWidth = masks.shape[2].intValue
//    let maskHeight = masks.shape[3].intValue
//
//    // Convert bounding box coordinates to match mask dimensions
//    let maskXMin = Int((boundingBox.minX / imageViewSize.width) * CGFloat(maskWidth))
//    let maskXMax = Int((boundingBox.maxX / imageViewSize.width) * CGFloat(maskWidth))
//    let maskYMin = Int((boundingBox.minY / imageViewSize.height) * CGFloat(maskHeight))
//    let maskYMax = Int((boundingBox.maxY / imageViewSize.height) * CGFloat(maskHeight))
//
//    var maskProbabilities: [[Float]] = []
//
//    // Iterate through the mask within the bounding box
//    for y in maskYMin..<maskYMax {
//      var maskProbYAxis: [Float] = []
//      for x in maskXMin..<maskXMax {
//        let pointKey = [0, bestMaskIndex, y, x] as [NSNumber]
//        let probability = sigmoid(z: masks[pointKey].floatValue)
//
//        if probability >= maskProbThreshold {
//          maskProbYAxis.append(1.0)
//        } else {
//          maskProbYAxis.append(0.0)
//        }
//      }
//      maskProbabilities.append(maskProbYAxis)
//    }
//
//    return maskProbabilities
//  }
//
//  func drawMask(maskProbabilities: [[Float]], imageViewSize: CGSize) -> UIImage {
//    let renderer = UIGraphicsImageRenderer(size: imageViewSize)
//
//    let maskImage = renderer.image { context in
//      context.cgContext.setLineWidth(1)
//
//      let xFactor = Float(imageViewSize.width) / 160.0
//      let yFactor = Float(imageViewSize.height) / 160.0
//
//      for y in 0..<maskProbabilities.count {
//        for x in 0..<maskProbabilities[y].count {
//          let maskScaledX = Double(x) * Double(xFactor)
//          let maskScaledY = Double(y) * Double(yFactor)
//
//          if maskProbabilities[y][x] == 1.0 {
//            context.cgContext.setStrokeColor(UIColor.red.withAlphaComponent(0.2).cgColor)
//            context.cgContext.addRect(CGRect(x: maskScaledX, y: maskScaledY, width: 1, height: 1))
//            context.cgContext.drawPath(using: .stroke)
//          }
//        }
//      }
//    }
//
//    return maskImage
//  }

