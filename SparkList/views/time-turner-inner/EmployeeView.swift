#if false
// Created a new SwiftUI file for a modified version of the EmployeesView
import SwiftUI
@available(iOS 17.0, *)
struct EmployeeView: View {
    @EnvironmentObject var dataManager: DataManager // Access DataManager passed via environmentObject
    @State private var selectedEmployees: [String] = [] // Store selected employee names
  @State private var selectedHours = 0
    @Environment(\.colorScheme) var colorScheme
    @State private var showingPopover = false // Create a state variable to control

    // Add a computed property to check if selections are made
    var isSelectionComplete: Bool {
        return !selectedEmployees.isEmpty && selectedHours != 0
    }
    var isEmployeeComplete: Bool {
        return !selectedEmployees.isEmpty
    }
	
    var body: some View {
		VStack {
			VStack(spacing: 1) {
				
				HStack(spacing: 1) {
					
//					BackButton(destination: JobsView(), isActive: $navigateBack).frame(alignment: .leading)
					
					VStack {
						Image("3time")
							.aspectRatio(contentMode: .fit)
							.symbolRenderingMode(.palette)
							.font(Font.title.weight(.ultraLight))						.foregroundStyle(Color.white, dataManager.themeColor, Color.black)
						
						Text("Employee Hours").font(Font.custom("Quicksand", size: 30).bold())
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
							
							Divider().frame(height: 2.0).background(
								Color("Color 1")
							).padding(.horizontal)
							
							VStack(alignment: .leading, spacing: 5) {
								HStack {
									Circle().frame(width: 5, height: 5).foregroundColor(Color("Color 1")) // Custom bullet point
									Text("Select all of the employees that showed up on time and didnt leave early")
										.foregroundColor(Color("Color 6"))
								}
								.padding()
								HStack {
									Circle().frame(width: 5, height: 5).foregroundColor(Color("Color 1")) // Custom bullet point
									Text("At the bottom, select the amount of hours that everyone worked for the day")
										.foregroundColor(Color("Color 6"))
								}
								.padding()
								HStack {
									Circle().frame(width: 5, height: 5).foregroundColor(Color("Color 1")) // Custom bullet point
									Text("If your tuning in time for an employee who showed up late, left early or came from another job, select")
										.foregroundColor(Color("Color 6"))
									+
									Text(" Individual Hours").bold().fontWeight(.heavy)
										.foregroundColor(dataManager.themeColor)
									+
									Text(" otherwise, click")
										.foregroundColor(Color("Color 6"))
									+
									Text(" Next").bold().fontWeight(.heavy)
										.foregroundColor(dataManager.themeColor)
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
				ZStack {
					ScrollView {
						ForEach(dataManager.employeeNames, id: \.self) { employeeName in
							EmployeeSelectionRow(
								name: employeeName, isSelected: selectedEmployees.contains(employeeName)
							) {
								if let index = selectedEmployees.firstIndex(of: employeeName) {
									selectedEmployees.remove(at: index) // Toggle employee selection
								} else {
									selectedEmployees.append(employeeName)
								}
							}
						}
					}.scrollDismissesKeyboard(.interactively)
					
					
				}
				Divider().frame(height: 2.0).background(
					Color("Color 2")
				).padding(.horizontal)
				ZStack(alignment: .bottom) {
					Picker("Hours Worked", selection: $selectedHours) {
						ForEach(0 ..< 49, id: \.self) { index in
							let hours = index / 2
							let minutes = (index % 2) * 30
							if minutes == 0 {
								Text("\(hours) hours")
									.foregroundColor(Color("Color 3"))
								
									.tag(index)
							} else {
								Text("\(hours) hours \(minutes) minutes")
									.foregroundColor(Color("Color 3"))
									.tag(index)
							}
						}
					}
					.disabled(!isEmployeeComplete)
					.opacity(isEmployeeComplete ? 1.0 : 0.5) // Adjust opacity based on the selection status
					.pickerStyle(WheelPickerStyle())
					.labelsHidden()
					.onChange(of: selectedHours) { newValue in
						let hours = newValue / 2
						let minutes = (newValue % 2) * 30
						var userSelectedHours = ""
						if minutes == 0 {
							userSelectedHours = "\(hours) hours"
						} else {
							userSelectedHours = "\(hours) hours \(minutes) minutes"
						}
						
						for employeeName in selectedEmployees {
							dataManager.saveEmployeeHours(name: employeeName, hours: userSelectedHours)
						}
					}
					//					Divider().frame(height: 2.0).background(
					//						Color("Color 2")
					//					).padding(.horizontal)
					
					//				ZStack(alignment: .bottom) {
					//					Picker (){
					//					}
					//					HStack{
					//						NavigationLink(){
					//							HStack {
					//							}
					//						}
					//						Spacer()
					//						NavigationLink(){
					//							HStack {
					//							}
					//						}
					//					}.padding()
					//						.background(Color.clear) // Semi-transparent background
					//						.cornerRadius(10)
					//						.shadow(radius: 5)
					//						.padding(.horizontal)
					//						.padding(.bottom, 80)
					//				}.edgesIgnoringSafeArea(.bottom)
					
				
					HStack() {
						NavigationLink(destination: EmployeesViews()) {
							HStack {
								Image(systemName: "arrow.up")
									.foregroundColor(Color.green)
									.font(.title)
									.background(Color.clear)
								VStack {
									Text("Custom")
										.foregroundColor(Color.green)
										.background(Color.clear)
										.frame(alignment: .leading)
										.font(.title2)
									
								}
							}.frame(alignment: .bottomLeading)
						}
						.ignoresSafeArea()
						.buttonStyle(PlainButtonStyle())
						.frame(alignment: .leading)
						
						Spacer()
						NavigationLink(destination: PreViews()) {
							HStack {
								Text("Next")
									.foregroundColor(Color.green)
									.background(Color.clear)
									.font(.title2)
								
								Image(systemName: "arrow.right")
									.foregroundColor(Color.green)
									.font(.title2)
									.background(Color.clear)
								
							}
						}  .ignoresSafeArea()
							.buttonStyle(PlainButtonStyle())
							.disabled(!isSelectionComplete)
							.opacity(isSelectionComplete ? 1.0 : 0.5)
							.frame(alignment: .bottomTrailing)
						
					}.padding()
						.background(Color.clear) // Semi-transparent background
						.cornerRadius(10)
						.shadow(radius: 5)
						.padding(.horizontal)
						.padding(.bottom, 0)
					
				}.edgesIgnoringSafeArea(.bottom)
				Divider().frame(height: 1.0).background(
					Color(.green)
				).padding(.vertical, 1)
			}
        }.background(Color("Color 7"))
            .font(colorScheme == .dark ? .headline : .headline)
			.toolbar {MyToolbarItems()}
            .navigationBarBackButtonHidden(true) // Hides the back button
            .navigationBarHidden(true)
            .onChange(of: dataManager.isDarkMode) { newValue in
                UserDefaults.standard.set(newValue, forKey: "isDarkMode")
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.rootViewController?.overrideUserInterfaceStyle = newValue ? .dark : .light
                }
            }

    }
//
//	if [[ "$(uname -m)" == arm64 ]]; then
//	export PATH="/opt/homebrew/bin:$PATH"
//	fi
//	if which swiftlint >/dev/null; then
//	swiftlint --fix && swiftlint
//	else
//		echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
//		fi

    //        .foregroundColor(colorScheme == .dark ? dataManager.themeColor : Color.black)

}

struct EmployeeSelectionRow: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        HStack {
            Text(name)
                .foregroundColor(isSelected ? .green : .blue)

            Spacer()

            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? .green : .gray)
        }
        .padding(.horizontal)
        .padding(.vertical, 2)
        .contentShape(Rectangle()) // Set the shape for the hit testing area
        .onTapGesture {
            action() // Perform action when the row is tapped
        }
        
    }


}

#endif
