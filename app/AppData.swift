//
//  AppData.swift
//  Sample
//
//  Created by Mats Becker on 10/3/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

import UIKit
import FirebaseDatabase

struct Section{
  let name: String
  let path: String
  
  init(name: String, path: String) {
    self.name = name
    self.path = path
  }
}

struct SectionData {
  let key:  String
  let ref:  FIRDatabaseReference
  let name: String
  let url:  String?
  
  init(snapshot: FIRDataSnapshot) {
    self.key          = snapshot.key
    self.ref          = snapshot.ref
    
    let snapshotValue = snapshot.value as! [String: AnyObject]
    self.name         = snapshotValue["name"] as! String
    self.url          = snapshotValue["url"] as? String
  }
  
}
