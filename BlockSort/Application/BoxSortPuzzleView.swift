//
//  BoxSortPuzzleView.swift
//  BlockSort
//
//  Created by Vladyslav Baranov on 10.04.2022.
//

import SceneKit

final class BoxSortPuzzleView: SCNView {

    var pool: BlockColumnPool!
    var puzzleScene: SCNScene!
    
    private func addBlockColumn(_ column: BlockColumn) {
        puzzleScene.rootNode.addChildNode(column.baseNode)
        for block in column.blocks {
            puzzleScene.rootNode.addChildNode(block)
        }
    }
    
    override init(frame: CGRect, options: [String : Any]? = nil) {
        super.init(frame: frame, options: options)
        puzzleScene = SCNScene()
        isJitteringEnabled = true
        antialiasingMode = .multisampling2X
        puzzleScene.background.contents = UIColor(red: 0.12, green: 0.06, blue: 0.12, alpha: 1)
        scene = puzzleScene
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        let hitTestResult: [SCNHitTestResult] = hitTest(CGPoint(x: point.x, y: point.y))
        guard let firstResult = hitTestResult.first else { return }
        if let block = firstResult.node as? Block {
            pool.touch(block)
        }
        if let platform = firstResult.node as? ColumnBaseNode {
            pool.touch(platform)
        }
    }
    
    func resetPool() {
        pool.playerSteps.removeAll()
        pool.selectedBlock = nil
        for node in puzzleScene.rootNode.childNodes {
            node.removeFromParentNode()
        }
        for column in pool.pool {
            addBlockColumn(column)
        }
    }
}
