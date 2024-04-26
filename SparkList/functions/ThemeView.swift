//
//  ThemeView.swift
//  SparkTime
//
//  Created by Anthony on 1/28/24.
//
//.variableColor.cumulative.dimInactiveLayers.reversing
import SwiftUI
import Foundation
@available(iOS 17.0, *)
struct ThemeView: View {
	@EnvironmentObject var dataManager:DataManager
	
	let colors: [Color] = [.blue, .green, .orange, .pink, .purple, .black, .gray]
	
	var body: some View {
		
	// Change VStack alignment to center
	
			VStack{
				
				ScrollView {
					sunview().padding(.top, 120)
					VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
						
						
						
						HStack {
							
							Spacer()
							Text("Select a theme color")
								.padding(.bottom)
								.fontWeight(.bold)
								.foregroundStyle(dataManager.isDarkMode ? .white: .black)
							Spacer()
							
							
						}
						ForEach(colors, id: \.self) { color in
							HStack {
								Circle()
									.fill(color)
									.frame(width: 24, height: 24)
								Text(color.description.capitalized)
									.padding()
									.foregroundStyle(dataManager.isDarkMode ? .white: .black)
							}
							.onTapGesture {
								dataManager.themeColor = color
							}
							
						}
					}
				}
				
				
				//		}}.padding(.top)
				//				.frame(minWidth: 0, maxWidth: .infinity)
				//				.modifier(DarkModeLightModeBackground())
				//		//		.toolbar {
				//		//			ToolbarItem() {
				//		//				sunview().padding(30)
				//		//			}
				//		//		}
			}
			
			.frame(minWidth: 0, maxWidth: .infinity)
			.padding(.top, 50)
			
			.modifier(DarkModeLightModeBackground())
			//		.edgesIgnoringSafeArea(.all)
		}
	
}

