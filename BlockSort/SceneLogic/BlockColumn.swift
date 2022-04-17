//
//  BlockColumn.swift
//  BlockSort
//
//  Created by Vladyslav Baranov on 10.04.2022.
//

import SceneKit

final class ColumnBaseNode: SCNNode {
    weak var column: BlockColumn!
}

final class BlockStep {
    weak var block: Block!
    var previousColumn: BlockColumn!
    var previousPosition: SCNVector3!
}

final class BlockColumn {
	
	static var audioSource: SCNAudioSource!
    static var maxLength = 3
    
    var id = "ID-0"
    
    var globalPosition = SCNVector3()
    var baseNode: ColumnBaseNode
    var blocks: [Block] = [] {
        didSet {
            if blocks.isEmpty {
                baseNode.geometry?.firstMaterial = SCNMaterial.createGlossyMetallicMaterial(diffuseColor: .darkGray)
            }
        }
    }
    
    var isFull: Bool {
        blocks.count == Self.maxLength
    }
    
    init(colors: [UIColor]) {
        baseNode = ColumnBaseNode()
        baseNode.geometry = SCNBox(
            width: CGFloat(Block.blockSize.x) + 0.03,
            height: 0.01,
            length: CGFloat(Block.blockSize.z) + 0.03,
            chamferRadius: 0
        )
        baseNode.column = self
        baseNode.geometry?.firstMaterial = SCNMaterial.createGlossyMetallicMaterial(diffuseColor: colors.first)
        for color in colors {
            let block = Block(color: color)
            block.column = self
            blocks.append(block)
        }
    }
    
    func switchMaterialOnBaseNode(newMaterial: SCNMaterial?, in milliseconds: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(milliseconds)) { [unowned self] in
            baseNode.geometry?.firstMaterial = newMaterial
        }
    }
    
    func setGlobalPosition(x: CGFloat, z: CGFloat) {
        self.globalPosition = .init(x, 0, z)
        var baseBlockY = Block.blockSize.y
        var positionInColumn = 0
        baseNode.position = .init(x, CGFloat(Block.blockSize.y / 2) - 0.005, z)
        for block in blocks {
            block.positionInColumn = positionInColumn
            block.position = .init(x, CGFloat(baseBlockY), z)
            baseBlockY += Block.blockSize.y
            positionInColumn += 1
        }
    }
    
    func removeLast() {
        blocks.removeLast()
        makeTopVisisble()
    }
    
    func add(_ block: Block, putDownAudioSource: SCNAudioSource?) -> BlockStep? {

        if blocks.isEmpty {
            let step = BlockStep()
            step.previousColumn = block.column
            step.previousPosition = block.previousPosition
            step.block = block
            
            block.column.removeLast()
            blocks.append(block)
            let vec = recompute()
            block.move(to: vec)
            block.isSelected = false
            switchMaterialOnBaseNode(newMaterial: block.geometry?.firstMaterial, in: 600)
            
			if AppState.shared.soundsAreOn() {
				DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
					block.runAction(.playAudio(Self.audioSource, waitForCompletion: false))
				}
			}
            return step
        } else {
            if blocks.count == Self.maxLength {
                return nil
            }
            guard let lastBlock = blocks.last else { return nil }
            guard lastBlock.color == block.color else { return nil }
            
            let step = BlockStep()
            step.previousColumn = block.column
            step.previousPosition = block.previousPosition
            step.block = block
            
            block.column.removeLast()
            blocks.append(block)
            let vec = recompute()
            block.move(to: vec)
            block.isSelected = false
			if AppState.shared.soundsAreOn() {
				DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
					block.runAction(.playAudio(Self.audioSource, waitForCompletion: false))
				}
			}
            return step
        }
    }
    
    func recompute() -> SCNVector3 {
        var positionInColumn = 0
        var baseBlockY = Block.blockSize.y
        for block in blocks {
            block.positionInColumn = positionInColumn
            block.column = self
            baseBlockY += Block.blockSize.y
            positionInColumn += 1
        }
        return .init(
            globalPosition.x,
            baseBlockY - Block.blockSize.y,
            globalPosition.z
        )
    }
    
    func allAreSame() -> Bool {
        let colors = blocks.map { $0.color }
        let colorSet = Set(colors)
        return colorSet.count == 1 || colorSet.isEmpty
    }
    
    func makeTopVisisble() {
        blocks.last?.isColorHidden = false
        if blocks.count == 1 {
			SCNTransaction.begin()
			SCNTransaction.animationDuration = 0.5
            baseNode.geometry?.firstMaterial?.diffuse.contents = blocks.last?.color ?? .black
			SCNTransaction.commit()
        }
    }
    
    func setupHiddenMode() {
        baseNode.geometry?.firstMaterial?.diffuse.contents = UIColor.black
        for i in 0..<blocks.count {
            if i == blocks.count - 1 {
                blocks[i].isColorHidden = false
            } else {
                blocks[i].isColorHidden = true
            }
        }
    }
}
