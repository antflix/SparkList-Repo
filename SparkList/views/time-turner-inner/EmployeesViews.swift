#if false
import SwiftUI

@available(iOS 17.0, *)
struct EmployeesViews: View {
    @EnvironmentObject var dataManager: DataManager // Access DataManager passed via environmentObject

    @State private var showingPopover = false // Create a state variable to control popover visibility

    var isAnyEmployeeAssignedHours: Bool {
        // Check if any employee has assigned hours in DataManager

        return dataManager.employeeData.values.contains(where: { !$0.isEmpty })
    }

	var body: some View {
		VStack {
			VStack(spacing: 1) {
				HStack(spacing: 1) {
//					BackButton(destination: EmployeeView(), isActive: $navigateBack).frame(alignment: .leading)

					VStack {
						Image("3times")
							.aspectRatio(contentMode: .fit)
							.symbolRenderingMode(.palette)
							.foregroundStyle(Color.white, dataManager.themeColor, Color.black)
							.font(Font.title.weight(.ultraLight))
							
						Text("Employees").font(Font.custom("Quicksand", size: 30).bold())
							.frame(maxWidth: .infinity * 0.90, alignment: .center)

						
					}
					Button(action: {
						// Toggle the popover state for this particular row
						showingPopover.toggle()
					}) {
						Image(systemName: "questionmark.circle.fill")
							.foregroundColor(.white)
					}
					.buttonStyle(PlainButtonStyle())
					.popover(isPresented: $showingPopover) {
						VStack(alignment: .leading, spacing: 10) {
							Text("Instructions:")
								.foregroundColor(Color("Color 6"))
								.font(.title)

							Divider()
								.background(Color("Color 6"))

							VStack(alignment: .leading, spacing: 5) {
								HStack {
									Circle().frame(width: 5, height: 5).foregroundColor(Color("Color 1")) // Custom bullet point
									Text("Enter hours for each employee that you are turning in time for then, click").foregroundColor(Color("Color 6"))

									+
									Text(" Submit")
										.foregroundColor(Color("Color 1"))
								}
								.padding()
								HStack {
									Circle().frame(width: 5, height: 5).foregroundColor(Color("Color 1")) // Custom bullet point
									Text("Use a decimal format-\n\t5.5 hours = 5 hours 30 minutes. ").foregroundColor(Color("Color 6"))
								}
								.padding()
								HStack {
									Circle().frame(width: 5, height: 5).foregroundColor(Color("Color 1")) // Custom bullet point
									Text("All partial hour quantities will be rounded to the nearest 30 minutes.").foregroundColor(Color("Color 6"))
								}
								.padding()
							}
							.padding(.horizontal)
						}
						.padding()
						.background(Color("Color 5")) // Replace 'YourBackgroundColor' with desired color
						.cornerRadius(8)
					}
				}
				.padding(.horizontal)
				.background(dataManager.themeColor)
				.foregroundColor(.white)
				.font(.headline)
			}
			ZStack(alignment: .bottom) {
				ScrollView {

					ForEach(dataManager.employeeNames, id: \.self) { name in
						EmployeeRowView(employeeName: name, dataManager: dataManager)
							.padding(.bottom, 0)

							.cornerRadius(8) // Optional: Add corner radius to rows
					}
				}.scrollDismissesKeyboard(.immediately)

				
				HStack {
					Spacer()
					NavigationLink(destination: PreViews()) {
						HStack {
							Text("Next")
								.foregroundColor(Color.green)
								.background(Color.clear)
								.font(.title)
							
							Image(systemName: "arrow.right")
								.foregroundColor(Color.green)
								.font(.title)
								.background(Color.clear)
								.font(.title)
							
						}
					}
						.buttonStyle(PlainButtonStyle())
						.disabled(!isAnyEmployeeAssignedHours)
						.opacity(isAnyEmployeeAssignedHours ? 1.0 : 0.5)
						.frame(alignment: .bottomTrailing)
						.padding()
						.background(Color.clear) // Semi-transparent background
						
						.shadow(radius: 5)
						.padding(.horizontal)
						.padding(.bottom, 0)
					
				}.edgesIgnoringSafeArea(.bottom)
					
				
				

			}.toolbar {MyToolbarItems()}
				.background(Color("Color 7"))
				.navigationBarBackButtonHidden(true) // Hides the back button
				.navigationBarHidden(true)
				.onChange(of: dataManager.isDarkMode) { newValue in
					UserDefaults.standard.set(newValue, forKey: "isDarkMode")
					if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
					   let window = windowScene.windows.first {
						window.rootViewController?.overrideUserInterfaceStyle = newValue ? .dark : .light
					}
				}
		}  .onAppear {
			
		}
	  
	}
}

struct EmployeeRowView: View {
    let employeeName: String
    @ObservedObject var dataManager: DataManager

    @State private var enteredHours: String // State to store the entered hours by the user

    init(employeeName: String, dataManager: DataManager) {
        self.employeeName = employeeName
        self.dataManager = dataManager

        // Fetch the current hours for the employee from the DataManager when initializing the view
        _enteredHours = State(initialValue: dataManager.hoursForEmployee(employeeName))
    }

    var body: some View {
        HStack {
            Text(employeeName)

            Spacer()

            TextField("Enter Hours", text: $enteredHours)
                .keyboardType(.decimalPad)
                .padding(.vertical, 8) // Vertical padding
                .foregroundColor(.green.opacity(0.9)) // Text color
                .overlay(Rectangle().frame(height: 1).padding(.top, 30).foregroundColor(.blue)) // Underline
                .padding(.trailing)
                .onChange(of: enteredHours) { newValue in
                    // Add a delay before handling the entered value
					DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        // Check if the entered value is a valid double
                        if let value = Double(newValue), value >= 0.0 && value <= 24.0 {
                            // Check if the entered value is a whole number or has only one decimal place
                            let isWholeNumber = value.truncatingRemainder(dividingBy: 1) == 0
                            let hasOneDecimalPlace = (value * 10).truncatingRemainder(dividingBy: 1) == 0

                            if isWholeNumber || hasOneDecimalPlace {
                                let roundedValue = (value * 2).rounded() / 2 // Ensure hour and half-hour increments
                                let formattedHours = self.formatHours(roundedValue) // Get formatted hours
                                dataManager.saveEmployeeHours(name: employeeName, hours: formattedHours)
                                enteredHours = formattedHours // Update enteredHours with formatted value
                            }
                        }
                    } // Change placeholder text color
                }
                .foregroundColor(.red) // Change placeholder text color

                .keyboardType(.decimalPad)
        }
    }

    func formatHours(_ hours: Double) -> String {
        let totalMinutes = Int(hours * 60)
        let formattedHours = totalMinutes / 60
        let formattedMinutes = totalMinutes % 60
        if formattedMinutes == 0 {
            return "\(formattedHours) hours"
        } else if formattedMinutes % 30 == 0 {
            return "\(formattedHours) hours \(formattedMinutes) minutes"
        } else {
            return "\(formattedHours) hours \(formattedMinutes) minutes" // Return formatted string
        }
    }
}


#endif
