//
//  ViewController.swift
//  Home Decor
//
//  Created by Ranadhir Dey on 14/06/18.
//  Copyright © 2018 ARFactory. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    let config = ARWorldTrackingConfiguration()
    
    let floorImageArray = ["Wood1","Wood2","Wood3","Wood4", "Wood5", "Wood6", "Tile1", "Tile2", "Tile3", "Tile4"]
    lazy var imageName = floorImageArray[0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        config.planeDetection = .horizontal
        sceneView.session.run(config)

        sceneView.delegate = self
        
        
        //        let capsuleNode = SCNNode(geometry: SCNCapsule(capRadius: 0.03, height: 0.1))
        //        capsuleNode.position = SCNVector3(0.1, 0.1, -0.1)
        //
        //        capsuleNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue //1
        //        capsuleNode.eulerAngles = SCNVector3(0,0,Double.pi/2)//2
        //
        //        sceneView.scene.rootNode.addChildNode(capsuleNode)

    }
    
    fileprivate func createFloorNode(anchor:ARPlaneAnchor) ->SCNNode{
        let floorNode = SCNNode(geometry: SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))) //1
        floorNode.position=SCNVector3(anchor.center.x,0,anchor.center.z)                                               //2
        floorNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: imageName)                                //3
        floorNode.geometry?.firstMaterial?.isDoubleSided = true                                                        //4
        floorNode.eulerAngles = SCNVector3(Double.pi/2,0,0)                                                             //5
        return floorNode                                                                                               //6
    }
    
    

}


extension ViewController:ARSCNViewDelegate{
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        let planeNode = createFloorNode(anchor: planeAnchor)
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        node.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        let planeNode = createFloorNode(anchor: planeAnchor)
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let _ = anchor as? ARPlaneAnchor else {return}
        node.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
    }
}

extension ViewController:UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return floorImageArray.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        if let imgVw = cell.viewWithTag(1) as? UIImageView{
            imgVw.image = UIImage(named: floorImageArray[indexPath.row])
            resizeImageInCell(cell, isSelected: imageName == floorImageArray[indexPath.row])
        }
        
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = self.collectionView.cellForItem(at: indexPath)
        
        resizeImageInCell(cell!, isSelected: true)
        
        
        imageName = floorImageArray[indexPath.row]
        collectionView.reloadData()
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = self.collectionView.cellForItem(at: indexPath)
        
        resizeImageInCell(cell!, isSelected: false)
    }
    
    func resizeImageInCell(_ cell:UICollectionViewCell, isSelected:Bool){
        
        cell.layer.cornerRadius = isSelected ? 35 : 20
        cell.layer.masksToBounds = true
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return imageName == floorImageArray[indexPath.row] ? CGSize(width: 70, height: 70) : CGSize(width: 40, height: 40)
    }
    
}
