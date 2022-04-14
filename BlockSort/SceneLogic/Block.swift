//
//  Block.swift
//  BlockSort
//
//  Created by Vladyslav Baranov on 10.04.2022.
//

import SceneKit

final class Block: SCNNode {
    static let blockSize = SCNVector3(0.06, 0.15, 0.06)
    
    var positionInColumn = -1
    var isColorHidden = false {
        didSet {
            geometry?.firstMaterial = SCNMaterial.createGlossyMetallicMaterial(diffuseColor: isColorHidden ? .black : color)
        }
    }
    var color: UIColor
    var previousPosition: SCNVector3?
    var isSelected = false
    
    weak var column: BlockColumn!
    
    init(color: UIColor) {
        self.color = color
        super.init()
        castsShadow = false
        geometry = SCNBox(
            width: CGFloat(Self.blockSize.x),
            height: CGFloat(Self.blockSize.y),
            length: CGFloat(Self.blockSize.z),
            chamferRadius: 0
        )
        geometry?.firstMaterial = SCNMaterial.createGlossyMetallicMaterial(diffuseColor: color)
        name = "block-\(UUID().uuidString)"
    }
    
    func isLastInColumn() -> Bool {
        let columnLen = column.blocks.count
        return columnLen == positionInColumn + 1
    }
    
    func select() {
        previousPosition = position
        runAction(.move(to: .init(position.x, Block.blockSize.y * Float(BlockColumn.maxLength + 1), position.z), duration: 0.3))
        isSelected = true
    }
    
    func unselect() {
        if previousPosition != nil {
            runAction(.move(to: previousPosition!, duration: 0.3))
            // previousPosition = nil
        }
        isSelected = false
    }
    
    func move(to position: SCNVector3) {
        runAction(.sequence([
            .move(to: .init(position.x, self.position.y, position.z), duration: 0.3),
            .move(to: .init(position.x, position.y, position.z), duration: 0.3)
        ]))
        // previousPosition = nil
    }
    
    func twitch() {
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
