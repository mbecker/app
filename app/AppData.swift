//
//  AppData.swift
//  Sample
//
//  Created by Mats Becker on 10/3/16.
//  Copyright © 2016 Facebook. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

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
    let images: [String: String]?
    var imagesRef = [String: URL]()
    let storage:            FIRStorage
    
    init(snapshot: FIRDataSnapshot) {
        self.storage      = FIRStorage.storage()
        self.key          = snapshot.key
        self.ref          = snapshot.ref
        
        let snapshotValue = snapshot.value as! [String: AnyObject]
        self.name         = snapshotValue["name"] as! String
        self.url          = snapshotValue["url"] as? String
        self.images         = snapshotValue["images"] as? [String: String]
        
        /*
         image375x300
         image337x218
         */
    }   
        
}

