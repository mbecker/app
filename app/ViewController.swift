//
//  ViewController.swift
//

import UIKit
import AsyncDisplayKit
import Firebase
import FirebaseDatabase
import Kingfisher
import ARNTransitionAnimator
import ChameleonFramework

let airBnbImageFooterHeight: CGFloat = 58
let airBnbHeight: CGFloat = 218 + airBnbImageFooterHeight
let airBnbInset = UIEdgeInsetsMake(0, 24, 0, 24)


final class ViewController: ASViewController<ASDisplayNode>, ASTableDataSource, ASTableDelegate, ARNImageTransitionZoomable, ZoomCellDelegate {
    
    var sections : [Section] = [Section]()
    
    var tableNode: ASTableNode {
        return node as! ASTableNode
    }
    
    // MARK: Firebase init
    var ref: FIRDatabaseReference!
    var refs: [FIRDatabaseReference] = [FIRDatabaseReference]()
    
    // ARNImageTransitionZoomable
    var _imageTransitionZoomable: ASNetworkImageNode?
    
    
    init() {
        super.init(node: ASTableNode(style: UITableViewStyle.grouped))
        tableNode.view.asyncDataSource = self
        tableNode.view.asyncDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation bar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(didTapAdd))
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Clear Cache", style: .plain, target: self, action: #selector(didTapClearCache))
        
        // removing text "back" from statusbar
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.tableNode.view.showsVerticalScrollIndicator = false
        self.tableNode.backgroundColor = UIColor.white
        self.tableNode.view.separatorColor = UIColor.clear
        
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func viewWillLayoutSubviews() {
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
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: self.tableNode.view.bounds.size.width, height: 46)
        headerView.backgroundColor = UIColor.white
        headerView.translatesAutoresizingMaskIntoConstraints = true
        let headerLabel   = UILabel()
        let myTitle = self.sections[section].name
        
        let attributes: NSDictionary = [
            NSForegroundColorAttributeName: UIColor.black,
            NSKernAttributeName:CGFloat(0.6)
        ]
        let attributedTitle = NSAttributedString(string: myTitle, attributes: attributes as? [String : AnyObject])
        headerLabel.font  = UIFont(name: "Calibre-Light", size: 24)
        headerLabel.attributedText = attributedTitle
        headerLabel.numberOfLines = 1
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let hLabel = UILabel()
        hLabel.attributedText = attributedTitle
        
        headerView.addSubview(headerLabel)
        
        //    let verticalConstraint = NSLayoutConstraint(item: headerLabel, attribute: .centerY, relatedBy: .equal, toItem: headerView, attribute: .centerY, multiplier: 1, constant: 0)
        let leadingMargin = NSLayoutConstraint(item: headerLabel, attribute: .leadingMargin, relatedBy: .equal, toItem: headerView, attribute: .leadingMargin, multiplier: 1, constant: airBnbInset.left)
        
        //    NSLayoutConstraint.activate([verticalConstraint])
        //    headerView.addConstraint(verticalConstraint)
        
        headerView.addConstraint(leadingMargin)
        
        return headerView
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 46
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: self.tableNode.view.bounds.size.width, height: 46)
        headerView.backgroundColor = UIColor.white
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 46
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    // MARK: - CustomCellDelegate
    
    func selectedItem(_ item:SectionData, _ image:ASNetworkImageNode){
        self._imageTransitionZoomable = image
        let storyboard = UIStoryboard(name: "DetailViewController", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        controller.image = self._imageTransitionZoomable?.image
        controller.title = item.name
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - ARNImageTransitionZoomable
    
    func createTransitionImageView() -> UIImageView {
        let imageView = UIImageView(image: self._imageTransitionZoomable?.image)
//        imageView.contentMode = (self._imageTransitionZoomable?.contentMode)!
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
