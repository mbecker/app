//
//  Helpers.swift
//  Sample
//
//  Created by Mats Becker on 10/4/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

import UIKit

public func listFonts(){
  for name in UIFont.familyNames {
    print(name)
    if let nameString = name as? String
    {
      print(UIFont.fontNames(forFamilyName: nameString))
    }
  }
}

public func setCharacterSpacig(string:String) -> NSMutableAttributedString {
    
    let attributedStr = NSMutableAttributedString(string: string)
    attributedStr.addAttribute(NSKernAttributeName, value: 1.25, range: NSMakeRange(0, attributedStr.length))
    return attributedStr
}

extension Int
{
    static func random(range: Range<Int> ) -> Int
    {
        var offset = 0
        
        if range.lowerBound < 0   // allow negative ranges
        {
            offset = Swift.abs(range.lowerBound)
        }
        
        let mini = UInt32(range.lowerBound + offset)
        let maxi = UInt32(range.upperBound   + offset)
        
        return Int(mini + arc4random_uniform(maxi - mini)) - offset
    }
}

extension String {
    
    func range(from: Int, to: Int) -> String {
        let offset = to - self.characters.count
        let start = self.index(self.startIndex, offsetBy: from)
        let end = self.index(self.endIndex, offsetBy: offset)
        let range = start..<end
        return self[range]
    }
}

extension NSAttributedString {
    class func attributedStringForTitleText(text: String) -> NSAttributedString {
        let titleAttributes =
            [NSFontAttributeName: UIFont(name: "AvenirNext-Heavy", size: 24)!,
             NSForegroundColorAttributeName: UIColor.black,
             NSParagraphStyleAttributeName: NSParagraphStyle.justifiedParagraphStyle()]
        return NSAttributedString(string: text, attributes: titleAttributes)
    }
    
    class func attributedStringForSubtitleText(text: String) -> NSAttributedString {
        let titleAttributes =
            [NSFontAttributeName: UIFont(name: "AvenirNext-DemiBold", size: 18)!,
             NSForegroundColorAttributeName: UIColor.black,
             NSShadowAttributeName: NSShadow.descriptionTextShadow(),
             NSParagraphStyleAttributeName: NSParagraphStyle.justifiedParagraphStyle()]
        return NSAttributedString(string: text, attributes: titleAttributes)
    }
    
    class func attributedStringForDescriptionText(text: String) -> NSAttributedString {
        let descriptionAttributes =
            [NSFontAttributeName: UIFont(name: "AvenirNext-Medium", size: 14)!,
             NSForegroundColorAttributeName: UIColor.black,
             NSForegroundColorAttributeName: UIColor.white,
             NSBackgroundColorAttributeName: UIColor.clear,
             NSParagraphStyleAttributeName: NSParagraphStyle.justifiedParagraphStyle()]
        return NSAttributedString(string: text, attributes: descriptionAttributes)
    }
}

extension NSParagraphStyle {
    class func justifiedParagraphStyle() -> NSParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .justified
        return paragraphStyle.copy() as! NSParagraphStyle
    }
}
extension NSShadow {
    class func titleTextShadow() -> NSShadow {
        let shadow = NSShadow()
        shadow.shadowColor = UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 0.3)
        shadow.shadowOffset = CGSize(width: 0, height: 2)
        shadow.shadowBlurRadius = 3.0
        return shadow
    }
    
    class func descriptionTextShadow() -> NSShadow {
        let shadow = NSShadow()
        shadow.shadowColor = UIColor(white: 0.0, alpha: 0.3)
        shadow.shadowOffset = CGSize(width: 0, height: 1)
        shadow.shadowBlurRadius = 3.0
        return shadow
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
