//
//  AppData.swift
//  Sample
//
//  Created by Mats Becker on 10/3/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

import UIKit
import Firebase
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


struct AppData {
  let key: String
  let section: Section
  let name: String
  let photoUrl: String?
  fileprivate(set) var image: UIImage?
  let ref: FIRDatabaseReference?
  
  
  init(snapshot: FIRDataSnapshot, section: Section) {
    self.key = snapshot.key
    self.section = section
    ref = snapshot.ref
    
    let snapshotValue = snapshot.value as! [String: AnyObject]
    self.name = snapshotValue["name"] as! String
    self.photoUrl = snapshotValue["photoUrl"] as? String
    
    self.image = nil
  }
  
  init?(key: String, section: Section, name: String, photoUrl: String) {
    
    self.key = key
    self.section = section
    self.name = name
    self.photoUrl = photoUrl
    self.ref = nil
    self.image = nil
  }
  
  mutating func setImage(_ image: UIImage){
    print(":: MODEL AppData :: setImage")
    self.image = image
    print(self.image)
    print(":: MODEL AppData :: setImage :: success")
  }
  
}
