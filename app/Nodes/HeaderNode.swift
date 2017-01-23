//
//  HeaderNode.swift
//  app
//
//  Created by Mats Becker on 10/31/16.
//  Copyright © 2016 safari.digital. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class HeaderNode: ASDisplayNode {
    // 1
    let titleTextNode: ASTextNode
    let seperatorViewNode: ASDisplayNode
    
    // 2
    init(title: String) {
        titleTextNode = ASTextNode()
        self.seperatorViewNode = ASDisplayNode()
        super.init()
        setUpSubnodesWithTitle(title: title)
        buildSubnodeHierarchy()
    }
    
    // 3
    func setUpSubnodesWithTitle(title: String) {
        // Set up title text node
        self.titleTextNode.attributedString = NSAttributedString.attributedStringForTitleText(text: title)
        self.seperatorViewNode.backgroundColor = UIColor(red:0.84, green:0.84, blue:0.84, alpha:1.00) // Iron
    }
    
    // 4
    func buildSubnodeHierarchy() {
        addSubnode(titleTextNode)
        addSubnode(seperatorViewNode)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        self.seperatorViewNode.style.height = ASDimension(unit: .points, value: 1)
        self.seperatorViewNode.style.height = ASDimension(unit: .points, value: 80)
        
        self.titleTextNode.style.flexShrink = 1
        self.titleTextNode.style.flexGrow   = 1
        
        let verticalStackSpec               = ASStackLayoutSpec(direction: .vertical, spacing: 0, justifyContent: .center, alignItems: .start, children: [self.titleTextNode, self.seperatorViewNode])
        verticalStackSpec.style.flexShrink  = 1
        verticalStackSpec.style.flexGrow    = 1
        
        let insets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        let headerBox = ASInsetLayoutSpec(insets: insets, child: verticalStackSpec)
        headerBox.style.flexGrow = 1
        headerBox.style.flexShrink = 1
        headerBox.style.alignSelf = .stretch
        
        return headerBox
    }
    
}
