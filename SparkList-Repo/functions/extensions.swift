import SwiftUI
extension Binding where Value == [String: Bool] {
	subscript(key: String) -> Binding<Bool> {
		Binding<Bool>(
			get: { self.wrappedValue[key, default: false] },
			set: { self.wrappedValue[key] = $0 }
		)
	}
}
//  extensions.swift
//  SparkList
//
//  Created by User on 12/8/23.




