//
//  MapFormViewController.swift
//  ImagePicker
//
//  Created by Mats Becker on 10/26/16.
//  Copyright © 2016 Hyper Interaktiv AS. All rights reserved.
//

import UIKit
import Mapbox

protocol MapFormViewControllerDelegate: class {
    func saveLocation(location: CLLocationCoordinate2D)
}

class MapFormViewController: UIViewController {
    
    var navigationBarSnapshot: UIView!
    var navigationBarHeight: CGFloat = 0
    let location: CLLocationCoordinate2D
    var mapView: MGLMapView!
    weak var delegate: MapFormViewControllerDelegate?
    
    init(location: CLLocationCoordinate2D) {
        self.location = location
        super.init(nibName: nil, bundle: nil)
        print(":: INIT ::")
        showTitle(title: "Map")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showTitle(title: "Map")
        
        let saveButton = SaveCancelButton(title: "Save", position: .Right, type: .Normal, showimage: true)
        let mapButton = MapButton(position: .Left)
        saveButton.addTarget(self, action: #selector(self.saveLocation), for: UIControlEvents.touchUpInside)
        
        //create a new button
        let button: UIButton = UIButton(type: .custom)
        //set image for button
        button.setImage(AssetManager.getImage("cancel32.png"), for: UIControlState.normal)
        //add function for button
        button.addTarget(self, action: #selector(self.popBack), for: UIControlEvents.touchUpInside)
        //set frame
        button.frame = CGRect(x: 0, y: 0, width: 64, height: 64)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 32)
        button.backgroundColor = UIColor.clear
        
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
        
        self.mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Set the map’s center coordinate and zoom level.
        mapView.setCenter(self.location, zoomLevel: 16, animated: false)
        
        mapView.addSubview(pinView)
        mapView.layer.insertSublayer(ellipsisLayer, below: pinView.layer)
        
        let center = mapView.convert(mapView.centerCoordinate, toPointTo: pinView)
        pinView.center = CGPoint(x: center.x, y: center.y - (pinView.bounds.height/2))
        ellipsisLayer.position = center
        
        self.view.addSubview(mapView)
        self.view.addSubview(saveButton)
        self.view.addSubview(mapButton)
    }
    
    func popBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func saveLocation(){
        self.delegate?.saveLocation(location: self.mapView.centerCoordinate)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.colorForNavBar(color: UIColor.white), for: .any, barMetrics: .default)
        showTitle(title: "Map")
    }
    
    func showTitle(title: String){
        let navLabel = UILabel()
        navLabel.attributedText = NSAttributedString(
            string: title,
            attributes: [
                NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 23)!,
                NSForegroundColorAttributeName: UIColor(red:0.24, green:0.24, blue:0.24, alpha:1.00),
                NSKernAttributeName: 0.6,
                ])
        navLabel.sizeToFit()
        self.navigationItem.titleView = navLabel
    }
    
    /**
     * User center circle
     */
    lazy var pinView: UIImageView = { [unowned self] in
        let v = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        v.image = v.image?.withRenderingMode(.alwaysTemplate)
        v.tintColor = self.view.tintColor
        v.backgroundColor = .clear
        v.clipsToBounds = true
        v.contentMode = .scaleAspectFit
        v.isUserInteractionEnabled = false
        return v
        }()
    
    let width: CGFloat = 18.0
    let height: CGFloat = 5.0
    
    lazy var ellipse: UIBezierPath = { [unowned self] in
        let ellipse = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: self.width, height: self.width))
        return ellipse
        }()
    
    lazy var ellipsisLayer: CAShapeLayer = { [unowned self] in
        let layer = CAShapeLayer()
        layer.bounds = CGRect(x: 0, y: 0, width: self.width, height: self.width)
        layer.path = self.ellipse.cgPath
        layer.fillColor = UIColor(red:1.00, green:0.31, blue:0.33, alpha:1.00).cgColor
        layer.fillRule = kCAFillRuleNonZero
        layer.lineCap = kCALineCapButt
        layer.lineDashPattern = nil
        layer.lineDashPhase = 0.0
        layer.lineJoin = kCALineJoinMiter
        layer.lineWidth = 4.0
        layer.miterLimit = 10.0
        layer.strokeColor = UIColor.white.cgColor
        return layer
        }()
    
}

// MARK: ExpandingTransitionPresentedViewController
extension MapFormViewController : ExpandingTransitionPresentedViewController {
    
    func expandingTransition(transition: ExpandingCellTransition, navigationBarSnapshot: UIView) {
        self.navigationBarSnapshot = navigationBarSnapshot
        self.navigationBarHeight = navigationBarSnapshot.frame.height
    }
    
}

extension MapFormViewController : MGLMapViewDelegate {
    public func mapView(_ mapView: MGLMapView, regionWillChangeAnimated animated: Bool) {
        ellipsisLayer.transform = CATransform3DMakeScale(0.5, 0.5, 1)
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.pinView.center = CGPoint(x: self!.pinView.center.x, y: self!.pinView.center.y - 10)
            })
    }
    
    public func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
        ellipsisLayer.transform = CATransform3DIdentity
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.pinView.center = CGPoint(x: self!.pinView.center.x, y: self!.pinView.center.y + 10)
            })
    }
    
    
    
}
