//
//  PMAlertAction.swift
//  PMAlertController
//
//  Created by Paolo Musolino on 07/05/16.
//  Copyright © 2016 Codeido. All rights reserved.
//

import UIKit

@objc public enum PMAlertActionStyle : Int {
    
    case `default`
    case cancel
}

@objc open class PMAlertAction: UIButton {
    
    fileprivate var action: (() -> Void)?
    
    open var actionStyle : PMAlertActionStyle
    
    var separator = UIImageView()
    
    init(){
        self.actionStyle = .cancel
        super.init(frame: CGRect.zero)
    }
    
    @objc public convenience init(title: String?, style: PMAlertActionStyle, action: (() -> Void)? = nil){
        self.init()
        self.backgroundColor = UIColor.clear
        self.action = action
        self.addTarget(self, action: #selector(PMAlertAction.tapped(_:)), for: .touchUpInside)
        
        
        self.setAttributedTitle(NSAttributedString(
            string: title!,
            attributes: [
                NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 23)!,
                NSForegroundColorAttributeName: UIColor(red:0.09, green:0.59, blue:0.48, alpha:1.00), // Dark Mint
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.6,
                ]), for: .normal)
        
        self.setAttributedTitle(NSAttributedString(
            string: title!,
            attributes: [
                NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 23)!,
                NSForegroundColorAttributeName: UIColor(red:0.24, green:0.24, blue:0.24, alpha:1.00), // Baltic sear
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.6,
                ]), for: .highlighted)
        
        self.setBackgroundColor(color: UIColor.lightGray.withAlphaComponent(0.2), forState: .highlighted)
        
        
        self.titleLabel?.backgroundColor = UIColor.clear
        
        self.actionStyle = style
        // Button color
//        style == .default ? (self.setTitleColor(UIColor(red:0.09, green:0.10, blue:0.12, alpha:1.00), for: UIControlState())) : (self.setTitleColor(UIColor.gray, for: UIControlState()))
        
        self.addSeparator()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func tapped(_ sender: PMAlertAction) {
        self.action?()
    }
    
    @objc fileprivate func addSeparator(){
        separator.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        self.addSubview(separator)
        
        // Autolayout separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        separator.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor, constant: 8).isActive = true
        separator.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor, constant: -8).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
}

extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(colorImage, for: forState)
    }}
