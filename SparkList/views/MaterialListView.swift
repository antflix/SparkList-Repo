//
//  MaterialListView.swift
//  SparkTime
//
//  Created by User on 12/30/23.
//
import Foundation
import SwiftUI


// Add other properties as needed
struct Material: Identifiable, Decodable {
    var id: Optional<Int>
    var name: String
    var quantity: Int

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case quantity
        case projectId = "project_id"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        quantity = try container.decode(Int.self, forKey: .quantity)
      
    }
}

@available(iOS 17.0, *)
struct MaterialFormView: View {
	@EnvironmentObject var dataManager: DataManager
    @State private var isSaved: Bool = false
    @State private var isFetched: Bool = false

    @State private var bracketBoxDuplex = ""
    @State private var gfci = ""
    @State private var cutin = ""
    @State private var surfaceMounted = ""
    @State private var controlled = ""

    @State private var quadBracketBox = ""
    @State private var quadGFCI = ""
    @State private var quadCutIn = ""
    @State private var quadSurfaceMounted = ""

    @State private var wire3FurnitureFeed = ""
    @State private var wire2FurnitureFeed = ""

    @State private var bracketBoxData = ""
    @State private var cutInData = ""

    @State private var lineVoltageDimmingSwitch = ""
    @State private var lineVoltageDimmingCutin = ""

    @State private var lvCat5Switch = ""
    @State private var lvCat5Cutin = ""

    @State private var lineVoltageSwitch = ""
    @State private var lineVoltageCutIn = ""

    @State private var inFloorDevice = ""
    @State private var in6FloorDevice = ""
    @State private var singlePole277V40AInstahot = ""
    @State private var pole208V40AInstahot = ""
    @State private var singlePole277V30AInstahot = ""

    @State private var materials: [Material] = []

	var body: some View {
		ZStack {
			
			VStack {
				Form {
					Section(header: Text("Single Gang Devices").foregroundStyle(dataManager.isDarkMode ? Color.black : Color.white))  {
						HStack {
							
							TextField("Enter Quantity", text: $bracketBoxDuplex)
							
								.foregroundColor(Color("Color 6"))
							
						}
						TextField("GFCI", text: $gfci).foregroundColor(Color("Color 6"))
						TextField("Cut-in", text: $cutin).foregroundColor(Color("Color 6"))
						TextField("Surface Mounted", text: $surfaceMounted).foregroundColor(Color("Color 6"))
						TextField("Controlled", text: $controlled).foregroundColor(Color("Color 6")).background(Color.white.opacity(0.0001))
						
					}
					.padding(.vertical, 8) // Vertical padding
					.foregroundColor(.green.opacity(0.9)) // Text color
					.overlay(Rectangle().frame(height: 1).padding(.top, 30).foregroundColor(.blue)) // Underline
					.padding(.trailing).scrollContentBackground(.hidden)
					
					.frame(alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/)
					
					Section(header: Text("Single Gang Devices").foregroundStyle(dataManager.isDarkMode ? Color.white : Color.black).id(UUID()))  {
						TextField("Standard Bracket Box", text: $dataManager.bracketBoxDuplex).foregroundColor(Color("Color 6"))
						TextField("GFCI", text: $gfci).foregroundColor(Color("Color 6"))
						TextField("Cut-in", text: $cutin).foregroundColor(Color("Color 6"))
						TextField("Surface Mounted", text: $surfaceMounted).foregroundColor(Color("Color 6"))
						TextField("Controlled", text: $controlled).foregroundColor(Color("Color 6")).background(Color.white.opacity(0.0001))
					}/*.background(Color.white.opacity(0.0001))*/
					.frame(alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/)
					
					Section(header: Text("Two-Gang Devices").foregroundStyle(Color("BWText")).font(.title2)) {
						TextField("Quad Bracket Box", text: $quadBracketBox).foregroundColor(Color("BWText"))
						
						TextField("Quad GFCI", text: $quadGFCI).foregroundColor(Color("Color 6"))
						TextField("Quad Cut-in", text: $quadCutIn).foregroundColor(Color("Color 6"))
						TextField("Quad Surface Mounted", text: $quadSurfaceMounted).foregroundColor(Color("Color 6"))
					}.underline()
						.frame(alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/)
					
					Section(header: Text("Furniture Feeds").foregroundStyle(Color("Color 1")).font(.title2)) {
						TextField("3wire Furniture Feed", text: $wire3FurnitureFeed).foregroundColor(Color("Color 6"))
						TextField("4wire Furniture Feed", text: $wire2FurnitureFeed).foregroundColor(Color("Color 6"))
					}.underline()
						.frame(alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/)
					
					Section(header: Text("Data Devices").foregroundStyle(Color("Color 1")).font(.title2)) {
						TextField("Bracket Box Data", text: $bracketBoxData).foregroundColor(Color("Color 6"))
						TextField("Cut-in Data", text: $cutInData).foregroundColor(Color("Color 6"))
					}.underline()
						.frame(alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/)
					
					Section(header: Text("Line-Voltage Dimming").foregroundStyle(Color("Color 6")).font(.title2)) {
						TextField("Line-Voltage Dimming Switch", text: $lineVoltageDimmingSwitch).foregroundColor(Color("Color 6"))
						TextField("Line-Voltage Dimming Cutin", text: $lineVoltageDimmingCutin).foregroundColor(Color("Color 6"))
					}.underline()
						.frame(alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/)
					
					Section(header: Text("LV/Cat5").foregroundStyle(Color("Color 1")).font(.title2)) {
						TextField("LV/Cat5 Switch", text: $lvCat5Switch).foregroundColor(Color("Color 6"))
						TextField("LV/Cat5 Cut-in", text: $lvCat5Cutin).foregroundColor(Color("Color 6"))
					}.underline()
						.frame(alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/)
					
					Section(header: Text("Line-Voltage Switch").foregroundStyle(Color("Color 1")).font(.title2)) {
						TextField("Line-Voltage Switch", text: $lineVoltageSwitch).foregroundColor(Color("Color 6"))
						TextField("Line-Voltage Cut-in", text: $lineVoltageCutIn).foregroundColor(Color("Color 6"))
					}.underline()
						.frame(alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/)
					
					Section(header: Text("Floor Devices").foregroundStyle(Color("Color 1")).font(.title2)) {
						TextField("6in Floor Device", text: $inFloorDevice).foregroundColor(Color("Color 6"))
						TextField("4in Floor Device", text: $in6FloorDevice).foregroundColor(Color("Color 6"))
					}.underline()
						.frame(alignment: /*@START_MENU_TOKEN@*/ .center/*@END_MENU_TOKEN@*/)
					
					Section(header: Text("Instahot").foregroundStyle(Color("Color 1")).font(.title2)) {
						TextField("Single-Pole 277V 40A Instahot", text: $singlePole277V40AInstahot).foregroundColor(Color("Color 6"))
						TextField("2-Pole 208V 40A Instahot", text: $pole208V40AInstahot).foregroundColor(Color("Color 6"))
						TextField("Single-Pole 277V 30A Instahot", text: $singlePole277V30AInstahot).foregroundColor(Color("Color 6"))
					}.underline()
						.frame(alignment: .center)
					
//					Button(isSaved ? "Calculated" : "Calculate Material") {
//						Task {
//							await submitForm()
//							fetchMaterials(projectName: dataManager.projectName) { result in
//								switch result {
//									case let .success(fetchedMaterials):
//										self.materials = fetchedMaterials
//										isFetched = true
//									case let .failure(error):
//										// Handle the error, maybe show an alert or a placeholder text
//										print("Error fetching materials: \(error)")
//										isError = true
//								}
//							}
//						}
//					}.padding()
						.frame(maxWidth: .infinity)
					//					.background(isError ? .red : .green)
						.foregroundColor(.white)
						.cornerRadius(10)
						.foregroundStyle(isSaved ? .green : .blue)
				}.scrollContentBackground(.hidden)
					.padding(.top, 50)//
				ScrollView {
					VStack(alignment: .leading) {
						ForEach(materials) { material in
							VStack(alignment: .leading) {
								Text("\(material.name)- ").foregroundStyle(Color.black)
								+
								Text("\(material.quantity)").foregroundStyle(Color.yellow.opacity(0.7))
							}
						}
					}
					
				}.frame(maxHeight: isFetched ? 300 : 0)
			}.padding(.top, 70)
			
			
		}
    }


    // Function to create a new project



}


@available(iOS 17.0, *)
struct MaterialListView: View {
//	@State private var gradientA: [Color] = [.black, .blue]
//	@State private var gradientB: [Color] = [.red, .purple]
	    @State private var materialRequirements: [String: [String: Int]] = [:]  // Initialize appropriately


	@State private var showMenu = false

	@State private var selected = 0
	func loadFromUserDefaults() {
		if let savedData = UserDefaults.standard.data(forKey: "MaterialRequirements"),
		   let decodedData = try? JSONDecoder().decode([String: [String: Int]].self, from: savedData)
		{
			self.materialRequirements = decodedData
		} else {
			self.materialRequirements = DataManager.defaultMaterialRequirements
		}
	}
	var body: some View {
		
		ZStack {
			if dataManager.isDarkMode {
				blueGradient()
			} else {
				lightblueGradient()
			}
			TabView(selection: $selected) {
				VStack {
					SingleGangView()
					
				}.tag(0)
				VStack {
					BoxTypeView()
					
				}.tag(1)
				
				VStack {
					SwitchesView()
					
				}.tag(2)
				VStack {
					
					MiscView()
				}.tag(3)
				VStack {
					
					OutletCalculatorView()
					
				}.tag(4)
				
			}
			.indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
			.tabViewStyle(PageTabViewStyle())
//			.onChange(of: selected, perform: { value in
//				withAnimation(.spring()) {
//					self.setGradient(gradient: [Color.black, Color.blue])
//				}
//			})
			.navigationBarHidden(true)
			.modifier(DarkModeLightModeBackground())
			SlideMenu( isShowing: $showMenu, materialRequirements: $materialRequirements)

			
		}
		.id(dataManager.isDarkMode) 
		.edgesIgnoringSafeArea(.all)
		.onAppear { loadFromUserDefaults() }
	
		// Sliding Menu
	}

}
//
//
//@available(iOS 17.0, *)
//struct MaterialListView_Previews: PreviewProvider {
//	static var previews: some View {
//		MaterialListView()
//	}
//}
