//
//  AppState.swift
//  BlockSort
//
//  Created by VladyslavMac on 14.04.2022.
//

import Foundation

struct AppState {
	static let shared = AppState()
	
	func setLevel(_ lvl: Int) {
		UserDefaults.standard.set(lvl, forKey: "com.blocksort.level")
	}
	
	func incrementLevel() {
		let lvl = getLevel()
		UserDefaults.standard.set(lvl + 1, forKey: "com.blocksort.level")
	}
	
	func getLevel() -> Int {
		UserDefaults.standard.value(forKey: "com.blocksort.level") as? Int ?? 1
	}
}
