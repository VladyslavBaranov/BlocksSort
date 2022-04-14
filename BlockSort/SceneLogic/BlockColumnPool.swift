//
//  BlockColumnPool.swift
//  BlockSort
//
//  Created by Vladyslav Baranov on 10.04.2022.
//

import SceneKit

final class BlockColumnPool {

    weak var putDownAudioSource: SCNAudioSource!
    weak var selectedBlock: Block!
    var pool: [BlockColumn] = []
    var playerSteps: [BlockStep] = []
    
    func touch(_ block: Block) {
        
        print("#", block.isLastInColumn(), block.column.id, block.positionInColumn)
        
        if selectedBlock != nil && selectedBlock.isSelected {
            if block === selectedBlock {
                selectedBlock.unselect()
            } else {
                if let step = block.column.add(selectedBlock, putDownAudioSource: putDownAudioSource) {
                    playerSteps.append(step)
                }
                
            }
        } else {
            selectedBlock = block
            
            let columnIsNotSelectable = selectedBlock.column.allAreSame() && selectedBlock.column.isFull
            if selectedBlock.isLastInColumn() && !columnIsNotSelectable {
                selectedBlock.select()
                // print("#SELECT")
            } else {
                // print("#UNSELECT")
            }
        }
    }
    
    func undoLast() {
        guard let step = playerSteps.last else { return }
        step.block.position = step.previousPosition
        step.block.isSelected = false
        
        step.block.column.removeLast()
        print(step.block.column.blocks.count)
        
        step.previousColumn.blocks.append(step.block)

        for column in pool {
            _ = column.recompute()
        }
        playerSteps.removeLast()
    }
    
    func touch(_ platform: ColumnBaseNode) {
        
        if let selectedBlock = selectedBlock {
            if let step = platform.column.add(selectedBlock, putDownAudioSource: putDownAudioSource) {
                playerSteps.append(step)
            }
            
            let winState = checkWinState()
            if winState {
                print("!!!WON!!!")
            }
            // print("#IS WON: \(winState)")
        }
    }
    
    func checkWinState() -> Bool {
        for column in pool {
            if !column.allAreSame() {
                return false
            }
        }
        return true
    }
    
    static func createColorsSets() -> [[UIColor]] {
        let colorSet: [UIColor] = [.orange, .lightGray, .blue, .purple, .red, .yellow]
        var input: [UIColor] = []
        for _ in 0..<BlockColumn.maxLength {
            for i in 0..<colorSet.count {
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
    
    static func createPool() -> BlockColumnPool {
        let pool = BlockColumnPool()
        
        var globalXPosition: CGFloat = 0.0
        var globalZPosition: CGFloat = 0.0
        
        let sets = Self.createColorsSets()
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
            column.setupHiddenMode()
        }
        for _ in 0...1 {
            let emptyColumn = BlockColumn(colors: [])
            emptyColumn.id = "ID-\(index)"
            emptyColumn.setGlobalPosition(x: globalXPosition, z: globalZPosition)
            globalZPosition += 0.2
            columns.append(emptyColumn)
            index += 1
            if index % 3 == 0 {
                globalXPosition = 0
                globalZPosition += 0.2
            }
        }
        pool.pool = columns
        return pool
    }
}
