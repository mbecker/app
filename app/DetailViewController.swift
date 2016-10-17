//
//  DetailViewController.swift
//  ARNZoomImageTransition
//
//  Created by xxxAIRINxxx on 2015/08/08.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit
import Kingfisher
import FirebaseStorage

class DetailViewController: UIViewController, ARNImageTransitionZoomable {
    
    
    @IBOutlet var imageView: UIImageView!
    var _image: UIImage?
    var _data: SectionData?
    var storage = FIRStorage.storage()
    
    deinit {
        print("deinit DetailViewController")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.imageView.clipsToBounds = true
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.backIndicatorImage  = UIImage(named: "chevron")
        
        self.title = self._data?.name
        self.imageView.image = self._image
        
        // ToDo: The image375x300 is already loadd in cell because of better image quality; load original image
        // Kingfisher: Load image image375x300
        if let imageURL: String = self._data?.url, (self._data?.url?.characters.count)! > 0 {
            
            let imgRef = self.storage.reference(forURL: imageURL)
            
            imgRef.downloadURL(completion: { (storageURL, error) -> Void in
                if error == nil {
                    let identifier: String = storageURL!.lastPathComponent
                    let resource = ImageResource(downloadURL: storageURL!, cacheKey: identifier)
                    
                    self.imageView.kf.indicatorType = .activity
                    self.imageView.kf.indicatorType = .custom(indicator: ActivityIndicator())
                    self.imageView.kf.setImage(with: resource, placeholder: self._image)
                    
                }
            })
            
            
        }

        
    }
    
    // MARK: - ARNImageTransitionZoomable
    
    func createTransitionImageView() -> UIImageView {
        let imageView = UIImageView(image: self._image)
        imageView.contentMode = self.imageView.contentMode
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = false
        imageView.frame = self.imageView!.frame
        return imageView
    }
    
    func presentationBeforeAction() {
        self.imageView.isHidden = true
    }
    
    func presentationCompletionAction(_ completeTransition: Bool) {
        self.imageView.isHidden = false
    }
    
    func dismissalBeforeAction() {
        self.imageView.isHidden = true
    }
    
    func dismissalCompletionAction(_ completeTransition: Bool) {
        if !completeTransition {
            self.imageView.isHidden = false
        }
    }
}

struct ActivityIndicator: Indicator {
    let view: UIView = UIView()
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    func startAnimatingView() {
        view.isHidden = false
    }
    func stopAnimatingView() {
        indicator.stopAnimating()
        view.isHidden = true
    }
    
    init() {
        indicator.startAnimating()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        let verticalConstraint = NSLayoutConstraint(item: indicator, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0)
        
        let horizontalConstraint = NSLayoutConstraint(item: indicator, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
        
        view.addConstraint(verticalConstraint)
        view.addConstraint(horizontalConstraint)
        
        view.addSubview(indicator)
    }
}
