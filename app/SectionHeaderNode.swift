//
//  SectionHeaderNode.swift
//  app
//
//  Created by Mats Becker on 10/13/16.
//  Copyright © 2016 safari.digital. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class SectionHeaderNode: ASDisplayNode {
    
    
    let _headerText: String
    let _headerLabel = ASTextNode()
    
    init(headerText: String) {
        self._headerText = headerText
        super.init()
        
        let spacing:CGFloat = 0.6
        
        self._headerLabel.attributedString = NSAttributedString(
            string: self._headerText,
            attributes: [
                NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 24)!,
                NSForegroundColorAttributeName: UIColor.flatBlack(),
                NSKernAttributeName: spacing,
                ])
        
        self.addSubnode(self._headerLabel)

    }
    
    override func didLoad() {
        
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
       
        self._headerLabel.style.flexShrink   = 1
        
        let centerLayoutSpec = ASCenterLayoutSpec(centeringOptions: .Y, sizingOptions: .minimumY, child: self._headerLabel)
        centerLayoutSpec.style.flexGrow = 1
        centerLayoutSpec.style.flexShrink = 1
        centerLayoutSpec.style.alignSelf = .stretch
        
        let insetLaoyutSpec = ASInsetLayoutSpec(insets: airBnbInset, child: centerLayoutSpec)
        
        return insetLaoyutSpec
    }
    

}
