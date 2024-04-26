
import SwiftUI


import AVFoundation


//
//@available(iOS 17.0, *)
//struct NewProject_Previews: PreviewProvider {
//	static var previews: some View {
//		NewProject()
//	}
//}
//@available(iOS 17.0, *)
//struct blueGradient: View {
//	@State private var gradientA: [Color] = [.black, .blue]
//	@State private var gradientB: [Color] = [.red, .purple]
//	@State private var quadBracketBox = ""
//	@State private var quadGFCI = ""
//	@State private var quadCutIn = ""
//	@State private var quadSurfaceMounted = ""
//	@State private var quadControlled = ""
//	@State private var firstPlane: Bool = true
//	
//	func setGradient(gradient: [Color]) {
//		if firstPlane {
//			
//			gradientB = gradient
//		}
//		else {
//			gradientA = gradient
//		}
//		firstPlane = !firstPlane
//	}
//	@State private var in6FloorDevice = ""
//	@State private var singlePole277V40AInstahot = "hiugiughiui"
//	@State private var pole208V40AInstahot = ""
//	@State private var singlePole277V30AInstahot = ""
//	@State private var selected = 1
//	@State private var goHome = false
//	var body: some View {
//		
//		ZStack {
//			
//			
//			LinearGradient(gradient: Gradient(colors: self.gradientA), startPoint: UnitPoint(x: 0, y: 0), endPoint: UnitPoint(x: 0, y: 1))
//			
//			LinearGradient(gradient: Gradient(colors: self.gradientB), startPoint: UnitPoint(x: 0, y: 0), endPoint: UnitPoint(x: 0, y: 1))
//				.opacity(self.firstPlane ? 0 : 1)
//			
//			
//				.onChange(of: selected, perform: { value in
//					withAnimation(.spring()) {
//						self.setGradient(gradient: [Color.black, Color.blue])
//					}
//				})
//			
//			
//		}
//		.edgesIgnoringSafeArea(.all)
//		.onAppear()
//		.enableInjection()
//	}
//#if DEBUG
//	@ObserveInjection var forceRedraw
//#endif
//}
//
//@available(iOS 17.0, *)
//struct blueGradient_Previews: PreviewProvider {
//	static var previews: some View {
//		blueGradient()
//	}
//}

@available(iOS 17.0, *)
struct blueGradient: View {
	@EnvironmentObject var dataManager: DataManager
	@State private var gradientA: [Color] = [.black, .blue]
	@State private var gradientB: [Color] = [.blue, .black]
	@State private var firstPlane: Bool = true
	
	func setGradient(gradient: [Color]) {
		if firstPlane {
			
			gradientB = gradient
		}
		else {
			gradientA = gradient
		}
		firstPlane = !firstPlane
	}
	@State private var selected = 1
	var body: some View {
		
		ZStack {
			
			
			LinearGradient(gradient: Gradient(colors: self.gradientA), startPoint: UnitPoint(x: 0, y: 0), endPoint: UnitPoint(x: 0, y: 1))
			
			LinearGradient(gradient: Gradient(colors: self.gradientB), startPoint: UnitPoint(x: 0, y: 0), endPoint: UnitPoint(x: 0, y: 1))
				.opacity(self.firstPlane ? 0 : 1)
			
			
			
			
				.onChange(of: selected, perform: { value in
					withAnimation(.spring()) {
						self.setGradient(gradient: [Color.black, dataManager.themeColor])
					}
				})
				.onChange(of: dataManager.themeColor, perform: { _ in // Listen to changes in themeColor
					withAnimation(.spring()) {
						self.setGradient(gradient: [Color.black, dataManager.themeColor]) // Use the updated themeColor
					}
				})
		}
		.edgesIgnoringSafeArea(.all)
		.onAppear {
			// Set actual values after the View has appeared
			gradientA = [.black, dataManager.themeColor]
			gradientB = [dataManager.themeColor, .black]
		}
	}
	
}

import SwiftUI


struct lightblueGradient: View {
	@EnvironmentObject var dataManager: DataManager
	@State private var gradientA: [Color] = [.gray, .blue]
	@State private var gradientB: [Color] = [.gray, .gray]
	@State private var firstPlane: Bool = true
	@State private var selected = 1
	
	
	func setGradient(gradient: [Color]) {
		if firstPlane {
			gradientB = gradient
		}
		else {
			gradientA = gradient
		}
		firstPlane = !firstPlane
	}
	
	var body: some View {
		ZStack {
			LinearGradient(gradient: Gradient(colors: self.gradientA), startPoint: UnitPoint(x: 0, y: 0), endPoint: UnitPoint(x: 0, y: 1))
				.opacity(1)
			
			LinearGradient(gradient: Gradient(colors: self.gradientB), startPoint: UnitPoint(x: 0, y: 0), endPoint: UnitPoint(x: 0, y: 1))
				.opacity(self.firstPlane ? 0 : 1)
			
				.onChange(of: selected, perform: { value in
					withAnimation(.spring()) {
						self.setGradient(gradient: [Color.gray, dataManager.themeColor])
					}
				})
				.onChange(of: dataManager.themeColor, perform: { _ in // Listen to changes in themeColor
					withAnimation(.spring()) {
						self.setGradient(gradient: [Color.gray, dataManager.themeColor]) // Use the updated themeColor
					}
				})
		}
		.edgesIgnoringSafeArea(.all)
		.onAppear {
			// Set actual values after the View has appeared
			gradientA = [.gray, dataManager.themeColor]
			gradientB = [dataManager.themeColor, .gray]
		}
	}
}


@available(iOS 17.0, *)
struct DarkModeLightModeBackground: ViewModifier {
	@EnvironmentObject var dataManager: DataManager
	
	func body(content: Content) -> some View {
		content
			.background(AnyView(Group {
				if dataManager.isDarkMode {
					blueGradient()

				} else {
					lightblueGradient()

				}
			}).transition(.opacity).animation(.easeInOut(duration: 3)))
			.edgesIgnoringSafeArea(.all)
	}
}

//struct blueGradient: View {
//	var body: some View {
//		ZStack {
//			LinearGradient(gradient: Gradient(colors: [.black, .blue]), startPoint: UnitPoint(x: 0, y: 0), endPoint: UnitPoint(x: 0, y: 1))
//
//			LinearGradient(gradient: Gradient(colors: [.red, .purple]), startPoint: UnitPoint(x: 0, y: 0), endPoint: UnitPoint(x: 0, y: 1))
//				.opacity(0) // Initially hidden
//		}
//		.edgesIgnoringSafeArea(.all)
//	}
//}

//struct lightblueGradient: View {
//	var body: some View {
//		ZStack {
//			DarkModeLightModeButton()
//
//			LinearGradient(gradient: Gradient(colors: [.gray, .blue]), startPoint: UnitPoint(x: 0, y: 0), endPoint: UnitPoint(x: 0, y: 1))
//
//			LinearGradient(gradient: Gradient(colors: [Color("FF0080"), Color("7FFFD4")]), startPoint: UnitPoint(x: 0, y: 0), endPoint: UnitPoint(x: 0, y: 1))
//				.opacity(0) // Initially hidden
//		}
//
//		.edgesIgnoringSafeArea(.all)
//	}
//}


@available(iOS 17.0, *)
struct sunview: View {
	@EnvironmentObject var dataManager: DataManager // DataManager should have isDarkMode as @Published
	@Environment(\.colorScheme) var colorScheme
	
	
	@State private var rotateDegree: Double = 0
	
	var body: some View {
		GeometryReader { geometry in
			ZStack {
				Image(systemName: dataManager.isDarkMode ? "moon" : "sun.max")
					.padding(10)
					.font(.title)
					
//					.offset(x: 0, y: -geometry.size.width / 4) // Half the screen width for radius
					.rotationEffect(.degrees(rotateDegree))
					.foregroundStyle(dataManager.isDarkMode ? .gray: .yellow)
					
			}
//			.position(x: geometry.size.width / 2, y: geometry.size.height / 7)
			.position(x: geometry.size.width - 40, y: 20 )
//			.onAppear {
//				dataManager.updateDarkMode(colorScheme: colorScheme)
//			}
			.onTapGesture {
				withAnimation(Animation.easeInOut(duration: 0.5)) {
					dataManager.isDarkMode.toggle()
				}
			}
			.onChange(of: colorScheme) { newColorScheme in
				dataManager.updateDarkMode(colorScheme: newColorScheme)
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
}



