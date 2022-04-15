//
//  Array+Extension.swift
//  BlockSort
//
//  Created by VladyslavMac on 15.04.2022.
//

import Foundation

extension Array {
	func getFirst(_ upToIndex: Int) -> [Self.Element] {
		var array: [Self.Element] = []
		var index = 0
		for _ in 0..<upToIndex {
			array.append(self[index])
			index += 1
			if index == count - 1 {
				index = 0
			}
		}
		return array
	}
}
