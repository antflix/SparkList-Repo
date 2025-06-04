//
//  toolbar.swift
//  SparkList
//
//  Created by User on 12/16/23.
//

import SwiftUI
import Contacts
import SwiftUI
import Foundation

@available(iOS 17.0, *)
struct MyToolbarItems: ToolbarContent {
	@EnvironmentObject var dataManager: DataManager
	@Environment(\.colorScheme) var colorScheme // Get the current color scheme
	@State private var showConfirmation = false
	@State private var showJobs = false
	@State private var isPopoverPresented = false
	@State private var isContactsPresented = false
	@State private var isHomePresented = false

	@State private var symbolAnimation = false
	// make the default setting darkmode
	// Your toolbar items go here
	var body: some ToolbarContent {
		
		ToolbarItemGroup(placement: .bottomBar) {
			
			VStack {
				
				HStack {
					HStack {
					
					
					
					
					Button(action: {
						// Call the function here
						dataManager.clearAllSMSData()
						
						// Navigate to the second view
						isHomePresented = true
					}) {
						Image(systemName: "house")
							.foregroundStyle(dataManager.themeColor)
							.font(Font.custom("Quicksand", size: 24).bold())
						
					}
					NavigationLink(destination: StartView(), isActive: $isHomePresented) {
						EmptyView()
					}
					.buttonStyle(PlainButtonStyle())
					
					.background(Color.green)
					.bold()
					.foregroundColor(.white)
				
					}.padding()

					Spacer()
//                                        HStack {
//                                                Button(action: {
//                                                        isContactsPresented.toggle()
//                                                }) {
//                                                        if !dataManager.selectedContacts.isEmpty {
//
//                                                                Image(systemName: "person.fill.badge.plus")
//                                                                        .font(Font.custom("Quicksand", size: 24).bold())
//                                                                        .aspectRatio(contentMode: .fit)
//                                                                        .symbolRenderingMode(.palette)
//                                                                        .foregroundStyle(Color.green, dataManager.themeColor)
//
//                                                        } else {
//                                                                Image(systemName: "person.fill.questionmark")
//                                                                        .font(Font.custom("Quicksand", size: 24).bold())
//                                                                        .symbolRenderingMode(.palette)
//                                                                        .onAppear {
//                                                                               symbolAnimation.toggle()
//                                                                        }
//
//                                                                        .foregroundStyle(Color.red, dataManager.themeColor)
//                                                                        .symbolEffect(.variableColor.reversing.cumulative, options: .repeat(100).speed(1), value: symbolAnimation)
//
//                                                        }
//                                                }
//                                                .popover(isPresented: $isContactsPresented, arrowEdge: .top) {
//                                                        ContactsSelectionView().environmentObject(dataManager)
//                                                }
//                                        }
//                                        //            }
//                                        Spacer()
//                                        HStack {
//                                                Button(action: {
//                                                        isPopoverPresented.toggle()
//                                                }) {
//                                                        Image(systemName: "clock.arrow.2.circlepath")
//                                                                .foregroundStyle(Color("Color 6"), dataManager.themeColor)
//                                                                .font(Font.custom("Quicksand", size: 24).bold())
//                                                }
//                                                .popover(isPresented: $isPopoverPresented, arrowEdge: .top) {
//                                                        AlarmSettingView()
//                                                }
//                                        }
					Spacer()
					// Add an onTapGesture to the arrow.up.trash symbol
					HStack {
						Image(systemName: "arrow.up.trash")
							.foregroundStyle(Color("Color 6"), dataManager.themeColor)
							.mask(Circle())
							.font(Font.custom("Quicksand", size: 24).bold())
							.onTapGesture {
								showConfirmation = true
							}
						
							.confirmationDialog(
								"Clear SMS Data",
								isPresented: $showConfirmation,
								titleVisibility: .visible
							) {
								Button("Clear it") {
									dataManager.clearAllSMSData()
									showJobs = true
								}
								Button("Cancel", role: .cancel) {}
							}
							.background(
								NavigationLink(
									destination: JobsView())
								{
									EmptyView()
								}
							)
					}.padding()
						
					Spacer()
					Spacer()
					HStack {
						if colorScheme == .light {
							Image("moonsun")
								.symbolRenderingMode(.multicolor)
								.onAppear {
									symbolAnimation.toggle()
								}
								.font(.title2)

								.foregroundStyle(dataManager.themeColor.opacity(0.9), dataManager.themeColor.opacity(0.9))
								.onTapGesture{
									withAnimation(.easeInOut(duration: 10)) { // Slow down the animation
										dataManager.isDarkMode.toggle()
								}
						}
						} else {
							Image("sunmoon")
								.symbolRenderingMode(.palette)
								.onAppear {
									symbolAnimation.toggle()
								}
								.foregroundStyle(dataManager.themeColor, Color.white)
								.font(.title2)
								.onTapGesture{
									withAnimation(.easeInOut(duration: 10)) { // Slow down the animation
										dataManager.isDarkMode.toggle()
									}
								}
						}
					}
					Spacer()
				}
			}

		}
	}
}

@available(iOS 17.0, *)

#Preview {
	NavigationStack {
		JobsView()
			.environmentObject(DataManager())
	}
	

}

//        // Create a placeholder view for the preview
//        Text("Placeholder View")
//            // Use the toolbar with MyToolbarItems for preview
//            .toolbar {
//                MyToolbarItems()
//            }
//    }
// }
