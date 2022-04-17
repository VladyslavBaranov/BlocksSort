//
//  BlockColumnPool.swift
//  BlockSort
//
//  Created by Vladyslav Baranov on 10.04.2022.
//

import SceneKit
import StoreKit

protocol BlockColumnPoolDelegate: AnyObject {
	func didSetLevel(_ level: Int)
}

final class BlockColumnPool {
	
	enum Mode {
		case basic
		case hidden
	}
	
	unowned var delegate: BlockColumnPoolDelegate

    weak var putDownAudioSource: SCNAudioSource!
    weak var selectedBlock: Block!
    var pool: [BlockColumn] = []
    var playerSteps: [BlockStep] = []
	
	init(delegate: BlockColumnPoolDelegate) {
		self.delegate = delegate
	}
    
	func touch(_ block: Block) {
        if selectedBlock != nil && selectedBlock.isSelected {
            if block === selectedBlock {
                selectedBlock.unselect()
            } else {
                if let step = block.column.add(selectedBlock, putDownAudioSource: putDownAudioSource) {
                    playerSteps.append(step)
					if playerSteps.count == 5 {
						playerSteps.removeFirst()
					}
                }
            }
        } else {
			guard block.isLastInColumn() else { return }
            selectedBlock = block
            
            let columnIsNotSelectable = selectedBlock.column.allAreSame() && selectedBlock.column.isFull
            if selectedBlock.isLastInColumn() && !columnIsNotSelectable {
                selectedBlock.select()
            }
        }
		
		let winState = checkWinState()
		if winState {
			
			if AppState.shared.getLaunchCount() == 3 {
				if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
					SKStoreReviewController.requestReview(in: scene)
				}
			}
			
			AppState.shared.incrementLevel()
			delegate.didSetLevel(AppState.shared.getLevel())
		}
    }
    
    func undoLast() {
        guard let step = playerSteps.last else { return }
        step.block.position = step.previousPosition
        step.block.isSelected = false
        
        step.block.column.removeLast()
        
        step.previousColumn.blocks.append(step.block)

        for column in pool {
            _ = column.recompute()
        }
        playerSteps.removeLast()
    }
    
    func touch(_ platform: ColumnBaseNode) {
		
		let winState = checkWinState()
		if winState {
			
			if AppState.shared.getLaunchCount() == 3 {
				if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
					SKStoreReviewController.requestReview(in: scene)
				}
			}
			
			AppState.shared.incrementLevel()
			delegate.didSetLevel(AppState.shared.getLevel())
		} else {
			if let selectedBlock = selectedBlock {
				if platform.column.blocks.isEmpty {
					if let step = platform.column.add(selectedBlock, putDownAudioSource: putDownAudioSource) {
						playerSteps.append(step)
						if playerSteps.count == 5 {
							playerSteps.removeFirst()
						}
					}
				}
			}
		}
    }
    
    func checkWinState() -> Bool {
		let winState = pool.allSatisfy { column in
			(column.isFull && column.allAreSame()) || column.blocks.count == 0
		}
		return winState
    }
    
	static func createColorsSets(colorCount: Int) -> [[UIColor]] {
		
		let availableColors: [UIColor] = [.lightGray, .yellow, .green, .orange, .red, .blue, .purple, .magenta, .brown]
		let colorSet: [UIColor] = availableColors.getFirst(colorCount)
        var input: [UIColor] = []
        for _ in 0..<BlockColumn.maxLength {
            for i in 0..<colorCount {
                input.append(colorSet[i])
                input.shuffle()
            }
        }

		input.shuffle()
		
        var output: [[UIColor]] = []
        
        var index = 0
        for _ in 0..<colorSet.count {
            var set = [UIColor]()
            for _ in 0..<BlockColumn.maxLength {
                set.append(input[index])
                index += 1
            }
            output.append(set)
        }
        
        // print(output)
        return output
    }
    
	static func createPool(
		colorCount: Int,
		emptyPlatformsCount: Int,
		mode: Mode,
		delegate: BlockColumnPoolDelegate
	) -> BlockColumnPool {
		let pool = BlockColumnPool(delegate: delegate)
        
        var globalXPosition: CGFloat = 0.0
        var globalZPosition: CGFloat = 0.0
        
		let sets = Self.createColorsSets(colorCount: colorCount)
        var columns: [BlockColumn] = []
        
        var index = 0
        for aSet in sets {
            let column = BlockColumn(colors: aSet)
            column.id = "ID-\(index)"
            column.setGlobalPosition(x: globalXPosition, z: globalZPosition)
            globalZPosition += 0.2
            columns.append(column)
            index += 1
            if index % 3 == 0 {
                globalXPosition += 0.2
                globalZPosition = 0
            }
			if mode == .hidden {
				column.setupHiddenMode()
			}
        }
        for _ in 0..<emptyPlatformsCount {
            let emptyColumn = BlockColumn(colors: [])
            emptyColumn.id = "ID-\(index)"
            emptyColumn.setGlobalPosition(x: globalXPosition, z: globalZPosition)
            globalZPosition += 0.2
            columns.append(emptyColumn)
            index += 1
            if index % 3 == 0 {
				globalXPosition += 0.2
                globalZPosition = 0.0
            }
        }
        pool.pool = columns
        return pool
    }
}
