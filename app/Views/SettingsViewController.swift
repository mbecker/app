//
//  SettingsViewController.swift
//  app
//
//  Created by Mats Becker on 10/31/16.
//  Copyright © 2016 safari.digital. All rights reserved.
//

import UIKit
import Kingfisher
import ChameleonFramework

class SettingsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let buttonAddData = UIButton(frame: CGRect(x: 25, y: 150, width: 150, height: 50))
        buttonAddData.setBackgroundColor(color: UIColor.flatBlue(), forState: .normal)
        buttonAddData.setBackgroundColor(color: UIColor.flatBlueColorDark(), forState: .highlighted)
        buttonAddData.setTitle("Add / Delete", for: .normal)
        buttonAddData.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)
        self.view.addSubview(buttonAddData)
        
        let buttonClearCache = UIButton(frame: CGRect(x: self.view.bounds.width - 25 - 150, y: 150, width: 150, height: 50))
        buttonClearCache.setBackgroundColor(color: UIColor.flatRed(), forState: .normal)
        buttonClearCache.setBackgroundColor(color: UIColor.flatRedColorDark(), forState: .highlighted)
        buttonClearCache.setTitle("Clear Cache", for: .normal)
        buttonClearCache.addTarget(self, action: #selector(didTapClearCache), for: .touchUpInside)
        self.view.addSubview(buttonClearCache)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Action Handling
    
    @objc fileprivate func didTapAdd() {
        
        let db = DatabaseModels()
        
        let alert = UIAlertController(title: "Firebase", message: "Add or delete items?", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { action in
            db.deleteBatch()
        }))
        
        alert.addAction(UIAlertAction(title: "Add", style: UIAlertActionStyle.default, handler: { action in
            db.insertBatch()
        }))
        
        alert.addAction(UIAlertAction(title: "Add 10", style: UIAlertActionStyle.default, handler: { action in
            db.insertBatch(count: 10)
        }))
        
        alert.addAction(UIAlertAction(title: "Add 50", style: UIAlertActionStyle.default, handler: { action in
            db.insertBatch(count: 50)
        }))
        
        alert.addAction(UIAlertAction(title: "Add Zebra", style: UIAlertActionStyle.default, handler: { action in
            db.addAnimal(animal: "Zebra")
        }))
        
        alert.addAction(UIAlertAction(title: "Add Giraffe", style: UIAlertActionStyle.default, handler: { action in
            db.addAnimal(animal: "Giraffe")
        }))
        
        alert.addAction(UIAlertAction(title: "Add Turtle", style: UIAlertActionStyle.default, handler: { action in
            db.addAnimal(animal: "Turtle")
        }))
        
        alert.addAction(UIAlertAction(title: "Add Elephant", style: UIAlertActionStyle.default, handler: { action in
            db.addAnimal(animal: "Elephant")
        }))
        
        alert.addAction(UIAlertAction(title: "Add Bison", style: UIAlertActionStyle.default, handler: { action in
            db.addAnimal(animal: "Bison")
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc fileprivate func didTapClearCache() {
        ImageCache.default.calculateDiskCacheSize { size in
            let alert = UIAlertController(title: "Cache", message: "Used disk size: \(size / 1024 / 1024) MB", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Clear cache", style: UIAlertActionStyle.destructive, handler: { action in
                // Clear memory cache right away.
                ImageCache.default.clearMemoryCache()
                
                // Clear disk cache. This is an async operation.
                ImageCache.default.clearDiskCache()
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
        }
    }

    
    
}
