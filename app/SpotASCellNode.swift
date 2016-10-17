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
    
    var cellData:           SectionData
    var cellSize:           CGSize
    var imageSize:          CGSize
    var storage:            FIRStorage
    var _image:             ASNetworkImageNode
    var _profileImage:      ASNetworkImageNode
    var _loadingIndicator:  ASDisplayNode
    var _title:             ASTextNode
    var _desc:              ASTextNode
    var _errorText:         ASTextNode
    
    
    init(cellData: SectionData, cellSize: CGSize) {
        self.cellData                   = cellData
        self.cellSize                   = cellSize
        self.imageSize                  = CGSize(width: cellSize.width, height: cellSize.height - airBnbImageFooterHeight)
        self.storage                    = FIRStorage.storage()
        let cache                       = KingfisherCache.sharedManager
        self._profileImage              = ASNetworkImageNode(cache: cache, downloader: cache)
        let profileImageDefaultName     = "lego" + String(arc4random_uniform(9) + 1)
        self._profileImage.defaultImage = UIImage(named: profileImageDefaultName)
        self._image                     = ASNetworkImageNode(cache: cache, downloader: cache)
        self._image.placeholderEnabled  = true
        self._image.defaultImage        = UIImage(named: "imagebackgrounddefault")
        self._image.contentMode         = .scaleAspectFill
        
        self._loadingIndicator          = SpinnerNode()
        
        self._title                     = ASTextNode()
        self._desc                      = ASTextNode()
        self._errorText                 = ASTextNode()
        
        super.init()
        
        self._image.delegate = self
        
        let spacing:CGFloat = 0.6
        
        _title.attributedString = NSAttributedString(
            string: self.cellData.name,
            attributes: [
                NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 19)!,
                NSForegroundColorAttributeName: UIColor(red:0.28, green:0.28, blue:0.28, alpha:1.00),
                NSKernAttributeName: spacing,
                ])
        _desc.attributedString = NSAttributedString(
            string: "2mins ago · 5km away",
            attributes: [
                NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 12)!,
                NSForegroundColorAttributeName: UIColor(red:0.19, green:0.26, blue:0.35, alpha:1.00),
                NSKernAttributeName: spacing
            ])
        
        self.addSubnode(_title)
        self.addSubnode(_desc)
        self.addSubnode(self._profileImage)
        self.addSubnode(self._image)
        self.addSubnode(self._errorText)
        self.addSubnode(self._loadingIndicator)
        loadImage()
    }
    
    override func didLoad() {
        
        // Material Design: Card (Shadow)
        //    self.view.layer.cornerRadius = 2
        //    let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 2)
        //    self.view.layer.masksToBounds = false
        //    self.view.layer.shadowColor = UIColor.black.cgColor
        //    self.view.layer.shadowOffset = CGSize(width: 0, height: 3)
        //    self.view.layer.shadowOpacity = 0.5
        //    self.view.layer.shadowPath = shadowPath.cgPath
        
        
        self._profileImage.view.layer.masksToBounds = false
        self._profileImage.view.layer.cornerRadius = 48 / 2
        self._profileImage.clipsToBounds = true
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        self._image.style.width   = ASDimension(unit: .points, value: self.imageSize.width)
        self._image.style.height  = ASDimension(unit: .points, value: self.imageSize.height)
        
        self._profileImage.style.width  = ASDimension(unit: .points, value: 48)
        self._profileImage.style.height = ASDimension(unit: .points, value: 48)
        
        self._title.style.flexShrink   = 1
        self._desc.style.flexShrink    = 1
        
        let verticalStackSpec               = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .start, alignItems: .start, children: [_title, _desc])
        verticalStackSpec.style.flexShrink  = 1
        
        let spacer              = ASLayoutSpec()
        spacer.style.flexShrink = 1
        spacer.style.flexGrow   = 1
        
        let horizontalStackSpec = ASStackLayoutSpec(direction: .horizontal, spacing: 0, justifyContent: .start, alignItems: .start, children: [verticalStackSpec, spacer, self._profileImage])
        horizontalStackSpec.style.flexShrink  = 1
        horizontalStackSpec.style.flexGrow    = 1
        horizontalStackSpec.style.alignSelf = .stretch
        
        let insets = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
        
        let footerBoxSpex = ASInsetLayoutSpec(insets: insets, child: horizontalStackSpec)
        footerBoxSpex.style.flexGrow = 1
        footerBoxSpex.style.flexShrink = 1
        footerBoxSpex.style.alignSelf = .stretch
        
        self._loadingIndicator.style.width  = ASDimension(unit: .points, value: 44)
        self._loadingIndicator.style.height = ASDimension(unit: .points, value: 44)
        
        
        let errorSpec = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 0), child: self._errorText)
        
        
        let errorImg = ASOverlayLayoutSpec(child: self._image, overlay: errorSpec)
        
        
        
        let imgOverlaySpec = ASOverlayLayoutSpec(child: errorImg, overlay: self._loadingIndicator)
        
        
        
        let layoutSpec = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .start, alignItems: .start, children: [imgOverlaySpec, footerBoxSpex])
        
        
        return layoutSpec
    }
    
    func loadImage() {
        
        self._profileImage.url = URL(string: "https://randomuser.me/api/portraits/men/72.jpg")
        
        var imgRef: FIRStorageReference
        if let imageURL: String = self.cellData.images?["image375x300"] {
            // Image 337x218 exists
            imgRef = self.storage.reference(forURL: imageURL)
            loadImageURL(imgRef: imgRef)
        } else if let imageURL: String = self.cellData.url as String!, imageURL.characters.count > 0 {
            // Load original image
            imgRef = self.storage.reference(forURL: imageURL)
            loadImageURL(imgRef: imgRef)
        } else {
            // Show error
            self._image.url = URL(string: "https://error.com")
        }
        
    }
    
    func loadImageURL(imgRef: FIRStorageReference){
        imgRef.downloadURL(completion: { (storageURL, error) -> Void in
            if error != nil {
                self._image.url = URL(string: "https://error.com")
            } else {
                self._image.url = storageURL
            }
        })
    }
    
    
}

extension SpotASCellNode: ASNetworkImageNodeDelegate {
    
    func imageNode(_ imageNode: ASNetworkImageNode, didLoad image: UIImage) {
        self._loadingIndicator.removeFromSupernode()
    }
    
    func imageNode(_ imageNode: ASNetworkImageNode, didFailWithError error: Error) {
        
        self._errorText.attributedString = NSAttributedString(
            string: error.localizedDescription,
            attributes: [
                NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 18)!,
                NSForegroundColorAttributeName: UIColor(red:0.28, green:0.28, blue:0.28, alpha:1.00)
            ])
        
        self._loadingIndicator.removeFromSupernode()
    }
    
}

final class SpinnerNode: ASDisplayNode {
    var activityIndicatorView: UIActivityIndicatorView {
        return view as! UIActivityIndicatorView
    }
    
    override init() {
        super.init(viewBlock: { UIActivityIndicatorView(activityIndicatorStyle: .gray) }, didLoad: nil)
        
        self.style.minHeight = ASDimensionMakeWithPoints(44.0)
    }
    
    override func didLoad() {
        super.didLoad()
        activityIndicatorView.backgroundColor = UIColor.clear
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.startAnimating()
    }
    
    
}
