//
//  extractImages.swift
//  SparkList
//
//  Created by Anthony on 3/12/24.
//
import SwiftUI
import PDFKit
import SwiftUI

struct PDFImagesView: View {
	@State private var images: [UIImage] = []
	
	var body: some View {
		VStack {
			ScrollView {
				if images.isEmpty {
					Text("Press the button to load images.")
				} else {
					// Display the full-page image
					Image(uiImage: images[0])
						.resizable()
						
						
					
					// Display the grid images
					ForEach(1..<images.count, id: \.self) { index in
						Image(uiImage: images[index])
							.resizable()
							.padding()
					}
				}
			}
			
			Button("Load Images") {
				// Assume you have a URL for your PDF here
				let pdfURL = Bundle.main.url(forResource: "pdf", withExtension: "pdf")!
				
				// Call your extract images function
				if let extractedImages = extractImages(from: pdfURL, fixedHeight: 1000) {
					self.images = extractedImages
				}
			}
			.padding()
			.background(Color.blue)
			.foregroundColor(.white)
			.cornerRadius(10)
		}
	}
	
	func extractImages(from pdfURL: URL, fixedHeight: CGFloat) -> [UIImage]? {
		guard let document = PDFDocument(url: pdfURL) else { return nil }
		var extractedImages: [UIImage] = []
		
		for pageIndex in 0..<document.pageCount {
			guard let page = document.page(at: pageIndex) else { continue }
			let pageRect = page.bounds(for: .mediaBox)
			// Calculate the width that maintains the aspect ratio with the fixed height
			let aspectRatio = pageRect.width / pageRect.height
			let calculatedWidth = fixedHeight * aspectRatio
			let outputSize = CGSize(width: calculatedWidth, height: fixedHeight)
			// Extract the full-page image
			let fullPageImage = extractImage(from: page, with: pageRect, scaledTo: outputSize)
			extractedImages.append(fullPageImage)

			// Divide the page into a 4x4 grid and extract images from each section
			let rows = 2
			let cols = 2
			let sectionWidth = pageRect.width / CGFloat(cols)
			let sectionHeight = pageRect.height / CGFloat(rows)
			
			for row in 0..<rows {
				for col in 0..<cols {
					let sectionRect = CGRect(x: CGFloat(col) * sectionWidth,
											 y: CGFloat(row) * sectionHeight,
											 width: sectionWidth,
											 height: sectionHeight)
					let sectionImage = extractImage(from: page, with: sectionRect, scaledTo: outputSize)
					extractedImages.append(sectionImage)
				}
			}
		}
		return extractedImages
	}
}

func extractImage(from page: PDFPage, with rect: CGRect, scaledTo size: CGSize) -> UIImage {
	let renderer = UIGraphicsImageRenderer(size: size)
	return renderer.image { ctx in
		UIColor.white.set()
		ctx.fill(CGRect(origin: .zero, size: size))
		ctx.cgContext.translateBy(x: 0.0, y: size.height)
		ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
		ctx.cgContext.scaleBy(x: size.width / rect.width, y: size.height / rect.height)
		page.draw(with: .mediaBox, to: ctx.cgContext)
	}
}
