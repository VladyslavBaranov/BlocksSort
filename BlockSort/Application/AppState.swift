//
//  AppState.swift
//  BlockSort
//
//  Created by VladyslavMac on 14.04.2022.
//

import Foundation

struct AppState {
	
	static let shared = AppState()
	
	func getLaunchCount() -> Int {
		UserDefaults.standard.value(forKey: "com.blocksort.launchCount") as? Int ?? 0
	}
	
	func incrementLaunchCount() {
		let count = getLaunchCount()
		UserDefaults.standard.setValue(count + 1, forKey: "com.blocksort.launchCount")
	}
	
	func adsAreOn() -> Bool {
		UserDefaults.standard.value(forKey: "com.blocksort.adson") as? Bool ?? true
	}
	
	func turnOffAds() {
		UserDefaults.standard.set(false, forKey: "com.blocksort.adson")
	}
	
	func soundsAreOn() -> Bool {
		UserDefaults.standard.value(forKey: "com.blocksort.soundson") as? Bool ?? true
	}
	
	func setSoundsState(isOn: Bool) {
		UserDefaults.standard.set(isOn, forKey: "com.blocksort.soundson")
	}
	
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
