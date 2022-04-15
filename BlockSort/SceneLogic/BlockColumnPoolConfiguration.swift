//
//  BlockColumnPoolConfiguration.swift
//  BlockSort
//
//  Created by VladyslavMac on 15.04.2022.
//

import Foundation

struct BlockColumnPoolConfiguration {
	var colorCount: Int = 0
	var emptyColumnsCount = 2
	var mode: BlockColumnPool.Mode = .basic
	
	init() {
		let currentLvl = AppState.shared.getLevel()
		colorCount = 3 + currentLvl / 10
		emptyColumnsCount = 2
		if currentLvl % 3 == 0 {
			mode = .hidden
		} else {
			if currentLvl % 5 == 0 {
				emptyColumnsCount = 1
			}
		}
		if currentLvl > 10 {
			BlockColumn.maxLength = 4
		} else if currentLvl > 50 {
			BlockColumn.maxLength = 5
		} else if currentLvl > 100 {
			BlockColumn.maxLength = 6
		}
	}
}
