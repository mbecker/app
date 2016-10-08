//
//  SpotASCellNode.swift
//  Sample
//
//  Created by Mats Becker on 10/4/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import FirebaseStorage

final class SpotASCellNode: ASCellNode {
  
  var cellData:       SectionData
  var cellSize:       CGSize
  var imageSize:      CGSize
  var storage:        FIRStorage
  var _image:         ASNetworkImageNode
  var _profileImage:  ASNetworkImageNode
  var _title:         ASTextNode
  var _desc:          ASTextNode
  
  
  init(cellData: SectionData, cellSize: CGSize) {
    self.cellData       = cellData
    self.cellSize       = cellSize
    self.imageSize      = CGSize(width: cellSize.width, height: cellSize.height - 40)
    self.storage        = FIRStorage.storage()
    let cache           = KingfisherCache.sharedManager
    self._profileImage  = ASNetworkImageNode(cache: cache, downloader: cache)
    self._image         = ASNetworkImageNode(cache: cache, downloader: cache)
    self._title         = ASTextNode()
    self._desc          = ASTextNode()
    super.init()
    
    self.addSubnode(_title)
    let font = UIFont(name: "Calibre-Medium", size: 16)!
    _title.attributedString = NSAttributedString(
      string: self.cellData.name,
      attributes: [
        NSFontAttributeName: font,
        NSForegroundColorAttributeName: UIColor(red:1.00, green:0.31, blue:0.33, alpha:1.00),
        NSKernAttributeName: -0.3
      ])
    
    self.addSubnode(_desc)
    _desc.attributedString = NSAttributedString(
      string: "2mins ago · 5km away",
      attributes: [
        NSFontAttributeName: UIFont(name: "Calibre", size: 12)!,
        NSForegroundColorAttributeName: UIColor(red:0.19, green:0.26, blue:0.35, alpha:1.00),
        NSKernAttributeName: -0.3
      ])
    
    self.addSubnode(_image)
    self.addSubnode(_profileImage)
    
    loadImage()
  }
  
  override func didLoad() {
//    self.view.layer.borderWidth = 1
//    self.view.layer.borderColor = UIColor(red:0.73, green:0.73, blue:0.73, alpha:1.00).cgColor
    
    self.view.layer.cornerRadius = 2
    let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 2)
    
    self.view.layer.masksToBounds = false
    self.view.layer.shadowColor = UIColor.black.cgColor
    self.view.layer.shadowOffset = CGSize(width: 0, height: 3)
    self.view.layer.shadowOpacity = 0.5
    self.view.layer.shadowPath = shadowPath.cgPath
    
    self._profileImage.view.layer.masksToBounds = false
    self._profileImage.view.layer.cornerRadius = 32 / 2
    self._profileImage.clipsToBounds = true
    
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    
    self._image.style.width   = ASDimension(unit: .points, value: self.imageSize.width)
    self._image.style.height  = ASDimension(unit: .points, value: self.imageSize.height)
    
    self._profileImage.style.width  = ASDimension(unit: .points, value: 32)
    self._profileImage.style.height = ASDimension(unit: .points, value: 32)
    
    self._title.style.flexShrink   = 1
    self._desc.style.flexShrink    = 1
    
    let verticalStackSpec               = ASStackLayoutSpec(direction: .vertical, spacing: 2, justifyContent: .start, alignItems: .start, children: [_title, _desc])
    verticalStackSpec.style.flexShrink  = 1
    
    let spacer              = ASLayoutSpec()
    spacer.style.flexShrink = 1
    spacer.style.flexGrow   = 1
    spacer.setChild(self._desc, at: 0)
    
    let imageSpec = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .end, alignItems: .end, children: [self._profileImage])
    imageSpec.style.flexGrow    = 1
    imageSpec.style.flexShrink  = 1
    
    let imgSpec = ASStackLayoutSpec()
    imgSpec.style.flexShrink = 1
    imgSpec.alignItems = .end
    imgSpec.justifyContent = .end
    imgSpec.setChild(self._profileImage, at: 0)
    
    let horizontalStackSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 0, justifyContent: .center, alignItems: .center, children: [verticalStackSpec, spacer, self._profileImage])
    horizontalStackSpec.style.flexShrink  = 1
    horizontalStackSpec.style.flexGrow    = 1
    horizontalStackSpec.style.alignSelf = .stretch
    
    
    
    let insets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    let textBoxSpex = ASInsetLayoutSpec(insets: insets, child: horizontalStackSpec)
    textBoxSpex.style.flexGrow = 1
    textBoxSpex.style.flexShrink = 1
    textBoxSpex.style.alignSelf = .stretch
    
    let layoutSpec = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .start, alignItems: .start, children: [_image, textBoxSpex])
    
    
    return layoutSpec
  }
  
  func loadImage() {
    
    self._profileImage.url = URL(string: "https://randomuser.me/api/portraits/men/72.jpg")
    
    if let imageURL: String = self.cellData.url as String!, imageURL.characters.count > 0 {
      let imgRef = self.storage.reference(forURL: imageURL)
      
      imgRef.downloadURL(completion: { (storageURL, error) -> Void in
        if error != nil {
          self._image.url = URL(string: "https://dummyimage.com/345x261/000/fff.png&text=FirebaseError")
        } else {
          self._image.url = storageURL
        }
      })
    } else {
      self._image.url = URL(string: "https://dummyimage.com/345x261/000/fff.png&text=NoImage")
    }

  }
  
  

}
