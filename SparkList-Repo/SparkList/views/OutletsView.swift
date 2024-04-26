//
//  OutletsView.swift
//  SparkTime
//
//  Created by User on 1/4/24.
//

import SwiftUI


@available(iOS 17.0, *)
struct SingleGangView: View {
  @EnvironmentObject var dataManager: DataManager
  var body: some View {
    ZStack {
		
		ScrollView {
			VStack {
				
//				
//				Text("Outlets")
//					.fontWeight(.black)
//					.font(.largeTitle)
//					.multilineTextAlignment(.center)
//					.foregroundStyle(Color.white)
//					.frame(maxWidth: .infinity * 0.90, alignment: .center)
				HStack {
					
					Text("Outlets") .fontWeight(.black)
						.font(.largeTitle)
						.multilineTextAlignment(.center)
						.foregroundStyle(Color.white)
						.frame(maxWidth: .infinity * 0.90, alignment: .center)
			
				}
				Text("Count the amount of controlled and non-controlled* outlets that are shown on the print and enter below.")//					.fontWeight(.black)
					.padding()
					
					.foregroundStyle(Color.white)
					.multilineTextAlignment(.center)
					.font(.title2)
				
				
				VStack {
					HStack {
						Spacer()
						Text("Single Gang").foregroundStyle(Color.white).font(.title2).bold().padding(
							.top, 25.0)
						Spacer()
						Image("duplex")
							.padding(.top)
							.padding(.trailing, 40)
							.aspectRatio(contentMode: .fit)
							.symbolRenderingMode(.palette)
							.foregroundStyle(Color.white, Color.blue, Color.black)
							.font(Font.title.weight(.ultraLight))
					}
	
					Divider().background(dataManager.isDarkMode ? .green: .black).padding(.horizontal)
					HStack {
						Text("Non-Controlled*").foregroundStyle(Color.white).padding()
						
						TextField("Quantity", text: $dataManager.bracketBoxDuplex).padding()  // Vertical padding
							.keyboardType(.decimalPad)// Vertical padding
						
							.foregroundColor(.green.opacity(0.9))  // Text color
							.overlay(Rectangle().frame(height: 1).padding(.top, 30).foregroundColor(.blue))  // Underline
							.padding(.trailing)
						Image("sfduplex")
							.padding(.bottom)
							.padding(.trailing, 40)
							.aspectRatio(contentMode: .fit)
							.symbolRenderingMode(.palette)
							.foregroundStyle(Color.white, Color.blue, Color.black)
							.font(Font.title.weight(.ultraLight))
					}
	
					HStack {
						Text("Controlled").foregroundStyle(Color.white).padding()
						
						TextField("Quantity", text: $dataManager.controlled).padding()  // Vertical padding
							.keyboardType(.decimalPad)// Vertical padding
						
							.foregroundColor(.green.opacity(0.9))  // Text color
							.overlay(Rectangle().frame(height: 1).padding(.top, 30).foregroundColor(.blue))  // Underline
							.padding(.trailing)
						Image("sfcontrolled")
							.padding(.bottom)
							.padding(.trailing, 40)
							.aspectRatio(contentMode: .fit)
							.symbolRenderingMode(.palette)
							.foregroundStyle(Color.white, Color.blue, Color.black)
							.font(Font.title.weight(.ultraLight))
					}
						.padding(.bottom)
				}
				.background(
					.ultraThinMaterial,
					in: RoundedRectangle(cornerRadius: 15, style: .continuous)
					
				).padding(.top, 10)
				.padding(.horizontal)
				
				
				
				
				
				VStack {
					HStack {
						Spacer()
						Text("Two Gang").foregroundStyle(Color.white).font(.title2).bold().padding(.top, 25.0)
						Spacer()
						Image("quad")
							.padding(.top)
							.padding(.trailing, 20)
							.aspectRatio(contentMode: .fit)
							.symbolRenderingMode(.palette)
							.foregroundStyle(Color.white, Color.blue, Color.black)
							.font(Font.title.weight(.ultraLight))
					}
					Divider().background(dataManager.isDarkMode ? .green: .black).padding(.horizontal)
					HStack {
						Text("Non-Controlled*").foregroundStyle(Color.white).padding()
						
						TextField("Quantity", text: $dataManager.quadBracketBox).padding()
							.keyboardType(.decimalPad)// Vertical padding
// Vertical padding
							.foregroundColor(.green.opacity(0.9))  // Text color
							.overlay(Rectangle().frame(height: 1).padding(.top, 30).foregroundColor(.blue))  // Underline
							.padding(.trailing)
						Image("sfquad")
							.padding(.bottom)
							.padding(.trailing, 40)
							.aspectRatio(contentMode: .fit)
							.symbolRenderingMode(.palette)
							.foregroundStyle(Color.white, Color.blue, Color.black)
							.font(Font.title.weight(.ultraLight))
					}
					
					HStack {
						Text("Controlled").foregroundStyle(Color.white).padding()
						
						TextField("Quantity", text: $dataManager.quadControlled).padding(.vertical, 8)  // Vertical padding
							.keyboardType(.decimalPad)// Vertical padding

							.foregroundColor(.green.opacity(0.9))  // Text color
							.overlay(Rectangle().frame(height: 1).padding(.top, 30).foregroundColor(.blue))  // Underline
							.padding(.trailing)
						Image("sfquadControlled")
							.padding(.bottom)
							.padding(.trailing, 40)
							.aspectRatio(contentMode: .fit)
							.symbolRenderingMode(.palette)
							.foregroundStyle(Color.white, Color.blue, Color.black)
							.font(Font.title.weight(.ultraLight))
					}.padding(.top)
						.padding(.bottom)
				} .background(
					.ultraThinMaterial,
					in: RoundedRectangle(cornerRadius: 15, style: .continuous)
					
				).padding(.horizontal)
				Spacer()
				
				//                TextField("Quad GFCI", text: $dataManager.quadGFCI).foregroundColor(Color("Color 6"))
				//                TextField("Quad Cut-in", text: $dataManager.quadCutIn).foregroundColor(Color("Color 6"))
				//                TextField("Quad Surface Mounted", text: $dataManager.quadSurfaceMounted).foregroundColor(Color("Color 6"))
			}
		}
		
		.scrollDismissesKeyboard(.immediately)
			sunview()
    }
	.navigationBarHidden(true)
	  Text("*Include GFCI and cut-in outlets in quantities.")
		  .multilineTextAlignment(.center)
		  .foregroundStyle(Color.white)
		  .padding(
			.vertical
		  ).font(.subheadline)
	
  }
}

@available(iOS 17.0, *)
struct BoxTypeView: View {
  @EnvironmentObject var dataManager: DataManager

	var body: some View {
		ZStack {
			ScrollView {
				VStack {
					Text("Outlets detail") .fontWeight(.black)
						.font(.largeTitle)
						.multilineTextAlignment(.center)
						.foregroundStyle(Color.white)
						.frame(maxWidth: .infinity * 0.90, alignment: .center)
					Text("Out of the \(dataManager.boxTotal) outlets how many of each do you have?").padding()
						.foregroundStyle(Color.white)
						.multilineTextAlignment(.center)
						.font(.title2)
					
					Spacer()
					VStack {
						HStack {
							Spacer()
							Text("Single Gang").padding(.top, 25.0).padding(.horizontal).foregroundStyle(
								Color.white
							).font(.title2).bold()
							Spacer()
//							Image("duplex")
//								.padding(.top)
//								.padding(.trailing, 40)
//								.aspectRatio(contentMode: .fit)
//								.symbolRenderingMode(.palette)
//								.foregroundStyle(Color.white, Color.blue, Color.black)
//								.font(Font.title.weight(.ultraLight))
						}
						Divider().background(dataManager.isDarkMode ? .green: .black).padding(.horizontal)
						HStack {
							Text("Cut-in").foregroundStyle(Color.white).padding()
							
							TextField("Quantity", text: $dataManager.cutin).padding()  // Vertical padding
								.keyboardType(.decimalPad)// Vertical padding
							
								.foregroundColor(.green.opacity(0.9))  // Text color
								.overlay(Rectangle().frame(height: 1).padding(.top, 30).foregroundColor(.blue))  // Underline
								.padding(.trailing)
							Image("sfcutin")
								.resizable()
								.frame(width:20					, height: 40)
								.padding(.bottom)
								.padding(.trailing, 60)
								.aspectRatio(contentMode: .fit)
								.symbolRenderingMode(.palette)
								.foregroundStyle(Color.white, Color.blue, Color.black)
								.font(Font.title.weight(.ultraLight))
						}
						
						HStack {
							Text("GFCI").foregroundStyle(Color.white).padding()
							
							TextField("Quantity", text: $dataManager.gfci).padding(.vertical, 8)  // Vertical padding
								.keyboardType(.decimalPad)// Vertical padding
							
								.foregroundColor(.green.opacity(0.9))  // Text color
								.overlay(Rectangle().frame(height: 1).padding(.top, 30).foregroundColor(.blue))  // Underline
								.padding(.trailing)
							Image("sfGFCI")
								.padding(.bottom)
								.padding(.trailing, 40)
								.aspectRatio(contentMode: .fit)
								.symbolRenderingMode(.palette)
								.foregroundStyle(Color.white, Color.blue, Color.black)
								.font(Font.title.weight(.ultraLight))
						}
					} .background(
						.ultraThinMaterial,
						in: RoundedRectangle(cornerRadius: 15, style: .continuous)
						
					).padding(.horizontal)
					//        }.background(
					//          ZStack {
					//            RoundedRectangle(cornerRadius: 0, style: .circular)
					//              .fill(Color.gray.opacity(0.01))
					//            Blur(style: .dark)
					//          }
					//        )
					//        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous)).padding(.horizontal)
					VStack {
						HStack {
							Spacer()
							Text("Two Gang").padding(.top, 25.0).padding(.horizontal).foregroundStyle(Color.white)
								.font(.title2).bold()
							Spacer()
						
						}
						Divider().background(dataManager.isDarkMode ? .green: .black).padding(.horizontal)
						HStack {
							Text("Cut-in").foregroundStyle(Color.white).padding()
							
							TextField("Quantity", text: $dataManager.quadCutIn).padding()  // Vertical padding
								.keyboardType(.decimalPad)// Vertical padding
							
								.foregroundColor(.green.opacity(0.9))  // Text color
								.overlay(Rectangle().frame(height: 1).padding(.top, 30).foregroundColor(.blue))  // Underline
								.padding(.trailing)
							Image("sfcutinQuad")
								.resizable()
								.frame(width:40					, height: 40)
								.padding(.bottom)
								.padding(.trailing, 40)
								.aspectRatio(contentMode: .fit)
								.symbolRenderingMode(.palette)
								.foregroundStyle(Color.white, Color.blue, Color.black)
								.font(Font.title.weight(.ultraLight))
						}
						
						HStack {
							Text("GFCI").foregroundStyle(Color.white).padding()
							
							TextField("Quantity", text: $dataManager.quadGFCI).padding(.vertical, 8)  // Vertical padding
								.keyboardType(.decimalPad)// Vertical padding
							
								.foregroundColor(.green.opacity(0.9))  // Text color
								.overlay(Rectangle().frame(height: 1).padding(.top, 30).foregroundColor(.blue))  // Underline
								.padding(.trailing)
							Image("sfGFCI")
								.padding(.bottom)
								.padding(.trailing, 40)
								.aspectRatio(contentMode: .fit)
								.symbolRenderingMode(.palette)
								.foregroundStyle(Color.white, Color.blue, Color.black)
								.font(Font.title.weight(.ultraLight))
							
						}
						.padding(.bottom)
						
					} .background(
						.ultraThinMaterial,
						in: RoundedRectangle(cornerRadius: 15, style: .continuous)
						
					).padding(.horizontal)
					Spacer()
					//        }.background(
					//          ZStack {
					//            RoundedRectangle(cornerRadius: 0, style: .circular)
					//              .fill(Color.gray.opacity(0.01))
					//            Blur(style: .dark)
					//          }
					//        )
					//        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous)).padding()
					
					//                TextField("Quad GFCI", text: $dataManager.quadGFCI).foregroundColor(Color("Color 6"))
					//                TextField("Quad Cut-in", text: $dataManager.quadCutIn).foregroundColor(Color("Color 6"))
					//                TextField("Quad Surface Mounted", text: $dataManager.quadSurfaceMounted).foregroundColor(Color("Color 6"))
				}
			}.scrollDismissesKeyboard(.immediately)
sunview()
		}.onAppear {
			dataManager.calculateTotal()
			
		} .navigationBarHidden(true)
		
	}
}
@available(iOS 17.0, *)
struct SwitchesView: View {
	@EnvironmentObject var dataManager: DataManager
	@State private var isDimmingSwitchActive: Bool = false
	
	var body: some View {
		ZStack {
			ScrollView {
				VStack {
					
					Text("Switches") .fontWeight(.black)
						.font(.largeTitle)
						.multilineTextAlignment(.center)
						.foregroundStyle(Color.white)
						.frame(maxWidth: .infinity * 0.90, alignment: .center)
					Text("Count all of your switches and enter quantities below.")
						.padding()
					
						.foregroundStyle(Color.white)
						.multilineTextAlignment(.center)
						.font(.title2)
					Spacer()
					VStack {
						HStack {
							Spacer()
							Text("Single Gang")
								.foregroundStyle(Color.white).font(.title2).bold().padding(
									.top, 25.0)
							Spacer()
							Image("toggleswitch")
								.padding(.top)
								.padding(.trailing, 40)
								.aspectRatio(contentMode: .fit)
								.symbolRenderingMode(.palette)
								.foregroundStyle(Color.white.opacity(0.6), Color.blue, Color.black)
								.font(Font.title.weight(.ultraLight))
						}
						Divider().background(dataManager.isDarkMode ? .green: .black).padding(.horizontal)
						
						HStack(alignment: .top, spacing: 1) {
							VStack {
								Text("")
								Text("Line\nVoltage").font(.subheadline).foregroundStyle(Color.white).padding()
								Text("Low\nVoltage").font(.subheadline).foregroundStyle(Color.white).padding().padding(.top,0)
								
								
							}
							
							VStack {
								Text("Bracket Box").font(.subheadline).padding(.trailing)
								CustomTextField(placeholder: "Quantity", text: $dataManager.lineVoltageSwitch)
									.keyboardType(.decimalPad)// Vertical padding
								
								CustomTextField(placeholder: "Quantity", text: $dataManager.lvCat5Switch)
									.keyboardType(.decimalPad)// Vertical padding
								
								
							}
							
							VStack {
								Text("Cut-In").font(.subheadline).padding(.trailing)
								CustomTextField(placeholder: "Quantity", text: $dataManager.lineVoltageCutIn)
									.keyboardType(.decimalPad)// Vertical padding
								
								CustomTextField(placeholder: "Quantity", text: $dataManager.lvCat5Cutin)
									.keyboardType(.decimalPad)// Vertical padding
								
								
							}
							
							VStack {
								Text("").hidden() // Empty cell
								VStack {
									Text("0-10V").font(.caption2)
									Toggle("", isOn: $isDimmingSwitchActive)
										.toggleStyle(CheckboxToggleStyle())
										.font(.subheadline)
										.padding(.bottom, 30)
								}.padding(.horizontal, 2)
								VStack {
									Text("0-10V").font(.caption2)
									Toggle("", isOn: $isDimmingSwitchActive)
										.toggleStyle(CheckboxToggleStyle())
										.font(.subheadline)
										.padding(.bottom, 30)
								}.padding(.horizontal, 2)
								Text("").hidden() // Empty cell
							}.padding(.horizontal, 2)
						}
						
						
						.frame(maxWidth: .infinity)
					} .background(
						.ultraThinMaterial,
						in: RoundedRectangle(cornerRadius: 15, style: .continuous)
						
					).padding()
					
					//		  }.background(
					//          ZStack {
					//            RoundedRectangle(cornerRadius: 0, style: .circular)
					//              .fill(Color.gray.opacity(0.01))
					//            Blur(style: .dark)
					//          }
					//        )
					//        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous)).padding(.horizontal)
					
					
					VStack {
						HStack {
							Spacer()
							Text("Two Gang*").foregroundStyle(Color.white).font(.title2).bold().padding(
								.top, 25.0)
							Spacer()
							Image("toggleswitches")
								.padding(.top)
								.padding(.trailing, 40)
								.aspectRatio(contentMode: .fit)
								.symbolRenderingMode(.palette)
								.foregroundStyle(Color.white, Color.blue, Color.black)
								.font(Font.title.weight(.ultraLight))
						}
						Divider().background(dataManager.isDarkMode ? .green: .black).padding(.horizontal)
						
						HStack(alignment: .top, spacing: 1) {
							VStack {
								Text("")
								Text("Line\nVoltage").font(.subheadline).foregroundStyle(Color.white).padding()
								Text("Low\nVoltage").font(.subheadline).foregroundStyle(Color.white).padding().padding(.top,0)
								
								
							}
							
							VStack {
								Text("Bracket Box").font(.subheadline).padding(.trailing)
								CustomTextField(placeholder: "Quantity", text: $dataManager.twoGangSwitch)
									.keyboardType(.decimalPad)// Vertical padding
								
								CustomTextField(placeholder: "Quantity", text: $dataManager.lvTwoGangSwitch)
									.keyboardType(.decimalPad)// Vertical padding
								
								
							}
							
							VStack {
								Text("Cut-In").font(.subheadline).padding(.trailing)
								CustomTextField(placeholder: "Quantity", text: $dataManager.twoGangCutinSwitch)
									.keyboardType(.decimalPad)// Vertical padding
								
								CustomTextField(placeholder: "Quantity", text: $dataManager.lvTwoGangCutinSwitch)
									.keyboardType(.decimalPad)// Vertical padding
								
								
							}
							
							VStack {
								Text("").hidden() // Empty cell
								VStack {
									Text("0-10V").font(.caption2)
									Toggle("", isOn: $isDimmingSwitchActive)
										.toggleStyle(CheckboxToggleStyle())
										.font(.subheadline)
										.padding(.bottom, 30)
								}.padding(.horizontal, 2)
								VStack {
									Text("0-10V").font(.caption2)
									Toggle("", isOn: $isDimmingSwitchActive)
										.toggleStyle(CheckboxToggleStyle())
										.font(.subheadline)
										.padding(.bottom, 30)
								}.padding(.horizontal, 2)
								Text("").hidden() // Empty cell
							}.padding(.horizontal, 2)
						}
						
						
						.frame(maxWidth: .infinity)
						
					} .background(
						.ultraThinMaterial,
						in: RoundedRectangle(cornerRadius: 15, style: .continuous)
					).padding(.horizontal)
					//		  }.background(
					//          ZStack {
					//            RoundedRectangle(cornerRadius: 0, style: .circular)
					//              .fill(Color.gray.opacity(0.01))
					//            Blur(style: .dark)
					//          }
					//        )
					//
					
					Spacer()
					
				}
			}.scrollDismissesKeyboard(.immediately)
			sunview()
		}
		
		.navigationBarHidden(true)
		Text("*For boxes with 2 switches enter a \"1\" in the Two Gang section.")
			.multilineTextAlignment(.center)
			.foregroundStyle(Color.white)
			.padding(
			.vertical
		).font(.subheadline)
	}
	
}

@available(iOS 17.0, *)
struct MiscView: View {
  @EnvironmentObject var dataManager: DataManager
  @State private var selectedOption = "None"

  var body: some View {
    ZStack {
		ScrollView {
			VStack {
				
				
				Text("Miscellaneous") .fontWeight(.black)
					.font(.largeTitle)
					.multilineTextAlignment(.center)
					.foregroundStyle(Color.white)
					.frame(maxWidth: .infinity * 0.90, alignment: .center)
				Text("Count The remaing wall devices and enter below?").padding()
				
					.foregroundStyle(Color.white)
					.multilineTextAlignment(.center)
					.font(.title2)
				Spacer()
				VStack {
					Text("Instahots").padding(.top).font(.title2).foregroundStyle(.white)
					Divider().background(dataManager.isDarkMode ? .green: .black).padding(.horizontal)
					
					HStack {
						HStack {
							Text("30A").font(.subheadline).foregroundStyle(Color.white)
							
							TextField("Quantity", text: $dataManager.singlePole277V30AInstahot)							.keyboardType(.decimalPad)// Vertical padding
							
								.padding()  // Vertical padding
								.foregroundColor(.green.opacity(0.9))  // Text color
								.overlay(Rectangle().frame(height: 1).padding(.top, 30).foregroundColor(.blue))  // Underline
						}
						HStack {
							Text("40A").font(.subheadline).foregroundStyle(Color.white)
							
							TextField("Quantity", text: $dataManager.singlePole277V40AInstahot)
								.keyboardType(.decimalPad)// Vertical padding
								.padding()  // Vertical padding
								.foregroundColor(.green.opacity(0.9))  // Text color
								.overlay(Rectangle().frame(height: 1).padding(.top, 30).foregroundColor(.blue))  // Underline
						}
						
					}.padding(.top, 0).padding(.horizontal)
				} .background(
					.ultraThinMaterial,
					in: RoundedRectangle(cornerRadius: 15, style: .continuous)
					
				).padding(.horizontal)
				//        }.background(
				//          ZStack {
				//            RoundedRectangle(cornerRadius: 0, style: .circular)
				//              .fill(Color.gray.opacity(0.01))
				//            Blur(style: .dark)
				//          }
				//        )
				//        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous)).padding(.horizontal)
				VStack {
					Text("Furniture Feeds").padding(.top).font(.title2).foregroundStyle(.white)
					Divider().background(dataManager.isDarkMode ? .green: .black).padding(.horizontal)
					
					HStack {
						HStack {
							Text("3-wire").font(.subheadline).foregroundStyle(Color.white)
							
							TextField("Quantity", text: $dataManager.wire3FurnitureFeed).padding()  // Vertical padding
								.keyboardType(.decimalPad)// Vertical padding
							
								.foregroundColor(.green.opacity(0.9))  // Text color
								.overlay(Rectangle().frame(height: 1).padding(.top, 30).foregroundColor(.blue))  // Underline
						}
						HStack {
							Text("4-wire").font(.subheadline).foregroundStyle(Color.white)
							
							TextField("Quantity", text: $dataManager.wire2FurnitureFeed).padding()  // Vertical padding
								.keyboardType(.decimalPad)// Vertical padding
							
								.foregroundColor(.green.opacity(0.9))  // Text color
								.overlay(Rectangle().frame(height: 1).padding(.top, 30).foregroundColor(.blue))  // Underline
						}
					}.padding()
				} .background(
					.ultraThinMaterial,
					in: RoundedRectangle(cornerRadius: 15, style: .continuous)
					
				).padding(.horizontal)
				
				//        }.background(
				//          ZStack {
				//            RoundedRectangle(cornerRadius: 0, style: .circular)
				//              .fill(Color.gray.opacity(0.01))
				//            Blur(style: .dark)
				//          }
				//        )
				//        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous)).padding(.horizontal)
				VStack {
					VStack {
						Text("Misc.").padding(.top).font(.title2).foregroundStyle(.white)
						Divider().background(dataManager.isDarkMode ? .green: .black).padding(.horizontal)
						
					}
					
					HStack {
						HStack {
							VStack {
								Text("Bracket").font(.subheadline).foregroundStyle(Color.white)
								Text("Data").font(.subheadline).foregroundStyle(Color.white)
								
							}
							TextField("Quantity", text: $dataManager.bracketBoxData).padding()  // Vertical padding
								.keyboardType(.decimalPad)// Vertical padding
							
								.foregroundColor(.green.opacity(0.9))  // Text color
								.overlay(Rectangle().frame(height: 1).padding(.top, 30).foregroundColor(.blue))  // Underline
						}
						VStack {
							Text("Cut-in").font(.subheadline).foregroundStyle(Color.white)
							Text("Data").font(.subheadline).foregroundStyle(Color.white)
							
						}
						TextField("Quantity", text: $dataManager.cutInData).padding()  // Vertical padding
							.keyboardType(.decimalPad)// Vertical padding
						
							.foregroundColor(.green.opacity(0.9))  // Text color
							.overlay(Rectangle().frame(height: 1).padding(.top, 30).foregroundColor(.blue))  // Underline
					}.padding(.top, 0).padding(.horizontal)
					HStack {
						VStack {
							Text("Homerun").font(.subheadline).foregroundStyle(Color.white)
							Text("Quantity").font(.subheadline).foregroundStyle(Color.white)
							
						}
						TextField("Quantity", text: $dataManager.homerunQuantity).padding()  // Vertical padding
							.keyboardType(.decimalPad)// Vertical padding
						
							.foregroundColor(.green.opacity(0.9))  // Text color
							.overlay(Rectangle().frame(height: 1).padding(.top, 30).foregroundColor(.blue))  // Underline
						
						VStack {
							Text("Longest").font(.subheadline).foregroundStyle(Color.white)
							Text("HR length").font(.subheadline).foregroundStyle(Color.white)
						}
						TextField("Quantity", text: $dataManager.homerunLength).padding()  // Vertical padding
							.keyboardType(.decimalPad)// Vertical padding
						
							.foregroundColor(.green.opacity(0.9))
							.overlay(Rectangle().frame(height: 1).padding(.top, 30).foregroundColor(.blue))  // Underline
					}
					HStack {
						let options = [
							"None", "WIREMOLD- 4FFATC15", "WIREMOLD- #RC4ATC", "WIREMOLD- #RC3ATC",
							"WIREMOLD- #RC9A15TC", "WIREMOLD- #RC7ATC", "WIREMOLD- #WIREMOLD- 6ATC2P",
							"WIREMOLD- #152CHA",
						]
						Text("Floor Devices").foregroundStyle(.white)
						
						Picker("Options", selection: $selectedOption) {
							ForEach(options, id: \.self) { option in
								Text(option).foregroundColor(.white)
							}
						}.pickerStyle(.automatic)
							.foregroundColor(Color.white)
							.background(Color.clear)
						
						// Display the selected option
						TextField("Quantity", text: $dataManager.in6FloorDevice).padding()  // Vertical padding
							.keyboardType(.decimalPad)// Vertical padding
						
							.foregroundColor(.green.opacity(0.9))  // Text color
							.overlay(Rectangle().frame(height: 1).padding(.top, 30).foregroundColor(.blue))
					}.padding(.top, 0).padding(.bottom).padding(.horizontal)
				} .background(
					.ultraThinMaterial,
					in: RoundedRectangle(cornerRadius: 15, style: .continuous)
					
				).padding(.horizontal)
				//
				//		}.background(
				//          ZStack {
				//            RoundedRectangle(cornerRadius: 0, style: .circular)
				//              .fill(Color.gray.opacity(0.01))
				//            Blur(style: .dark)
				//          }
				//        )
				//        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous)).padding(.horizontal)
				
				Spacer()
				
				//                TextField("Quad GFCI", text: $dataManager.quadGFCI).foregroundColor(Color("Color 6"))
				//                TextField("Quad Cut-in", text: $dataManager.quadCutIn).foregroundColor(Color("Color 6"))
				//                TextField("Quad Surface Mounted", text: $dataManager.quadSurfaceMounted).foregroundColor(Color("Color 6"))
			}
		}.scrollDismissesKeyboard(.immediately)
		sunview()
    }.onAppear {
      dataManager.calculateTotal()
		
	}.navigationBarHidden(true)
		 

  }
}


@available(iOS 17.0, *)
struct OutletCalculatorView: View {
	
	@EnvironmentObject var dataManager: DataManager
	
	@State private var materialRequirements: [String: [String: Int]]
	@State private var showingMaterialList = false
	init() {
		if let savedData = UserDefaults.standard.data(forKey: "MaterialRequirements"),
		   let decodedData = try? JSONDecoder().decode([String: [String: Int]].self, from: savedData)
		{
			_materialRequirements = State(initialValue: decodedData)
		} else {
			_materialRequirements = State(initialValue: DataManager.defaultMaterialRequirements)
		}
	}
	
	
	@State private var editingMaterialRequirements: Bool = false
	func loadFromUserDefaults() {
		if let savedData = UserDefaults.standard.data(forKey: "MaterialRequirements"),
		   let decodedData = try? JSONDecoder().decode([String: [String: Int]].self, from: savedData)
		{
			self.materialRequirements = decodedData
		} else {
			self.materialRequirements = DataManager.defaultMaterialRequirements
		}
	}
	
	func saveToUserDefaults() {
		if let encoded = try? JSONEncoder().encode(materialRequirements) {
			UserDefaults.standard.set(encoded, forKey: "MaterialRequirements")
		}
	}
	
	var body: some View {
		ZStack {
			VStack {
				
				//
				Button(editingMaterialRequirements ? "Done Editing" : "Edit Material Requirements") {
					editingMaterialRequirements.toggle()
					saveToUserDefaults()
				}
				.buttonStyle(PlainButtonStyle())
				.foregroundStyle(Color("BWText"))
				.padding()
				.background(Color.blue)
				
				.sheet(isPresented: $editingMaterialRequirements) {
					EditMaterialRequirementsView(
						materialRequirements: $materialRequirements,
						materialKeys: $dataManager.materialKeys)
				}
				
				Button(action: {
					self.showingMaterialList = true
				}) {
					Text("Calculate Materials")
				}
				.buttonStyle(PlainButtonStyle())
				.foregroundStyle(Color("BWText"))
					.padding()
					.background(Color.blue)
				
				
					.sheet(isPresented: $showingMaterialList) {
						MaterialsListView(
							materials:
								self.calculateMaterials(quantities: [
									"Standard Bracket Box": dataManager.bracketBoxDuplex,
									"GFCI": dataManager.gfci,
									"Cut-In": dataManager.cutin,
									"Surface Mounted": dataManager.cutin,
									"Controlled": dataManager.controlled,
									"Scaled": dataManager.scaled,
									"Homerun Quantity": dataManager.homerunQuantity,
									"Quad Bracket Box": dataManager.quadBracketBox,
									"Quad GFCI": dataManager.quadGFCI,
									"Quad Cut-in": dataManager.quadCutIn,
									"Quad Surface Mounted": dataManager.quadSurfaceMounted,
									"Quad Controlled": dataManager.quadControlled,
									"3wire Furniture Feed": dataManager.wire3FurnitureFeed,
									"4wire Furniture Feed": dataManager.wire2FurnitureFeed,
									"Bracket Box Data": dataManager.bracketBoxData,
									"Cut-in Data": dataManager.cutInData,
									"Line-Voltage Dimming Switch": dataManager.lineVoltageDimmingSwitch,
									"Line-Voltage Dimming Cut-in": dataManager.lineVoltageDimmingCutin,
									"LV/Cat5 Switch": dataManager.lvCat5Switch,
									"LV/Cat5 Cut-in": dataManager.lvCat5Cutin,
									"Line-Voltage Switch": dataManager.lineVoltageSwitch,
									"Line-Voltage Cut-in": dataManager.lineVoltageCutIn,
									"2-Gang Switch": dataManager.twoGangSwitch,
									"2-Gang Cut-In Switch": dataManager.twoGangCutinSwitch,
									"2-Gang LV/Cat5 Switch": dataManager.lvTwoGangSwitch,
									"2-Gang LV/Cat5 Cut-In Switch": dataManager.lvTwoGangCutinSwitch,
									"6in Floor Device": dataManager.inFloorDevice,
									"4in Floor Device": dataManager.in6FloorDevice,
									"Single-Pole 277V 40A Instahot": dataManager.singlePole277V40AInstahot,
									"2-Pole 208V 40A Instahot": dataManager.pole208V40AInstahot,
									"Single-Pole 277V 30A Instahot": dataManager.singlePole277V30AInstahot,
								]))
						
					}
					.padding()
					.foregroundStyle(Color("BWText"))
				
				//				List(allMaterials, id: \.self) { material in
				//					if let quantity = calculatedMaterials[material] {
				//						if quantity > 0 {
				//							HStack {
				//								Text(material)
				//								Spacer()
				//								Text("\(quantity)")
				//							}
				//						}
				//					}
				//				}
				
			}
			sunview()
		}.navigationBarHidden(true)
		.onAppear { loadFromUserDefaults() }
			.padding()
	}
	func calculateMaterials(quantities: [String: String]) -> [String: Int] {
		var totalMaterials: [String: Int] = [:]
		
		for (deviceType, deviceQuantityString) in quantities {
			if let deviceQuantity = Int(deviceQuantityString) {  // Convert the String to an Int
				for (material, quantity) in materialRequirements[deviceType] ?? [:] {
					totalMaterials[material, default: 0] += quantity * deviceQuantity
				}
			}
		}
		
		// Add mcTotal to "12/2 LV MC"
		if let mcTotalInt = Int(dataManager.mcTotal) {
			totalMaterials["12/2 LV MC", default: 0] += mcTotalInt
		}
		
		return totalMaterials
		
	}
}

struct MaterialsListView: View {
	var materials: [String: Int]
	@EnvironmentObject var dataManager: DataManager  // Assuming you have a dataManager object
	
	var body: some View {
		List(dataManager.allMaterials, id: \.self) { material in
			if let quantity = materials[material], quantity > 0 {
				HStack {
					Text(material)
					Spacer()
					Text("\(quantity)")
				}
			}
		}
	}
}

struct EditMaterialRequirementsView: View {
	@EnvironmentObject var dataManager: DataManager
	@State private var expandedDeviceTypes: [String: Bool] = [:]
	@Binding var materialRequirements: [String: [String: Int]]
	@Binding var materialKeys: [String: [String]]
	// State to handle new material addition
	@State private var showingAddMaterialSheet = false
	func saveToUserDefaults() {
		if let encoded = try? JSONEncoder().encode(materialRequirements) {
			UserDefaults.standard.set(encoded, forKey: "MaterialRequirements")
		}
	}
	
	var body: some View {
		HStack {
			List {
				ForEach(dataManager.deviceCategories.keys.sorted(), id: \.self) { category in
					DisclosureGroup(category) {
						ForEach(dataManager.deviceCategories[category]!, id: \.self) { outletType in
							DeviceSectionView(outletType: outletType)
						}
					}
				}
			}
		}
		
	}
	@ViewBuilder
	private func DeviceSectionView(outletType: String) -> some View {
		VStack {
			DisclosureGroup(isExpanded: $expandedDeviceTypes[outletType]) {
				ForEach(materialRequirementKeys(for: outletType), id: \.self) { key in
					materialRequirementRow(outletType: outletType, key: key)
				}
				HStack {
					Button(action: {
						
						showingAddMaterialSheet = true
					}) {
						Label("Add Material", systemImage: "plus.circle.fill")
							.labelStyle(VerticalLabelStyle())
							.foregroundColor(.green)
					}
					.buttonStyle(PlainButtonStyle()) // Prevents the button style from interfering with the tap gesture.
					.sheet(isPresented: $showingAddMaterialSheet) {
						AddMaterialView(
							materialRequirements: $materialRequirements,
							materialKeys: $materialKeys,
						
							selectedDeviceType: outletType)
					}
					.padding(.trailing)
					
					Button(action: {
						saveToUserDefaults()
						expandedDeviceTypes[outletType] = false
					}) {
						Label("Save Changes", systemImage: "checkmark.circle.fill")
							.labelStyle(VerticalLabelStyle())
							.foregroundColor(.blue)
					}
					.buttonStyle(PlainButtonStyle())
					.padding(.leading)
				}
				.padding() // Adjust padding as needed to ensure clear separation from the disclosure group.
			} label: {
				Text(outletType)
					.foregroundStyle(Color.blue)
					.bold()
					.font(.headline)
			}
			.contentShape(Rectangle()) // This ensures the entire area of the disclosure label is tappable, without interfering with the buttons.
		}
		.padding(.vertical) // Adjust padding to ensure sufficient space around sections.
	}
	struct VerticalLabelStyle: LabelStyle {
		func makeBody(configuration: Configuration) -> some View {
			VStack {
				configuration.icon
				configuration.title
			}
		}
	}
	private func materialRequirementKeys(for outletType: String) -> [String] {
		materialRequirements[outletType]?.keys.sorted() ?? []
	}
	
	@ViewBuilder
	private func materialRequirementRow(outletType: String, key: String) -> some View {
		HStack {
			
			Text(key)
				.padding(.leading, 8)  // Padding to separate the text from the minus icon
			
			Spacer()
			
			TextField("Quantity", value: binding(for: outletType, key: key), format: .number)
				.textFieldStyle(RoundedBorderTextFieldStyle())
				.scaledToFit()
			
		}.onAppear {
			
		}
	}
	
	private func binding(for outletType: String, key: String) -> Binding<Int> {
		Binding(
			get: { self.materialRequirements[outletType]?[key] ?? 0 },
			set: { self.materialRequirements[outletType]?[key] = $0 }
		)
	}
}
struct AddMaterialView: View {
	@Binding var materialRequirements: [String: [String: Int]]
	@Binding var materialKeys: [String: [String]]
	
	var selectedDeviceType: String
	
	@State private var selectedMaterial: String = ""
	@State private var materialQuantity: Int = 0
	@Environment(\.dismiss) var dismiss
	func saveToUserDefaults() {
		if let encoded = try? JSONEncoder().encode(materialRequirements) {
			UserDefaults.standard.set(encoded, forKey: "MaterialRequirements")
		}
	}
	private func revertToDefault() {
		// Set materialRequirements to the default values
		materialRequirements =
		DataManager.defaultMaterialRequirements /* Your default materialRequirements here */
		saveToUserDefaults()
	}
	var body: some View {
		NavigationView {
			VStack {
				Text("\(selectedDeviceType)")
				Form {
					Section {
						Picker("Select Material", selection: $selectedMaterial) {
							ForEach(dataManager.allMaterials, id: \.self) {
								Text($0)
							}
						}
						.pickerStyle(WheelPickerStyle())
					}
					
					Section {
						TextField("Quantity", value: $materialQuantity, format: .number)
					}
					
					Section {
						Button("Add Material") {
							addMaterial(
								to: selectedDeviceType, material: selectedMaterial, quantity: materialQuantity)
							saveToUserDefaults()
							dismiss()
							
						}
						Button("Revert to Default Settings") {
							revertToDefault()
						}
						
					}
				}
				
			}
			.navigationBarTitle("Add Material", displayMode: .inline)
		}
	}
	
	// When adding a new material, make sure to update both the dictionary and the keys array
	func addMaterial(to deviceType: String, material: String, quantity: Int) {
		print("material\(material) devicetype \(deviceType) quantity \(quantity)")
		if materialRequirements[deviceType]?[material] == nil {
			materialKeys[deviceType]?.append(material)
			saveToUserDefaults()
			print(
				"material- \(material) devicetype- \(deviceType) quantitiy- \(quantity) materialKeys[\(deviceType)]?.append(\(material)"
			)
		}
		materialRequirements[deviceType]?[material] = quantity
		saveToUserDefaults()
		print(
			"material- \(material) devicetype- \(deviceType) quantitiy- \(quantity) materialRequirements[\(deviceType)]?[\(material)] = \(quantity)"
		)
		
	}
}

//List {
//
//				Section(header: Text("Single Gang Devices").foregroundStyle(dataManager.isDarkMode ? Color.white : Color.black).id(UUID()))  {
//					TextField("Standard Bracket Box", text: $dataManager.bracketBoxDuplex).foregroundColor(Color("Color 6"))
//					TextField("GFCI", text: $dataManager.gfci).foregroundColor(Color("Color 6"))
//					TextField("Cut-In", text: $dataManager.cutin).foregroundColor(Color("Color 6"))
//					TextField("Surface Mounted", text: $dataManager.cutin).foregroundColor(Color("Color 6"))
//					TextField("Controlled", text: $dataManager.controlled).foregroundColor(Color("Color 6"))
//				}.underline()
//				.frame(alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/)
//
//				Section(header: Text("Two-Gang Devices").foregroundStyle(Color("BWText")).font(.title2)) {
//					TextField("Quad Bracket Box", text: $dataManager.quadBracketBox).foregroundColor(Color("Color 6"))
//					Text("hello").foregroundStyle(Color("BWText"))
//					TextField("Quad GFCI", text: $dataManager.quadGFCI).foregroundColor(Color("Color 6"))
//					TextField("Quad Cut-in", text: $dataManager.quadCutIn).foregroundColor(Color("Color 6"))
//					TextField("Quad Surface Mounted", text: $dataManager.quadSurfaceMounted).foregroundColor(Color("Color 6"))
//					TextField("Quad Controlled", text: $dataManager.quadControlled).foregroundColor(Color("Color 6"))
//				}.underline()
//					.frame(alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/)
//
//				Section(header: Text("Single Gang Devices").foregroundStyle(dataManager.isDarkMode ? Color.white : Color.black).id(UUID())) {
//					TextField("Standard Bracket Box", text: $dataManager.bracketBoxDuplex).foregroundColor(Color("Color 6"))
//					TextField("GFCI", text: $dataManager.gfci).foregroundColor(Color("Color 6"))
//					TextField("Cut-In", text: $dataManager.cutin).foregroundColor(Color("Color 6"))
//					TextField("Surface Mounted", text: $dataManager.cutin).foregroundColor(Color("Color 6"))
//					TextField("Controlled", text: $dataManager.controlled).foregroundColor(Color("Color 6"))
//				}
//					.frame(alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/)
//
//				Section(header: Text("Two-Gang Devices").foregroundStyle(Color("BWText")).font(.title2)) {
//					TextField("Quad Bracket Box", text: $dataManager.quadBracketBox).foregroundColor(Color("Color 6"))
//					TextField("Quad GFCI", text: $dataManager.quadGFCI).foregroundColor(Color("Color 6"))
//					TextField("Quad Cut-in", text: $dataManager.quadCutIn).foregroundColor(Color("Color 6"))
//					TextField("Quad Surface Mounted", text: $dataManager.quadSurfaceMounted).foregroundColor(Color("Color 6"))
//					TextField("Quad Controlled", text: $dataManager.quadControlled).foregroundColor(Color("Color 6"))
//				}
//					.frame(alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/)
//
//				Section(header: Text("Furniture Feeds").foregroundStyle(Color("Color 1")).font(.title2)) {
//					TextField("3wire Furniture Feed", text: $dataManager.wire3FurnitureFeed).foregroundColor(Color("Color 6"))
//					TextField("4wire Furniture Feed", text: $dataManager.wire2FurnitureFeed).foregroundColor(Color("Color 6"))
//				}
//					.frame(alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/)
//
//				Section(header: Text("Data Devices").foregroundStyle(Color("Color 1")).font(.title2)) {
//					TextField("Bracket Box Data", text: $dataManager.bracketBoxData).foregroundColor(Color("Color 6"))
//					TextField("Cut-in Data", text: $dataManager.cutInData).foregroundColor(Color("Color 6"))
//				}
//					.frame(alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/)
//
//				Section(header: Text("Line-Voltage Dimming").foregroundStyle(Color("Color 6")).font(.title2)) {
//					TextField("Line-Voltage Dimming Switch", text: $dataManager.lineVoltageDimmingSwitch).foregroundColor(Color("Color 6"))
//					TextField("Line-Voltage Dimming Cut-in", text: $dataManager.lineVoltageDimmingCutin).foregroundColor(Color("Color 6"))
//				}
//					.frame(alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/)
//
//				Section(header: Text("LV/Cat5").foregroundStyle(Color("Color 1")).font(.title2)) {
//					TextField("LV/Cat5 Switch", text: $dataManager.lvCat5Switch).foregroundColor(Color("Color 6"))
//					TextField("LV/Cat5 Cut-in", text: $dataManager.lvCat5Cutin).foregroundColor(Color("Color 6"))
//				}
//					.frame(alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/)
//
//				Section(header: Text("Line-Voltage Switch").foregroundStyle(Color("Color 1")).font(.title2)) {
//					TextField("Line-Voltage Switch", text: $dataManager.lineVoltageSwitch).foregroundColor(Color("Color 6"))
//					TextField("Line-Voltage Cut-in", text: $dataManager.lineVoltageCutIn).foregroundColor(Color("Color 6"))
//				}
//					.frame(alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/)
//
//				Section(header: Text("Floor Devices").foregroundStyle(Color("Color 1")).font(.title2)) {
//					TextField("6in Floor Device", text: $dataManager.inFloorDevice).foregroundColor(Color("Color 6"))
//					TextField("4in Floor Device", text: $dataManager.in6FloorDevice).foregroundColor(Color("Color 6"))
//				}
//					.frame(alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/)
//
//				Section(header: Text("Instahot").foregroundStyle(Color("Color 1")).font(.title2)) {
//					TextField("Single-Pole 277V 40A Instahot", text: $dataManager.singlePole277V40AInstahot).foregroundColor(Color("Color 6"))
//					TextField("Single-Pole 277V 30A Instahot", text: $dataManager.singlePole277V30AInstahot).foregroundColor(Color("Color 6"))
//					TextField("2-Pole 208V 40A Instahot", text: $dataManager.pole208V40AInstahot).foregroundColor(Color("Color 6"))
//				}
//					.frame(alignment: .center)
//			}
//
//			.foregroundColor(.white)
//			.cornerRadius(10)
//			.foregroundStyle(isSaved ? .green : .blue)
//			// Button to toggle editing mode


struct CheckboxToggleStyle: ToggleStyle {
	func makeBody(configuration: Configuration) -> some View {
		HStack {
			
			RoundedRectangle(cornerRadius: 5.0)
				.stroke(lineWidth: 2)
				.frame(width: 25, height: 25)
				.cornerRadius(5.0)
				.overlay {
					Image(systemName: configuration.isOn ? "checkmark" : "")
				}
				.onTapGesture {
					withAnimation(.spring()) {
						configuration.isOn.toggle()
					}
				}
			
			configuration.label
			
		}
	}
}
struct CustomTextField: View {
	var placeholder: String
	@Binding var text: String
	
	var body: some View {
		TextField(placeholder, text: $text)
			.padding()
			.foregroundColor(.green.opacity(0.9))
			.overlay(Rectangle().frame(height: 1).padding(.top, 30).foregroundColor(.blue))
			.padding(4)
	}
}




