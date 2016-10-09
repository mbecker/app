//
//  DetailViewController.swift
//  ARNZoomImageTransition
//
//  Created by xxxAIRINxxx on 2015/08/08.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, ARNImageTransitionZoomable {
    
    
    @IBOutlet var imageView: UIImageView!
    var image: UIImage?
    
    
    deinit {
        print("deinit DetailViewController")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.imageView.image = image
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        self.imageView.image = image
    }
    
    // MARK: - ARNImageTransitionZoomable
    
    func createTransitionImageView() -> UIImageView {
        let imageView = UIImageView(image: self.imageView.image)
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
