//
//  TabBarController.swift
//  app
//
//  Created by Mats Becker on 10/24/16.
//  Copyright © 2016 safari.digital. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import PMAlertController

class TabBarController: UITabBarController {
    
    let appNavigationController = ARNImageTransitionNavigationController(rootViewController: ViewController())
    let cameraDummyView = UIViewController()
    let settingsViewController = SettingsViewController()
    let progressView = UIProgressView()
    
    struct Dimensions {
        static let borderWidth: CGFloat = 2
        static let buttonSize: CGFloat = 58
        static let buttonBorderSize: CGFloat = 68
    }
    
    // MARK: Firebase init
    var ref: FIRDatabaseReference!
    var refs: [FIRDatabaseReference] = [FIRDatabaseReference]()
    var _storage = FIRStorage.storage()
    var _storageRef: FIRStorageReference
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.ref = FIRDatabase.database().reference()
        self._storageRef = self._storage.reference()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        //        fatalError("init(coder:) has not been implemented")
        self.ref = FIRDatabase.database().reference()
        self._storageRef = self._storage.reference()
        super.init(coder: aDecoder)!
    }
    
    init() {
        self.ref = FIRDatabase.database().reference()
        self._storageRef = self._storage.reference()
        super.init(nibName: nil, bundle: nil)
        
        self.delegate = self
        
        // Add UIViewControlles to TabBar
        
        appNavigationController.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "picnicTable"), selectedImage: UIImage(named: "picnicTable"))
        appNavigationController.tabBarItem.imageInsets = UIEdgeInsets(top:6,left:0,bottom:-6,right:0)
        cameraDummyView.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "camera"), selectedImage: UIImage(named: "Camera-66"))
        cameraDummyView.tabBarItem.imageInsets = UIEdgeInsets(top:6,left:0,bottom:-6,right:0)
        settingsViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .more, tag: 1)
        
        
        self.setViewControllers([appNavigationController, cameraDummyView, settingsViewController], animated: false)
        
        
        // Set TabBar style
        self.tabBar.unselectedItemTintColor = UIColor.flatBlack()
        self.tabBar.tintColor = UIColor.flatMintColorDark()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set TabBar stlye
        self.tabBar.backgroundImage = UIImage.colorForNavBar(color: UIColor.white)        
        
        self.progressView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20)
        self.progressView.progressViewStyle = .default
        self.progressView.progressTintColor = UIColor.flatRed()
        self.progressView.trackTintColor = UIColor.flatWhite()
        self.progressView.progress = 0.0
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    /**
     * FIREBASE
     */
    func processImages(originalImages: [UIImage], resizedImages: [UIImage], types: [whatTypes], names: [String?], items: [Int : [String]], positions: [CLLocationCoordinate2D]){
        
        var itemName = String()
        if names[0] == nil {
            itemName = (items[0]?.joined(separator: ", "))!
        } else {
            itemName = names[0]!
        }
        
        var itemTags = [String]()
        for item in items[0]! {
            itemTags.insert(item, at: 0)
        }
        
        var itemType = String()
        switch types[0] {
        case .Animal:
            itemType = "animals"
        case .Attraction:
            itemType = "attractions"
        default:
            itemType = "public"
        }
        
        let lat = Double(positions[0].latitude)
        let long = Double(positions[0].longitude)
        
        self.tabBar.addSubview(self.progressView)
        
        // Upload image
        let imageData = UIImageJPEGRepresentation(originalImages[0], 1.0)                                                               // Get data
        let imageResizedData = UIImageJPEGRepresentation(resizedImages[0].resizedImageWithinRect(rectSize: CGSize(width: 375, height: 300)), 0.6) // Get data from resized image
        
        let key = ref.child("park/addo/\(itemType)").childByAutoId().key
        
        
        let imageOriginalRef = self._storageRef.child("\(itemType)/\(key).jpg")                                                       // Get storage reference for new uploaded image with given imagename
        let imageResizedRef = self._storageRef.child("\(itemType)/\(key)_375x300.jpg")                                        // Get storage reference for new uploaded image with given imagename
        
        var imageOriginalURL: String = String()
        let metadataForImages = FIRStorageMetadata()
        metadataForImages.contentType = "image/jpeg"
        
        let imageOriginalUploadTask = imageOriginalRef.put(imageData!, metadata: metadataForImages)
        
        imageOriginalUploadTask.observe(.progress) { snapshot in
            // Upload reported progress
            if let progress = snapshot.progress {
                let percentComplete: Float = 60 * Float(progress.completedUnitCount) / Float(progress.totalUnitCount)
                print(":: Upload image 1 - \(percentComplete)")
                self.progressView.setProgress(percentComplete / 100, animated: true);
                
            }
        }
        imageOriginalUploadTask.observe(.success) { snapshot in
            imageOriginalURL = (snapshot.metadata?.downloadURL()!.absoluteString)!
            
            let imageResizedUploadTask = imageResizedRef.put(imageResizedData!, metadata: metadataForImages)
            imageResizedUploadTask.observe(.progress) { snapshot in
                // Upload reported progress
                if let progress = snapshot.progress {
                    let percentComplete: Float = 30 * Float(progress.completedUnitCount) / Float(progress.totalUnitCount)
                    print(":: Upload image  2 - \(percentComplete)")
                    self.progressView.setProgress(0.6 + percentComplete / 100, animated: true);
                    
                }
            }
            imageResizedUploadTask.observe(.success) { snapshot in
                // Upload completed successfully -> Save in database
                
                let resizedImageURL = (snapshot.metadata?.downloadURL()?.absoluteString)!
                
                let post = ["name": itemName,
                            "url":  resizedImageURL,
                            "images": [
                                "image375x300": resizedImageURL,
                                "original": imageOriginalURL,
                            ],
                            "tags": itemTags,
                            "location": [
                                "latitude": lat,
                                "longitude": long
                            ],
                            "timestamp": FIRServerValue.timestamp()
                    ] as [String : Any]
                let childUpdates = ["/park/addo/\(itemType)/\(key)": post]
                self.ref.updateChildValues(childUpdates)
                
                self.ref.updateChildValues(childUpdates, withCompletionBlock: { (error, reference) in
                    if error != nil {
                        print(":: ERROR SAVING TO FIREBASE")
                        print(error)
                        let alertVC = PMAlertController(title: "ERROR UPLOADING IMAGES", description: (error?.localizedDescription)!, image: nil, style: .alert)
                        
                        alertVC.addAction(PMAlertAction(title: "OK", style: .default, action: { () -> Void in
                            
                        }))
                        self.present(alertVC, animated: true, completion: nil)
                    } else {
                        let alertVC = PMAlertController(title: "Image uploaded", description: "Image was successfully uploaded", image: resizedImages[0], style: .alert)
                        
                        alertVC.addAction(PMAlertAction(title: "Done", style: .default, action: { () -> Void in
                            
                        }))
                        self.present(alertVC, animated: true, completion: nil)
                    }
                })
                
                self.progressView.setProgress(1, animated: true)
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (timer) in
                    self.progressView.removeFromSuperview()
                    self.progressView.setProgress(0.00, animated: false)
                })
            }
        }
    }


}

extension TabBarController : UITabBarControllerDelegate {
    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController == self.cameraDummyView {
            let imagePicker = ImagePickerController()
            imagePicker.delegate = self
            Configuration.recordLocation = true
            Configuration.imageLimit = 1
            imagePicker.imageLimit = 1
            
            let imageNavcontroller = UINavigationController(rootViewController: imagePicker)
            self.show(imageNavcontroller, sender: nil)
            return false
        }
        return true
    }
}

extension TabBarController : ImagePickerDelegate {
    
    public func doneButtonDidPress(_ imagePicker: ImagePickerController, originalImages: [UIImage], resizedImages: [UIImage], types: [whatTypes], names: [String?], items: [Int : [String]], positions: [CLLocationCoordinate2D]) {
        
        self.dismiss(animated: true) {
            self.processImages(originalImages: originalImages, resizedImages: resizedImages, types: types, names: names, items: items, positions: positions)
        }        
        
    }
    
    
    public func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        self.tabBarController?.dismiss(animated: true, completion: nil)
    }
    
    public func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        //
    }
}
