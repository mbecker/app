//
//  FormViewController.swift
//  ImagePicker
//
//  Created by Mats Becker on 10/29/16.
//  Copyright © 2016 Hyper Interaktiv AS. All rights reserved.
//

import UIKit
import MapKit
import PMAlertController

public enum whatTypes: String {
    case Animal
    case Attraction
    case None
}

protocol FormViewControllerDelegate: class {
    func formViewControllerDone(originalImage: UIImage, resizedImage: UIImage, type: whatTypes, name: String?, items: [String], position: CLLocationCoordinate2D)
}

class FormViewController: UIViewController, ExpandingTransitionPresentingViewController {
    
    let tableView = UITableView()
    weak var delegate: FormViewControllerDelegate?
    
    var selectedIndexPath: IndexPath?
    
    let transition = ExpandingCellTransition(type: .Presenting)
    
    let doneButton = SaveCancelButton(title: "Done", position: .Right, type: .Reverted, showimage: false)
    let backButton = SaveCancelButton(title: "Back", position: .Left, type: .Reverted, showimage: false)
    
    var selectedName: String?
    var selectedType: whatTypes {
        didSet {
            switch selectedType {
            case .Animal:
                self.cellWhat.detailLabel.text = "Select animals"
                self.cellWhat.descriptionLabel.text = self.descriptionText
                self.cellType.detailLabel.text = "Animal"
                self.cellType.descriptionLabel.text = "Click to change"
            case .Attraction:
                self.cellWhat.detailLabel.text = "Select attractions"
                self.cellWhat.descriptionLabel.text = self.descriptionText
                self.cellType.detailLabel.text = "Attraction"
                self.cellType.descriptionLabel.text = "Click to change"
            default:
                self.cellWhat.detailLabel.text = "Select type"
            }
            
            self.selectedItems = []
            self.selectedCells = []
        }
    }
    var selectedLocation: CLLocationCoordinate2D!
    var selectedItems = [String]()
    var selectedCells = [IndexPath]()
    
    let descriptionText = "Click to select"
    let defaultLocation = CLLocationCoordinate2D(latitude: -33.483333, longitude: 25.750000)

    
    let resizedImage: UIImage!
    let originalImage: UIImage!
    
    
    init(originalImage: UIImage, resizedImage: UIImage, location: CLLocationCoordinate2D?) {
        self.resizedImage = resizedImage
        self.originalImage = originalImage
        if let _: CLLocationCoordinate2D = location {
            self.selectedLocation = location!
        } else {
            // ToDo: Get park location from settings to show specific information like GPS Location, which animals, etc. (at which park is the user?)
            self.selectedLocation = defaultLocation
        }
        self.cellImage = FormTableImageCell(style: .default, reuseIdentifier: nil, image: resizedImage)
        self.selectedType = .None
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override var prefersStatusBarHidden : Bool {
        return true
    }
    
    /**
     * CELLS
     */
    let cellType = FormTableLabelCell(style: .default, reuseIdentifier: nil, heading: "Type?", detail: "Animal or Attraction", description: "Click to select")
    let cellName: FormTableViewCell = FormTableViewCell()
    let cellWhere = FormTableLabelCell(style: .default, reuseIdentifier: nil, heading: "Where?", detail: "Select Location", description: "Click to select")
    let cellWhat = FormTableLabelCell(style: .default, reuseIdentifier: nil, heading: "What?", detail: "Select type", description: "")
    let cellImage: FormTableImageCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.navigationController?.delegate = self
        self.edgesForExtendedLayout = .top
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.frame = self.view.frame
        self.tableView.register(FormTableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.tableHeaderView = headerView
        self.tableView.tableFooterView = UIView()
        
        
        /**
         * Buttons
         */
        doneButton.addTarget(self, action: #selector(self.navButtonDone), for: UIControlEvents.touchUpInside)
        backButton.addTarget(self, action: #selector(self.navButtonBack), for: UIControlEvents.touchUpInside)
        
        
        /**
         * CELLS
         */
        
        let selectedBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: self.tableView.rowHeight))
        selectedBackgroundView.backgroundColor = UIColor(red:0.10, green:0.71, blue:0.57, alpha:1.00).withAlphaComponent(0.2)
        
        self.cellType.selectionStyle = .default
        self.cellType.selectedBackgroundView = selectedBackgroundView
        self.cellType.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        self.cellName.headingLabel.text = "Name"
        self.cellName.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        self.cellName.selectionStyle = .none
        
        self.cellWhat.selectionStyle = .default
        self.cellWhat.selectedBackgroundView = selectedBackgroundView
        self.cellWhat.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        let lat = String(self.selectedLocation.latitude).range(from: 0, to: 5)
        let long = String(self.selectedLocation.longitude).range(from: 0, to: 5)
        self.cellWhere.detailLabel.text = "\(lat), \(long)"
        self.cellWhere.selectionStyle = .default
        self.cellWhere.selectedBackgroundView = selectedBackgroundView
        self.cellWhere.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        self.cellImage.selectionStyle = .none
        self.cellImage.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        self.view.addSubview(self.tableView)
        self.view.addSubview(doneButton)
        self.view.addSubview(backButton)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.tableView.allowsSelectionDuringEditing = false
        
        // Deselect rows
        
        self.tableView.deselectRow(at: IndexPath(row: 2, section: 0), animated: false)
        self.tableView.deselectRow(at: IndexPath(row: 3, section: 0), animated: false)
        self.tableView.deselectRow(at: IndexPath(row: 4, section: 0), animated: false)
        self.tableView.deselectRow(at: IndexPath(row: 5, section: 0), animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /**
     *varlled when the user click on the view (outside the UITextField).
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func navButtonDone(){
        
        var errorLables = [UILabel]()
        
        // 1. Check Type
        if self.selectedType == .None {
            errorLables.insert(self.cellType.descriptionLabel, at: 0)
        }
        
        // 2. Check What
        if self.selectedItems.count == 0 {
            errorLables.insert(self.cellWhat.descriptionLabel, at: 0)
        }
        
        // 3. Check location
        if self.selectedLocation == nil {
            self.cellWhere.descriptionLabel.text = "Click to select"
            errorLables.insert(self.cellWhere.descriptionLabel, at: 0)
        }
        if self.selectedLocation.latitude == defaultLocation.latitude && self.selectedLocation.longitude == defaultLocation.longitude {
            self.cellWhere.descriptionLabel.text = "Please select the location of your spot"
            errorLables.insert(self.cellWhere.descriptionLabel, at: 0)
        }
        
        // Show errors or upload image
        if errorLables.count > 0 {
            for label in errorLables {
                label.textColor = UIColor(red:0.83, green:0.29, blue:0.31, alpha:1.00)
            }
            return
        } else {
            if self.cellName.textField.text == "Add name" {
                self.selectedName = nil
            } else {
               self.selectedName = self.cellName.textField.text
            }
            self.delegate?.formViewControllerDone(originalImage: self.originalImage, resizedImage: self.resizedImage, type: self.selectedType, name: self.selectedName, items: self.selectedItems, position: self.selectedLocation)
        }
        
    }
    
    func navButtonBack(){
        self.navigationController?.popViewController(animated: false)
    }
    
    func showTypeAlert(){
        let alertVC = PMAlertController(title: "Type of your spot?", description: "Please selct the type of your spot.", image: nil, style: .alert)
        
        alertVC.addAction(PMAlertAction(title: "Animal", style: .default, action: { () -> Void in
            self.tableView.deselectRow(at: IndexPath(row: 1, section: 0), animated: false)
            self.tableView.deselectRow(at: IndexPath(row: 2, section: 0), animated: false)
            self.selectedType = .Animal
            self.doneButton.isHidden = false
            self.backButton.isHidden = false
        }))
        
        alertVC.addAction(PMAlertAction(title: "Attraction", style: .default, action: { () in
            self.tableView.deselectRow(at: IndexPath(row: 1, section: 0), animated: false)
            self.tableView.deselectRow(at: IndexPath(row: 2, section: 0), animated: false)
            self.selectedType = .Attraction
            self.doneButton.isHidden = false
            self.backButton.isHidden = false
        }))
        self.doneButton.isHidden = true
        self.backButton.isHidden = true
        self.present(alertVC, animated: true, completion: nil)
    }
    
    
    /**
     * HEADER VIEW
     */
    
    lazy var headerView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: 90))
        view.backgroundColor = UIColor.white
        
        let header = UILabel()
        header.attributedText = NSAttributedString(
            string: "Add details",
            attributes: [
                NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 23)!,
                NSForegroundColorAttributeName: UIColor(red:0.24, green:0.24, blue:0.24, alpha:1.00), // Baltic sea
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.6,
                ])
        header.translatesAutoresizingMaskIntoConstraints = false
        
        let seperator = UIView()
        seperator.backgroundColor = UIColor(red:0.28, green:0.28, blue:0.28, alpha:1.00) // Charcoal
        seperator.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(header)
        view.addSubview(seperator)
        
        let constraintLeftHeader = NSLayoutConstraint(item: header, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 20)
        let constraintBottomHeader = NSLayoutConstraint(item: header, attribute: .bottom, relatedBy: .equal, toItem: seperator, attribute: .top, multiplier: 1, constant: -16)
        
        let constraintTopSeperator = NSLayoutConstraint(item: seperator, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 60)
        let constraintLeftSeperator = NSLayoutConstraint(item: seperator, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 20)
        let constraintWidthSeperator = NSLayoutConstraint(item: seperator, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 80)
        let constraintHeightSeperator = NSLayoutConstraint(item: seperator, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 1)
        
        view.addConstraint(constraintLeftHeader)
        view.addConstraint(constraintBottomHeader)
        
        view.addConstraint(constraintLeftSeperator)
        view.addConstraint(constraintTopSeperator)
        view.addConstraint(constraintWidthSeperator)
        view.addConstraint(constraintHeightSeperator)
        
        return view
    }()
    
    // MARK: ExpandingTransitionPresentingViewController
    public func expandingTransitionTargetViewForTransition(transition: ExpandingCellTransition) -> UIView! {
        if let indexPath = self.selectedIndexPath {
            return self.tableView.cellForRow(at: indexPath)
        }
        else {
            return nil
        }
    }
    
}

extension FormViewController : UINavigationControllerDelegate {
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.transition
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self.transition
    }
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if fromVC is FormViewController {
            transition.type = .Presenting
        } else {
            transition.type = .Dismissing
        }
        return self.transition
    }
    
}

/**
 * Tableview Delegate methodes
 */
extension FormViewController : UITableViewDelegate {
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 4:
            let cellWidth = self.tableView.bounds.width - 40
            let imageHeight = cellWidth / 1.25
            let cellHeight = imageHeight + 20
            print(":: CELL HEIGHT - \(cellHeight)")
            // SELECTED IMAGE - (0.0, 0.0, 327.0, 218.0)
            return 218 + 20
        default:
            return 70
        }
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 4:
            return 230
        default:
            return 70
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(":: FORM TABLE VIEW CONTROLLER - DID SELECT")
        // End editing textfield
        self.view.endEditing(true)
        
        self.selectedIndexPath = indexPath
        
        switch indexPath.row {
        case 1: // Type of your spot?
            showTypeAlert()
            break
        case 2: // WHAT?
            if self.selectedType == .None  {
                showTypeAlert()
            }
            let controller = AnimalFormCollections(title: "Select " + self.selectedType.rawValue + "s", type: self.selectedType, selectedCells: self.selectedCells)
            controller.delegate = self
            controller.modalPresentationStyle = .custom
            controller.modalPresentationCapturesStatusBarAppearance = true
            self.navigationController?.pushViewController(controller, animated: true)
        case 3: // WHERE?
            let mapFormViewController = MapFormViewController(location: self.selectedLocation)
            mapFormViewController.delegate = self
            mapFormViewController.modalPresentationStyle = .custom
            mapFormViewController.modalPresentationCapturesStatusBarAppearance = true
            self.navigationController?.pushViewController(mapFormViewController, animated: true)
            break
        default:
            break
        }
        
        
    }
    
}

extension FormViewController : UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return self.cellName
        case 1:
            return self.cellType
        case 2:
            return self.cellWhat
        case 4:
            return self.cellImage
        default:
            return self.cellWhere
        }
    }
    
    
}

/*
 * Animal Form Collections -
 */
extension FormViewController : AnimalFormCollectionDelegate {
    
    public func saveItems(index: [IndexPath], items: [String]) {
        
        if items.count > 1 {
            self.cellWhat.detailLabel.text = String(items.count) + " " + self.selectedType.rawValue + "s"
            self.cellWhat.descriptionLabel.text = items.joined(separator: ", ")
        } else if items.count == 1 {
            self.cellWhat.detailLabel.text = String(items.count) + " " + self.selectedType.rawValue
            self.cellWhat.descriptionLabel.text = items[0]
        } else {
            self.cellWhat.descriptionLabel.text = self.descriptionText
        }
        
        self.selectedItems = items
        self.selectedCells = index
        
        self.tableView.setNeedsDisplay()
        self.navigationController?.popViewController(animated: true)
    }
    
}

/*
 * Map Form Delegate
 */
extension FormViewController : MapFormViewControllerDelegate {
    public func saveLocation(location: CLLocationCoordinate2D) {
        self.selectedLocation = location
        let lat = String(self.selectedLocation.latitude).range(from: 0, to: 5)
        let long = String(self.selectedLocation.longitude).range(from: 0, to: 5)
        self.cellWhere.detailLabel.text = "\(lat), \(long)"
        self.cellWhere.descriptionLabel.text = "... fetching Street Name"
        self.navigationController?.popViewController(animated: true)
    }
}

