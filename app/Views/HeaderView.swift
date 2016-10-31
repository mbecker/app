//
//  SectionHeaderView.swift
//  app
//
//  Created by Mats Becker on 10/31/16.
//  Copyright © 2016 safari.digital. All rights reserved.
//

import UIKit

class HeaderView: UIView {

    init(text: String) {
        super.init(frame: CGRect.zero)
        self.backgroundColor = UIColor.white
        
        let title = UILabel()
        title.attributedText = NSAttributedString(
            string: text,
            attributes: [
                NSFontAttributeName: UIFont(name: "CircularStd-Black", size: 32)!,
                NSForegroundColorAttributeName: UIColor(red:0.24, green:0.24, blue:0.24, alpha:1.00), // Baltic sea
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: -0.6,
                ])
        title.translatesAutoresizingMaskIntoConstraints = false
        
        let seperator = UIView()
        seperator.backgroundColor = UIColor(red:0.84, green:0.84, blue:0.84, alpha:1.00) // Iron
        seperator.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(title)
        self.addSubview(seperator)
        
        let constraintLeftHeader = NSLayoutConstraint(item: title, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 20)
        let constraintCenterYHeader = NSLayoutConstraint(item: title, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        
        let constraintBottomSeperator = NSLayoutConstraint(item: seperator, attribute: .top, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -1)
        let constraintLeftSeperator = NSLayoutConstraint(item: seperator, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 20)
        let constraintWidthSeperator = NSLayoutConstraint(item: seperator, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 80)
        let constraintHeightSeperator = NSLayoutConstraint(item: seperator, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 1)
        
        self.addConstraint(constraintLeftHeader)
        self.addConstraint(constraintCenterYHeader)
        
        self.addConstraint(constraintLeftSeperator)
        self.addConstraint(constraintBottomSeperator)
        self.addConstraint(constraintWidthSeperator)
        self.addConstraint(constraintHeightSeperator)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
