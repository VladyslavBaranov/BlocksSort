//
//  SCNMaterial+Extension.swift
//  BlockSort
//
//  Created by Vladyslav Baranov on 10.04.2022.
//

import SceneKit

extension SCNMaterial {
    static func createGlossyMetallicMaterial(diffuseColor: UIColor?) -> SCNMaterial {
        let material = SCNMaterial()
        material.lightingModel = .physicallyBased
        material.roughness.contents = 0
        material.diffuse.contents = diffuseColor ?? UIColor.darkGray
        material.metalness.contents = 1
        material.locksAmbientWithDiffuse = true
        return material
    }
}
