//
// Copyright © 2024 Anthony. All rights reserved.
// 
import SwiftyJSON
import SwiftUI
import Foundation
class ProjectsViewModel: ObservableObject {
	@Published var projects = [Project]()

	func loadProjects() {
		guard let url = URL(string: "https://api.yourdomain.com/projects") else {
			print("Invalid URL")
			return
		}

		let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
			guard let data = data, error == nil else {
				print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
				return
			}

			// Parse data with SwiftyJSON
			let json = JSON(data)
			let projectsItems = json["data"]["projects_items"]["edges"].arrayValue
			DispatchQueue.main.async {
				self?.projects = projectsItems.map { Project(json: $0["node"]) }
			}
		}

		task.resume()
	}
}
struct Project {
	var id: String
	var number: String
	var name: String
	var projectOwner: String
	var createdAt: String
	var active: String
	var link: String
	var canArchive: String

	init(json: JSON) {
		id = json["id"].stringValue
		number = json["number"].stringValue
		name = json["name"].stringValue
		projectOwner = json["project_owner"].stringValue
		createdAt = json["created_at"].stringValue
		active = json["active"].stringValue
		link = json["link"].stringValue
		canArchive = json["can_archive"].stringValue
	}
}

struct API: View {
	@StateObject private var viewModel = ProjectsViewModel()
	@State public var showlist = false
	var body: some View {
		VStack {
			Button(
				action: {
					test()
					self.showlist.toggle()
					print(viewModel.projects.isEmpty)
				},
				label: {Image(systemName: "cloud.heavyrain.fill")
					.foregroundColor(.red)
					.font(.largeTitle) }
			)
			if showlist == true {
				List(viewModel.projects, id: \.id) { project in
					VStack(alignment: .leading) {
						Text(project.name).font(.headline)
						Text("Name: \(project.name)").font(.subheadline)
						Text("ID: \(project.id)").font(.caption)

					}.foregroundStyle(Color.white)
				}.foregroundStyle(Color.white)

			}

		}
		.onAppear {
			viewModel.loadProjects()
		}

	}
	
	func test() {
		let jsonData = [
			"title": "Projects Table",
			"columns": [
				[
					"title": " "
				],
				[
					"title": "Project Number"
				],
				[
					"title": "Project Name"
				],
				[
					"title": "Project Creator"
				],
				[
					"title": "Created"
				],
				[
					"title": "Status"
				],
				[
					"title": "Actions"
				]
			],
			"search_method": "projects_items",
			"query": "{\n      projects_items(order_direction: \"asc\", order_column: \"favorite\", after: \"MjU=\", first: 25, last: 25) {\n        totalCount\n        pageInfo {\n          endCursor\n          hasNextPage\n          hasPreviousPage\n          startCursor\n          startCursor\n        }\n        edges {\n          node           {            id            number            name            project_owner            created_at            active            link            favorite            can_archive          }        \n        }\n      }\n    }"
		] as [String : Any]
		let data = try! JSONSerialization.data(withJSONObject: jsonData, options: [])

		let url = URL(string: "https://buildingblok.com/graphql")!
		let headers = [
			"accept": "*/*",
			"accept-language": "en-US,en;q=0.9",
			"content-type": "application/json",
			"cookie": "_ga=GA1.1.2112204833.1713630368; intercom-id-vdn31q4n=cf177858-bb6b-4bde-8d21-fec9793843f7; intercom-device-id-vdn31q4n=9acfc1a3-fdb2-401c-9001-fd052aa1cac8; masquerading=false; things-todo=; _ga_GK3B2SL2VG=GS1.1.1713666493.4.1.1713667145.0.0.0; intercom-session-vdn31q4n=VWtRdEczc0xYSERGRkh5MzJIT25IcHF2K1FzT24wbVVMZHdqUjcwTldaTk9xSUdSZS9TVmVoQVBOY2NKeCtDSS0tbjB3R0Z2SkFmZWNuenNnRktybnBiUT09--b850565200956f542d1357be2d463addd2791cf0; _bbapps_session=VFBud1dEclE1ZmhNTENIa1RzazFCNjUzbXk3RWVNTEl2c2lLd1BhTllLWkc0amt4YlkzK3lKcy9MZVpqNFI3UG80WXRuQUE0bEJySXQrS0ZkY0xQMmxuQ1BpWkJ4K2dNRGcvWXB1MTArTCt2Z3pjczl1dDVIK2VSVHBEUWk3M3IrRTE1YUtEOEpud3czMzh4aFlsM2VSalQzdklmenFpaEUrcmVhWWR4RGVNbHBZOE52eG90UXptT3RybjNvdmp2bUxDeG5yOE1VQ0h6WFlQZ1JlSUxQNFgxNndFaGlVc2xURFJTQnU3M0FYTDN1b2NOcmVZV2p5ekVsMjFNek5tYms4bFgrMU1uZ0MxcDNNN3UxZ2w4N2c9PS0td0gxNGVkT1hwSko3bEtwRHVtSXBpZz09--42526d08505136f840ec9f9ec3fe8f16303e4b46",
			"origin": "https://buildingblok.com",
			"priority": "u=1, i",
			"referer": "https://buildingblok.com/projects/active",
			"sec-ch-ua": "\"Chromium\";v=\"124\", \"Google Chrome\";v=\"124\", \"Not-A.Brand\";v=\"99\"",
			"sec-ch-ua-mobile": "?0",
			"sec-ch-ua-platform": "\"macOS\"",
			"sec-fetch-dest": "empty",
			"sec-fetch-mode": "cors",
			"sec-fetch-site": "same-origin",
			"user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
			"x-csrf-token": "inZn+/hkPy4DU7KBOh6o/RGx2nw3UBfdrih64tfrSo6ZoxyP4RHjmjTGZiHnVbHISP7iJXnSc1GTb+G/bBAgog=="
		]

		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.allHTTPHeaderFields = headers
		request.httpBody = data as Data

		let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
			if let error = error {
				print(error)
			} else if let data = data {
				let str = String(data: data, encoding: .utf8)
				print(str ?? "")
			}
		}

		task.resume()
	}
}

#Preview {
    API()
}
