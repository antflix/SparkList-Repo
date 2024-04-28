//
//  StartView.swift
//  SparkTime
//
//  Created by User on 12/31/23.
//

//
//  userInput.swift
//  Material
//
//  Created by User on 12/29/23.


import SwiftUI
import SwiftUI
import SwiftUI
@available(iOS 17.0, *)
struct StartView: View {
	@State private var isPopupVisible = false
	@State private var symbolAnimation = false

	var body: some View {
		VStack {
			VStack {
				// Header
				Text("Sparklists")
					.padding(.horizontal)
					.foregroundStyle(Color.white)
					.font(Font.custom("Quicksand", size: 60))
					.frame(maxWidth: .infinity * 0.90, alignment: .center)

				Text("The best apprentace you'll ever hire.")
					.foregroundStyle(Color.white)
					.font(Font.custom("Quicksand", size: 10).bold())
					.frame(maxWidth: .infinity * 0.90, alignment: .center)


				//				AnimatedGradientDivider()
			}.padding(.vertical, 30)
			Divider().frame(height: 1.0).background(
				Color(dataManager.themeColor)
			).padding(.vertical, 1)
			// Buttons for different options
			Spacer()
			VStack {
				Spacer()
				NavigationLink(destination: MaterialListView()) {
					Text("Generate Material List")
						.foregroundStyle(Color.white)
						.padding(.top, 20)
						.padding(.bottom, 20)
						.frame(maxWidth: .infinity, alignment: .center)
						.background(Color("button1"))
						.cornerRadius(5)
						.shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
					
				}
				.buttonStyle(PlainButtonStyle())

				.padding(.horizontal, 0)
				.padding(.top, 0)
				.padding(.bottom, 5)
				.frame(maxWidth: .infinity, alignment: .topLeading)
				
//				Button(action: {
//					// Action for View or Edit Existing Project
//				}) {
//					Text("View/Edit Project")
//						.foregroundStyle(Color.white)
//						.padding(.top, 20)
//						.padding(.bottom, 20)
//						.frame(maxWidth: .infinity, alignment: .center)
//						.background(Color("button2"))
//						.cornerRadius(5)
//						.shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
//				}
//				.buttonStyle(PlainButtonStyle())
//
//				.padding(.horizontal, 0)
//				.padding(.top, 0)
//				.padding(.bottom, 5)
//				.frame(maxWidth: .infinity, alignment: .topLeading)
//				Button(action: {
//					// Action for Quick Material List
//				}) {
//					Text("Quick Material List ")
//						.foregroundStyle(Color.white)
//						.padding(.top, 20)
//						.padding(.bottom, 20)
//						.frame(maxWidth: .infinity, alignment: .center)
//						.background(Color("button3"))
//						.cornerRadius(5)
//						.shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
//					
//				}
//				.buttonStyle(PlainButtonStyle())
//
//				.padding(.horizontal, 0)
//				.padding(.top, 0)
//				.padding(.bottom, 5)
//				.frame(maxWidth: .infinity, alignment: .topLeading)
				Spacer()
				NavigationLink(destination: SwipingTimeView()) {
					Text("Swiping Time View")
						.foregroundStyle(Color.white)
						.padding(.top, 20)
						.padding(.bottom, 20)
						.frame(maxWidth: .infinity, alignment: .center)
						.background(Color("button1"))
						.cornerRadius(5)
						.shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)

				}
				.buttonStyle(PlainButtonStyle())

				.padding(.horizontal, 0)
				.padding(.top, 0)
				.padding(.bottom, 5)
				.frame(maxWidth: .infinity, alignment: .topLeading)

Spacer()
				NavigationLink(destination: JobsView()) {
					Text("Time Turner-Inner")
						.foregroundStyle(Color.white)
						.padding(.top, 20)
						.padding(.bottom, 20)
						.frame(maxWidth: .infinity, alignment: .center)
						.background(Color("button2"))
						.cornerRadius(5)
						.shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
					
				}
				.buttonStyle(PlainButtonStyle())

				.padding(.horizontal, 0)
				.padding(.top, 0)
				.padding(.bottom, 5)
				.frame(maxWidth: .infinity, alignment: .topLeading)
				
				
				
				Spacer()
//				NavigationLink(destination: PanelSchedule()) {
//					Text("Panel Schedule Builider")
//						.foregroundStyle(Color.white)
//						.padding(.top, 20)
//						.padding(.bottom, 20)
//						.frame(maxWidth: .infinity, alignment: .center)
//						.background(Color("button3"))
//						.cornerRadius(5)
//						.shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
//					
//				}
//				.buttonStyle(PlainButtonStyle())
//				
//				.padding(.horizontal, 0)
//				.padding(.top, 0)
//				.padding(.bottom, 5)
//				.frame(maxWidth: .infinity, alignment: .topLeading)
				
				NavigationLink(destination: LightCounter()) {
					Text("Device Counter")
						.foregroundStyle(Color.white)
						.padding(.top, 20)
						.padding(.bottom, 20)
						.frame(maxWidth: .infinity, alignment: .center)
						.background(Color("button3"))
						.cornerRadius(5)
						.shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
					
				}
				.buttonStyle(PlainButtonStyle())
				
				.padding(.horizontal, 0)
				.padding(.top, 0)
				.padding(.bottom, 5)
				.frame(maxWidth: .infinity, alignment: .topLeading)
				
				
				NavigationLink(destination: DeviceFinderAPI()) {
					Text("Online Device Counter")
						.foregroundStyle(Color.white)
						.padding(.top, 20)
						.padding(.bottom, 20)
						.frame(maxWidth: .infinity, alignment: .center)
						.background(Color("button3"))
						.cornerRadius(5)
						.shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
					
				}
				.buttonStyle(PlainButtonStyle())
				
				.padding(.horizontal, 0)
				.padding(.top, 0)
				.padding(.bottom, 5)
				.frame(maxWidth: .infinity, alignment: .topLeading)
				
				Spacer()
			}
			
			
			
			Spacer()
			Button(action: {
				// Toggle the visibility of the pop-up
				isPopupVisible.toggle()
			}) {
				// Use a system icon
				Image("colorWheel")
					.symbolRenderingMode(.multicolor)
					.onAppear {
						symbolAnimation.toggle()
					}
					.buttonStyle(PlainButtonStyle())
					.symbolEffect(.variableColor.reversing.cumulative, options: .repeat(100).speed(1), value: symbolAnimation)
					.font(.largeTitle)
				// Customize your button's appearance
				
			}.buttonStyle(PlainButtonStyle())

			.popover(isPresented: $isPopupVisible, arrowEdge: .top) {
				ThemeView()
			}
//			NavigationLink(destination: SettingsView()) {
//				Text("Time Turner-Inner")
//					.foregroundStyle(Color.white)
//					.padding(.top, 20)
//					.padding(.bottom, 20)
//					.frame(maxWidth: .infinity, alignment: .center)
//					.background(Color("button2"))
//					.cornerRadius(5)
//					.shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
//				
//			}
//			.buttonStyle(PlainButtonStyle())
//			
//			.padding(.horizontal, 0)
//			.padding(.top, 0)
//			.padding(.bottom, 5)
//			.frame(maxWidth: .infinity, alignment: .topLeading)
			
		}
		
		.padding()
			.background(Color("Color 8"))
		
		
	}
	
}


//
//struct AnimatedGradientView: View {
//	var colors: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo, .purple]
//	var body: some View {
//		GeometryReader { geometry in
//			AnimatedGradientModifier(colors: colors, width: geometry.size.width)
//				.frame(height: 4) // Set the height of the divider line
//				.mask(Rectangle())
//		}
//	}
//
//	struct AnimatedGradientModifier: View, AnimatableModifier {
//		var colors: [Color]
//		let width: CGFloat
//		var percent: CGFloat = 0
//
//		var animatableData: CGFloat {
//			get { percent }
//			set { percent = newValue }
//		}
//
//		func body(content: Content) -> some View {
//			content.overlay(
//				LinearGradient(gradient: Gradient(colors: colors), startPoint: UnitPoint(x: percent - 1, y: 0), endPoint: UnitPoint(x: percent, y: 0))
//					.frame(width: width)
//					.offset(x: (percent - 1) * width)
//			)
//			.onAppear {
//				withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
//					self.percent = 1
//				}
//			}
//		}
//	}
//}








import SwiftUI

@available(iOS 17.0, *)
struct LandingPageView: View {
	// Define the columns for the grid layout
	let columns = [
		GridItem(.flexible()),
		GridItem(.flexible())
	]

	var body: some View {
		VStack {
			// Header section
			VStack {
				// Header
				Text("Sparklists")
					.padding(.horizontal)
					.foregroundStyle(Color.white)
					.font(Font.custom("Quicksand", size: 60))
					.frame(maxWidth: .infinity * 0.90, alignment: .center)

				Text("The best apprentace you'll ever hire.")
					.foregroundStyle(Color.white)
					.font(Font.custom("Quicksand", size: 10).bold())
					.frame(maxWidth: .infinity * 0.90, alignment: .center)


				//				AnimatedGradientDivider()
			}.padding(.vertical, 30)
			Divider().frame(height: 1.0).background(
				Color(dataManager.themeColor)
				)
			Spacer()
			// Grid of function tiles
			LazyVGrid(columns: columns, spacing: 20) {
				FunctionTile(title: "Material List Generator", iconName: "list.bullet.rectangle")
				FunctionTile(title: "Online Device Count", iconName: "network")
				FunctionTile(title: "Time Turner-Inner\n", iconName: "clock.arrow.circlepath")
				FunctionTile(title: "Offline Device Count", iconName: "desktopcomputer")
			}
			.padding()

			// Footer section
			Spacer()
			HStack {
				Button(action: {}) {
					Label("Settings", systemImage: "gear")
				}
				Spacer()
				Button(action: {}) {
					Label("Support", systemImage: "lifepreserver")
				}
			}
			.padding()
		}
	}
}

// Define a reusable view for the function tiles
struct FunctionTile: View {
	var title: String
	var iconName: String

	var body: some View {
		VStack {
			Image(systemName: iconName)
				.font(.largeTitle)
				.foregroundColor(.blue)
			Text(title)
				.fontWeight(.semibold)
		}
		.padding()
		.frame(maxWidth: .infinity)
		.background(Color.gray.opacity(0.2))
		.cornerRadius(10)
	}
}

@available(iOS 17.0, *)
struct LandingPageView_Previews: PreviewProvider {
	static var previews: some View {
		LandingPageView()
	}
}

