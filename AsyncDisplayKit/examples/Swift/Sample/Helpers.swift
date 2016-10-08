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
