//
//  ViewController.swift
//

import UIKit
import AsyncDisplayKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import Kingfisher
import ARNTransitionAnimator
import ChameleonFramework
import ImagePicker
import ImageIO

let airBnbImageFooterHeight: CGFloat = 58
let airBnbHeight: CGFloat = 218 + airBnbImageFooterHeight
let airBnbInset = UIEdgeInsetsMake(0, 24, 0, 24)
let airbnbSpacing = 12


final class ViewController: ASViewController<ASDisplayNode>, ASTableDataSource, ASTableDelegate, ARNImageTransitionZoomable, ZoomCellDelegate, ImagePickerDelegate {
    

    
    var sections : [Section] = [Section]()
    
    var tableNode: ASTableNode {
        return node as! ASTableNode
    }
    
    // MARK: Firebase init
    var ref: FIRDatabaseReference!
    var refs: [FIRDatabaseReference] = [FIRDatabaseReference]()
    var _storage = FIRStorage.storage()
    var _storageRef: FIRStorageReference
    
    // ARNImageTransitionZoomable
    var _imageTransitionZoomable: ASNetworkImageNode?
    
    
    init() {
        // Create a root reference
        self._storageRef = self._storage.reference()
        super.init(node: ASTableNode(style: UITableViewStyle.grouped))
        tableNode.view.asyncDataSource = self
        tableNode.view.asyncDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showCamera()
        
        // removing text "back" from statusbar
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // TableView
        self.tableNode.view.showsVerticalScrollIndicator = false
        self.tableNode.backgroundColor = UIColor.white
        self.tableNode.view.separatorColor = UIColor.clear
        
        // View
        self.tableNode.view.contentInset = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
        

        
        let searchController = UISearchController(searchResultsController: nil)
//        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.definesPresentationContext = true
        searchController.searchBar.sizeToFit()
//        self.tableNode.view.tableHeaderView = searchController.searchBar
        
        let wrapper = ASDisplayNode()
        wrapper.frame = CGRect(x: 0, y: 0, width: 320, height: 300)
        wrapper.backgroundColor = UIColor.white
        wrapper.isAccessibilityElement = false
        wrapper.accessibilityLabel = "wrapperNode"
        wrapper.accessibilityIdentifier = "wrapperNode"
        wrapper.isUserInteractionEnabled = true
        
        let buttonAddData = UIButton(frame: CGRect(x: 25, y: 0, width: 150, height: 50))
        buttonAddData.setBackgroundColor(color: UIColor.flatBlue(), forState: .normal)
        buttonAddData.setBackgroundColor(color: UIColor.flatBlueColorDark(), forState: .highlighted)
        buttonAddData.setTitle("Add / Delete", for: .normal)
        buttonAddData.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)
        wrapper.view.addSubview(buttonAddData)
        
        let buttonClearCache = UIButton(frame: CGRect(x: self.tableNode.bounds.width - 25 - 150, y: 0, width: 150, height: 50))
        buttonClearCache.setBackgroundColor(color: UIColor.flatRed(), forState: .normal)
        buttonClearCache.setBackgroundColor(color: UIColor.flatRedColorDark(), forState: .highlighted)
        buttonClearCache.setTitle("Clear Cache", for: .normal)
        buttonClearCache.addTarget(self, action: #selector(didTapClearCache), for: .touchUpInside)
        wrapper.view.addSubview(buttonClearCache)
        
        let buttonCamera = UIButton(frame: CGRect(x: 25, y: 75, width: 150, height: 50))
        buttonCamera.setBackgroundColor(color: UIColor.flatLime(), forState: .normal)
        buttonCamera.setBackgroundColor(color: UIColor.flatLimeColorDark(), forState: .highlighted)
        buttonCamera.setTitle("Spot!", for: .normal)
        buttonCamera.addTarget(self, action: #selector(buttonTouched(button:)), for: .touchUpInside)
        wrapper.view.addSubview(buttonCamera)
        
        self.tableNode.view.tableFooterView = wrapper.view
        self.tableNode.view.tableFooterView?.frame = CGRect(x: 0, y: 0, width: 250, height: 150)
        
        
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
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
        let headerNode = SectionHeaderNode(headerText: self.sections[section].name)
        headerNode.frame = CGRect(x: 0, y: 0, width: self.tableNode.bounds.width, height: 46)
        return headerNode.view
        
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
    
    // MARK: - CustomCellDelegate: Show detail
    
    func selectedItem(_ item:SectionData, _ image:ASNetworkImageNode){
        self._imageTransitionZoomable = image
        let storyboard = UIStoryboard(name: "DetailViewController", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        controller._data = item
        controller._image = image.image
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - ARNImageTransitionZoomable
    
    func createTransitionImageView() -> UIImageView {
        let width = self._imageTransitionZoomable?.image!.accessibilityFrame.width
        print("__ Image size: \(width)")
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
    
    func buttonTouched(button: UIButton) {
        showCamera()
    }
    
    // MARK: - ImagePickerDelegate
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
//        imagePicker.dismiss(animated: true, completion: nil)
        self.tabBarController?.dismiss(animated: false, completion: nil)
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print(":: ImagePicker - wrapperDidPress")
    }
    
    
    // ImagePicker done
    public func doneButtonDidPress(_ imagePicker: ImagePickerController, original: [UIImage], images: [UIImage]) {
        guard images.count > 0 else { return }
        
        var imageAssets: [UIImage] {
            return AssetManager.resolveAssets(imagePicker.stack.assets)
        }
        
        let imageNode = ASImageNode()
        
        imageNode.image = images[0].resizedImageWithinRect(rectSize: CGSize(width: 375, height: 300))
        imageNode.frame = CGRect(x: 0, y: 0, width: 375, height: 300)
        
        self.tableNode.addSubnode(imageNode)
        
        self.tabBarController?.dismiss(animated: false, completion: nil)
        //        processImages(imagePicker: imagePicker, images: images)

    }
    
    func processImages(imagePicker: ImagePickerController, images: [UIImage]){
        // Add progress bar
        let progressView = UIProgressView(frame: CGRect(x: 0, y: 0, width: self.tableNode.frame.width, height: 1))
        progressView.progressViewStyle = .default
        progressView.progressTintColor = UIColor.flatRed()
        progressView.trackTintColor = UIColor.flatWhite()
        progressView.progress = 0.25
        self.tabBarController?.tabBar.addSubview(progressView)
        
        // Dismiss ImagePicker
        imagePicker.dismiss(animated: true, completion: nil)
        
        // Upload image
        let imageData = UIImageJPEGRepresentation(images[0], 1.0)                                                               // Get data
        let imageResizedData = UIImageJPEGRepresentation(images[0].resizedImageWithinRect(rectSize: CGSize(width: 375, height: 300)), 0.6) // Get data from resized image
        let timestamp = String(Int64(NSDate().timeIntervalSince1970 * 1000))                                                    // Get image name
        let imageRef = self._storageRef.child("animals/\(timestamp).jpg")                                                       // Get storage reference for new uploaded image with given imagename
        let imageResizedRef = self._storageRef.child("animals/\(timestamp)_375x300.jpg")                                        // Get storage reference for new uploaded image with given imagename
        
        var imageURL: String = String()
        let metadataForImages = FIRStorageMetadata()
        metadataForImages.contentType = "image/jpeg"
        
        let imageUploadTask = imageRef.put(imageData!, metadata: metadataForImages)
        
        imageUploadTask.observe(.progress) { snapshot in
            // Upload reported progress
            if let progress = snapshot.progress {
                let percentComplete: Float = 60 * Float(progress.completedUnitCount) / Float(progress.totalUnitCount)
                print(":: Upload image 1 - \(percentComplete)")
                progressView.setProgress(percentComplete / 100, animated: true);
                
            }
        }
        imageUploadTask.observe(.success) { snapshot in
            imageURL = (snapshot.metadata?.downloadURL()!.absoluteString)!
            
            let imageResizedUploadTask = imageResizedRef.put(imageResizedData!, metadata: metadataForImages)
            imageResizedUploadTask.observe(.progress) { snapshot in
                // Upload reported progress
                if let progress = snapshot.progress {
                    let percentComplete: Float = 30 * Float(progress.completedUnitCount) / Float(progress.totalUnitCount)
                    print(":: Upload image  2 - \(percentComplete)")
                    progressView.setProgress(0.6 + percentComplete / 100, animated: true);
                    
                }
            }
            imageResizedUploadTask.observe(.success) { snapshot in
                // Upload completed successfully
                DatabaseModels().addAnimal(name: timestamp, url: imageURL, resizedURL: (snapshot.metadata?.downloadURL()?.absoluteString)!)
                progressView.setProgress(1, animated: true)
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (timer) in
                    progressView.removeFromSuperview()
                })
            }
        }
    }
    
    
    
    func showCamera(){
        let imagePicker = ImagePickerController()
        imagePicker.delegate = self
        Configuration.recordLocation = true
        Configuration.imageLimit = 1
        imagePicker.imageLimit = 1
        
        let imageNavcontroller = UINavigationController(rootViewController: imagePicker)
        imageNavcontroller.isNavigationBarHidden = true
        self.tabBarController?.show(imageNavcontroller, sender: nil)
        
//        present(imagePicker, animated: true, completion: nil)
    }
    
    
}
