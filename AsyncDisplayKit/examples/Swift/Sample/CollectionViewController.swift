//
//  CollectionViewController.swift
//  Sample
//
//  Created by Mats Becker on 10/2/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class CollectionViewController: ASViewController<ASDisplayNode>, ASCollectionDelegate, ASCollectionDataSource {
  
  let itemCount = 20
  
//  let itemSize: CGSize
//  let padding: CGFloat
  var collectionNode: ASCollectionNode {
    return node as! ASCollectionNode
  }

  init() {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.minimumInteritemSpacing = 10
    layout.minimumLineSpacing = 5
    layout.itemSize = CGSize(width: 100, height: 200)
    
    
    super.init(node: ASCollectionNode.init(frame: CGRect(x: 100, y: 100, width: 300, height: 200), collectionViewLayout: layout))
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Color", style: .plain, target: self, action: #selector(didTapColorsButton))
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Layout", style: .plain, target: self, action: #selector(didTapLayoutButton))
    collectionNode.delegate = self
    collectionNode.dataSource = self
    title = "Background Updating"
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.collectionNode.frame = CGRect(x: 100, y: 100, width: 300, height: 200)
    self.collectionNode.backgroundColor = UIColor.gray
  }
  
  
  // MARK: ASCollectionDataSource
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return itemCount
  }
  
  func collectionView(_ collectionView: ASCollectionView, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    return {
//      let node = DemoCellNode(glacierScenic: glacier)
      let node = ASTextCellNode()
      node.text = String(format: "[%ld.%ld] says hello!", (indexPath as NSIndexPath).section, (indexPath as NSIndexPath).row)
      
      return node
    }
  }
  
  func collectionView(_ collectionView: ASCollectionView, constrainedSizeForNodeAt indexPath: IndexPath) -> ASSizeRange {
    
    return ASSizeRangeMake(CGSize(width: 100, height: 200), CGSize(width: 100, height: 200))
    
  }
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 2
  }
  
  // MARK: Action Handling
  
  @objc fileprivate func didTapColorsButton() {
    let currentlyVisibleNodes = collectionNode.view.visibleNodes()
    let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
    queue.async {
      for case let node as DemoCellNode in currentlyVisibleNodes {
        node.backgroundColor = UIColor(red:0.00, green:0.62, blue:0.56, alpha:1.00)
      }
    }
  }
  
  @objc fileprivate func didTapLayoutButton() {
    let currentlyVisibleNodes = collectionNode.view.visibleNodes()
    let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
    queue.async {
      for case let node as DemoCellNode in currentlyVisibleNodes {
        
        node.setNeedsLayout()
      }
    }
  }
  
  // MARK: Static
  
//  static func computeLayoutSizesForMainScreen() -> (padding: CGFloat, itemSize: CGSize) {
//    let numberOfColumns = 4
//    let screen = UIScreen.mainScreen()
//    let scale = screen.scale
//    let screenWidth = Int(screen.bounds.width * screen.scale)
//    let itemWidthPx = (screenWidth - (numberOfColumns - 1)) / numberOfColumns
//    let leftover = screenWidth - itemWidthPx * numberOfColumns
//    let paddingPx = leftover / (numberOfColumns - 1)
//    let itemDimension = CGFloat(itemWidthPx) / scale
//    let padding = CGFloat(paddingPx) / scale
//    return (padding: padding, itemSize: CGSize(width: 200, height: 100))
//  }

}
