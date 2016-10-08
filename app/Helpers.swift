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
