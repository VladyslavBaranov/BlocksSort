//
//  BoxSortPuzzleViewController.swift
//  BlockSort
//
//  Created by Vladyslav Baranov on 10.04.2022.
//

import UIKit
import SceneKit
import StoreKit

final class BoxSortPuzzleViewController: UIViewController, SKProductsRequestDelegate {
    
    var request: SKProductsRequest!

    func validate() {
        let productIdentifiers = Set(["com.blockssort.noads"])
        request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
    }

    var products = [SKProduct]()
    // Create the SKProductsRequestDelegate protocol method
    // to receive the array of products.
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print(response.products)
        if !response.products.isEmpty {
           products = response.products
            for product in products {
                print(product.price, product.productIdentifier, product.subscriptionPeriod)
            }
        }

        for invalidIdentifier in response.invalidProductIdentifiers {
           print(invalidIdentifier)
        }
    }
    
    private var stepBackButton: UIButton!
    private var reloadButton: UIButton!
    private var levelLabel: UILabel!
    private var puzzleSceneView: BoxSortPuzzleView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        puzzleSceneView = BoxSortPuzzleView(frame: view.frame)
        puzzleSceneView.allowsCameraControl = true
        puzzleSceneView.autoenablesDefaultLighting = true
        puzzleSceneView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(puzzleSceneView)
        
        let anim = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        anim.toValue = 1
        anim.fromValue = 0
        anim.duration = 2
        anim.fillMode = .forwards
        anim.isRemovedOnCompletion = false
        puzzleSceneView.layer.add(anim, forKey: nil)
        
        NSLayoutConstraint.activate([
            puzzleSceneView.topAnchor.constraint(equalTo: view.topAnchor),
            puzzleSceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            puzzleSceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            puzzleSceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        setupUIControls()
        // validate()
    }
    
    func setupUIControls() {
        stepBackButton = UIButton()
        stepBackButton.setImage(UIImage(systemName: "arrowshape.turn.up.left.fill"), for: .normal)
        stepBackButton.setPreferredSymbolConfiguration(.init(pointSize: 40), forImageIn: .normal)
        stepBackButton.tintColor = .white
        stepBackButton.translatesAutoresizingMaskIntoConstraints = false
        stepBackButton.addTarget(self, action: #selector(stepBack), for: .touchUpInside)
        view.addSubview(stepBackButton)
        NSLayoutConstraint.activate([
            stepBackButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stepBackButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10)
        ])
        
        reloadButton = UIButton()
        reloadButton.setImage(UIImage(systemName: "arrow.counterclockwise"), for: .normal)
        reloadButton.setPreferredSymbolConfiguration(.init(pointSize: 40), forImageIn: .normal)
        reloadButton.tintColor = .white
        reloadButton.translatesAutoresizingMaskIntoConstraints = false
        reloadButton.addTarget(self, action: #selector(reload), for: .touchUpInside)
        view.addSubview(reloadButton)
        NSLayoutConstraint.activate([
            reloadButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            reloadButton.leadingAnchor.constraint(equalTo: stepBackButton.trailingAnchor, constant: 10)
        ])
        
        levelLabel = UILabel()
        levelLabel.text = "Level 1"
        levelLabel.font = UIFont(name: "ChalkboardSE-Regular", size: 30)
        levelLabel.textColor = .white
        levelLabel.textAlignment = .center
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(levelLabel)
        
        NSLayoutConstraint.activate([
            levelLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            levelLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
        
    }
    
    @objc func stepBack() {
        puzzleSceneView.pool.undoLast()
    }
    
    @objc func reload() {
        puzzleSceneView.pool = BlockColumnPool.createPool()
        puzzleSceneView.resetPool()
    }
}
