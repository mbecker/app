//
//  ViewController.swift
//

import UIKit
import AsyncDisplayKit
import Firebase
import FirebaseDatabase
import ARNTransitionAnimator

let airBnbImageFooterHeight: CGFloat = 58
let airBnbHeight: CGFloat = 218 + airBnbImageFooterHeight
let airBnbInset = UIEdgeInsetsMake(0, 24, 0, 24)
let airbnbSpacing = 12


final class ViewController: ASViewController<ASDisplayNode>, ASTableDataSource, ASTableDelegate {
    
    var sections : [Section] = [Section]()
    
    var tableNode: ASTableNode {
        return node as! ASTableNode
    }
    
    // MARK: Firebase init
    var ref: FIRDatabaseReference!
    var refs: [FIRDatabaseReference] = [FIRDatabaseReference]()
    
    // ARNImageTransitionZoomable
    var _imageTransitionZoomable: ASNetworkImageNode?
    
    var statusBarHidden = false {
        didSet {
            UIView.animate(withDuration: 0.5) { () -> Void in
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    let headerView = HeaderView(text: "Addo Elephant Park")
    
    
    init() {
        // Create a root reference
        super.init(node: ASTableNode(style: UITableViewStyle.grouped))
        tableNode.view.asyncDataSource = self
        tableNode.view.asyncDelegate = self
    }
    
    override var prefersStatusBarHidden: Bool {
        return self.statusBarHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .none
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // removing text "back" from statusbar
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // TableView
        self.tableNode.view.showsVerticalScrollIndicator = false
        self.tableNode.backgroundColor = UIColor.white
        self.tableNode.view.separatorColor = UIColor.clear
        
        // View
        self.tableNode.view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.headerView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 144)
        self.tableNode.view.tableHeaderView = self.headerView
        
        // MARK: Firebase
        ref = FIRDatabase.database().reference()
        ref.child("sections").observeSingleEvent(of: .value, with: { (snapshot) in
            let snaps = snapshot.value as! [String : NSDictionary]
            for snap in snaps {
                self.sections.append(Section.init(name: snap.value.object(forKey: "name") as! String, path: snap.value.object(forKey: "path") as! String))
            }
            self.tableNode.view.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        // It’s safe to use the view controller’s views’ bound size since the logic is inside viewWillLayoutSubviews() instead of viewDidLoad().
        // By this time in its lifecycle, the view controller’s view will already have its size set.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.statusBarHidden = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
   
    
    // MARK: ASTableView data source and delegate.
    
    func tableView(_ tableView: ASTableView, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        return {
            let cell = FirebaseCell(section: self.sections[indexPath.section], sectionSize: CGSize(width: self.view.frame.width, height: airBnbHeight))
            cell.delegate = self
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: ASTableView, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        return ASSizeRangeMake(CGSize(width: 0, height: 0), CGSize(width: self.view.frame.width, height: airBnbHeight))
    }
    
    
    // MARK: - Table section header & footer
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return createSectionHeaderView(text: self.sections[section].name)
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 74
    }
    
    func createSectionHeaderView(text: String) -> UIView {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor.white
        
        let title = UILabel()
        title.attributedText = NSAttributedString(
            string: text,
            attributes: [
                NSFontAttributeName: UIFont(name: "CircularStd-Book", size: 24)!,
                NSForegroundColorAttributeName: UIColor(red:0.24, green:0.24, blue:0.24, alpha:1.00), // Baltic sea
                NSBackgroundColorAttributeName: UIColor.clear,
                NSKernAttributeName: 0.0,
                ])
        title.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(title)
        
        let constraintLeftTitle = NSLayoutConstraint(item: title, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 20)
        let constraintCenterYTitle = NSLayoutConstraint(item: title, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        
        view.addConstraint(constraintLeftTitle)
        view.addConstraint(constraintCenterYTitle)
        
        return view
    }

    
}


extension ViewController : ARNImageTransitionZoomable, ZoomCellDelegate {
    
    /*
     * ZoomCellDelegate
     */
    
    func selectedItem(_ item:SectionData, _ image:ASNetworkImageNode){
        self._imageTransitionZoomable = image
        let storyboard = UIStoryboard(name: "DetailViewController", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        controller._data = item
        controller._image = image.image
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    /*
     * ARNImageTransitionZoomable
     */
    
    func createTransitionImageView() -> UIImageView {
        
        // Create imageView on given image
        let imageView = UIImageView(image: self._imageTransitionZoomable?.image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = false
        
        // Get superlayer
        var rootLayer: CALayer? = self._imageTransitionZoomable?.layer
        while let nextLayer = rootLayer?.superlayer {
            rootLayer = nextLayer
        }
        
        imageView.frame = (self._imageTransitionZoomable?.layer.convert((self._imageTransitionZoomable?.frame)!, to: rootLayer))!
        return imageView
    }
    
    func presentationCompletionAction(_ completeTransition: Bool) {
        self._imageTransitionZoomable?.isHidden = true
    }
    
    func dismissalCompletionAction(_ completeTransition: Bool) {
        self._imageTransitionZoomable?.isHidden = false
    }
}
