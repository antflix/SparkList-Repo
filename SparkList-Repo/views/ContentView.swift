//import MessageUI
import SwiftUI


@available(iOS 17.0, *)
struct ContentView: View {
    @StateObject var dataManager = DataManager()
//    @StateObject var darkModeSettings = DataManager() // Use observed object for dark modem



    enum Tab {
        case start, material, jobs, createProject, singleGangView, employee, employees, preview, switches, themes, outletcounter, lightcounter, PDFImagesView, DeviceFinderAPI, API
    }

    @State private var selectedTab: Tab = .start // Track selected tab
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                switch selectedTab {
                case .start:
                    StartView()
                        .environmentObject(dataManager)
                case .jobs:
                    JobsView()

                case .createProject:
                    MaterialListView()
                        .environmentObject(dataManager)
                case .singleGangView:
                    SingleGangView()
                        .environmentObject(dataManager)
                case .material:
                    MaterialFormView()
                        .environmentObject(dataManager)
                case .employee:
                    EmployeeView()
//                          .toolbar{MyToolbarItems()}
                        .environmentObject(dataManager)
                case .employees:
                    EmployeesViews()
//                          .toolbar{MyToolbarItems()}
                        .environmentObject(dataManager)
                case .preview:
                    PreViews()
//                          .toolbar{MyToolbarItems()}
                        .environmentObject(dataManager)
					case .switches:
						SwitchesView()
							.environmentObject(dataManager)
					case .themes:
						ThemeView()
							.environmentObject(dataManager)
					case .outletcounter:
						PanelSchedule()
							.environmentObject(dataManager)
					case .lightcounter:
						LightCounter()
							.environmentObject(dataManager)
					case .PDFImagesView:
						PDFImagesView()
							.environmentObject(dataManager)
					case .DeviceFinderAPI:
						DeviceFinderAPI()
							.environmentObject(dataManager)
					case .API:
						API()
							.environmentObject(dataManager)
//
                }

            }
        }
    }
}

//            if isSettingsViewPresented {
//                GeometryReader { geometry in
//                    VStack {
//                        Spacer()
//                        Image(systemName: "gear")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: geometry.size.width * 0.1, height: geometry.size.width * 0.1) // Adjust icon size dynamically
//                            .foregroundColor(.blue)
//                            .onTapGesture {
//                                withAnimation {
//                                    isSettingsViewPresented.toggle()
//                                }
//                            }
//                    }
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(.leading, geometry.size.width * 0.1) // Adjust padding dynamically
//                    .anchorPreference(key: MyPopoverKey.self, value: .bounds) { anchor in
//                        settingsPopoverAnchor = anchor
//                        return anchor
//                    }
//                }
//                .padding(.top, 50)
//            }
//        }.background(
//                    Color.clear // Ensure this stack is transparent to allow tap through
//                        .popover(
//                            isPresented: $isSettingsViewPresented,
//                            arrowEdge: .leading,
//                            content: {
//                                SettingsView()
//                            }
//                        )
//                )
//        }
//
//
//    struct SettingsHandleView: View {
//        @Binding var isSettingsViewPresented: Bool
//
//        var body: some View {
//            VStack {
//                Spacer()
//                Image(systemName: "gear")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 40, height: 40)
//                    .foregroundColor(.blue)
//                    .onTapGesture {
//                        withAnimation {
//                            isSettingsViewPresented.toggle()
//                        }
//                    }
//                Spacer()
//            }
//            .frame(maxWidth: .infinity, alignment: .leading) // Align to the left
//            .padding(.leading, 100) // Add padding from the left
//        }
//    }
// }
//    struct SettingsView: View {
//        var body: some View {
//            ModeToggleButton().background(Color("Color 5"))
//        }
//    }
//    // Custom key to hold popover anchor
//    struct MyPopoverKey: PreferenceKey {
//        static var defaultValue: Anchor<CGRect>? = nil
//        static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {}
//    }
//
////
// struct SettingsHandleView: View {
//    @Binding var isSettingsViewPresented: Bool
//
//    var body: some View {
//        VStack {
//            Spacer()
//            Image(systemName: "gear")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 40, height: 40)
//                .foregroundColor(.blue)
//                .onTapGesture {
//                    withAnimation {
//                        isSettingsViewPresented.toggle()
//                    }
//                }
//            Spacer()
//        }
//        .frame(maxWidth: .infinity, alignment: .trailing)
//        .padding(.trailing)
//    }
// }
//
// struct SettingsView: View {
//    var body: some View {
//        ModeToggleButton().background(Color("Color 5"))
//
//
//    }
// }

