import UIKit
import MediaPlayer
import Photos
import TOCropViewController

public protocol ImagePickerDelegate: class {
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage])
    func doneButtonDidPress(_ imagePicker: ImagePickerController, originalImages: [UIImage], resizedImages: [UIImage], types: [whatTypes], names: [String?], items: [Int: [String]], positions: [CLLocationCoordinate2D])
    func cancelButtonDidPress(_ imagePicker: ImagePickerController)
    
    
}

open class ImagePickerController: UIViewController {
    
    let locationManager = LocationManager()
    let doneButton = SaveCancelButton(title: "Next", position: .Right, type: .Reverted, showimage: false)
    let cancelButton = SaveCancelButton(title: "Cancel", position: .Left, type: .Reverted, showimage: false)
    
    var statusBarHidden = false {
        didSet {
            UIView.animate(withDuration: 0.5) { () -> Void in
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    var statusBarHiddenGlobal = true
    
    struct GestureConstants {
        static let maximumHeight: CGFloat = 200
        static let minimumHeight: CGFloat = 125
        static let velocity: CGFloat = 100
    }
    
    open lazy var galleryView: ImageGalleryView = { [unowned self] in
        let galleryView = ImageGalleryView()
        galleryView.delegate = self
        galleryView.selectedStack = self.stack
        galleryView.collectionView.layer.anchorPoint = CGPoint(x: 0, y: 0)
        galleryView.imageLimit = self.imageLimit
        
        return galleryView
        }()
    
    open lazy var bottomContainer: BottomContainerView = { [unowned self] in
        let view = BottomContainerView()
        view.delegate = self
        
        return view
        }()
    
    lazy var topView: TopView = { [unowned self] in
        let view = TopView()
        view.backgroundColor = UIColor.clear
        view.delegate = self
        
        return view
        }()
    
    lazy var cameraController: CameraView = { [unowned self] in
        let controller = CameraView()
        controller.delegate = self
        
        return controller
        }()
    
    lazy var panGestureRecognizer: UIPanGestureRecognizer = { [unowned self] in
        let gesture = UIPanGestureRecognizer()
        gesture.addTarget(self, action: #selector(panGestureRecognizerHandler(_:)))
        
        return gesture
        }()
    
    lazy var volumeView: MPVolumeView = { [unowned self] in
        let view = MPVolumeView()
        view.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        return view
        }()
    
    var volume = AVAudioSession.sharedInstance().outputVolume
    
    open weak var delegate: ImagePickerDelegate?
    open var stack = ImageStack()
    open var imageLimit = 0
    open var preferredImageSize: CGSize?
    var totalSize: CGSize { return UIScreen.main.bounds.size }
    var initialFrame: CGRect?
    var initialContentOffset: CGPoint?
    var numberOfCells: Int?
    
    
    fileprivate var isTakingPicture = false
    
    
    // MARK: - View lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isHidden = true
        
        self.locationManager.startUpdatingLocation()
        
        self.doneButton.addTarget(self, action: #selector(self.doneButtonDidPress), for: .touchUpInside)
        self.cancelButton.addTarget(self, action: #selector(self.cancelButtonDidPress), for: .touchUpInside)
        
        for subview in [cameraController.view, galleryView, bottomContainer, topView] {
            view.addSubview(subview!)
            subview?.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.addSubview(volumeView)
        view.sendSubview(toBack: volumeView)
        
        view.backgroundColor = UIColor.white
        view.backgroundColor = Configuration.mainColor
        
        cameraController.view.addGestureRecognizer(panGestureRecognizer)
        
        view.addSubview(doneButton)
        view.addSubview(cancelButton)
        
        subscribe()
        setupConstraints()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _ = try? AVAudioSession.sharedInstance().setActive(true)
        self.navigationController?.navigationBar.isHidden = true
        self.statusBarHidden = true
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let galleryHeight: CGFloat = UIScreen.main.nativeBounds.height == 960
            ? ImageGalleryView.Dimensions.galleryBarHeight : GestureConstants.minimumHeight
        
        galleryView.collectionView.transform = CGAffineTransform.identity
        galleryView.collectionView.contentInset = UIEdgeInsets.zero
        
        galleryView.frame = CGRect(x: 0,
                                   y: totalSize.height - bottomContainer.frame.height - galleryHeight,
                                   width: totalSize.width,
                                   height: galleryHeight)
        galleryView.updateFrames()
        checkStatus()
        
        initialFrame = galleryView.frame
        initialContentOffset = galleryView.collectionView.contentOffset
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    open func resetAssets() {
        self.stack.resetAssets([])
    }
    
    func checkStatus() {
        let currentStatus = PHPhotoLibrary.authorizationStatus()
        guard currentStatus != .authorized else { return }
        
        if currentStatus == .notDetermined { hideViews() }
        
        PHPhotoLibrary.requestAuthorization { (authorizationStatus) -> Void in
            DispatchQueue.main.async {
                if authorizationStatus == .denied {
                    self.presentAskPermissionAlert()
                } else if authorizationStatus == .authorized {
                    self.permissionGranted()
                }
            }
        }
    }
    
    func presentAskPermissionAlert() {
        let alertController = UIAlertController(title: Configuration.requestPermissionTitle, message: Configuration.requestPermissionMessage, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: Configuration.OKButtonTitle, style: .default) { _ in
            if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(settingsURL)
            }
        }
        
        let cancelAction = UIAlertAction(title: Configuration.cancelButtonTitle, style: .cancel) { _ in
            self.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(alertAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func hideViews() {
        enableGestures(false)
    }
    
    func permissionGranted() {
        galleryView.fetchPhotos()
        galleryView.canFetchImages = false
        enableGestures(true)
    }
    
    // MARK: - Notifications
    
    deinit {
        _ = try? AVAudioSession.sharedInstance().setActive(false)
        NotificationCenter.default.removeObserver(self)
    }
    
    func subscribe() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(adjustButtonTitle(_:)),
                                               name: NSNotification.Name(rawValue: ImageStack.Notifications.imageDidPush),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(adjustButtonTitle(_:)),
                                               name: NSNotification.Name(rawValue: ImageStack.Notifications.imageDidDrop),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReloadAssets(_:)),
                                               name: NSNotification.Name(rawValue: ImageStack.Notifications.stackDidReload),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(volumeChanged(_:)),
                                               name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRotation(_:)),
                                               name: NSNotification.Name.UIDeviceOrientationDidChange,
                                               object: nil)
    }
    
    func didReloadAssets(_ notification: Notification) {
        adjustButtonTitle(notification)
        galleryView.collectionView.reloadData()
        galleryView.collectionView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    func volumeChanged(_ notification: Notification) {
        guard let slider = volumeView.subviews.filter({ $0 is UISlider }).first as? UISlider,
            let userInfo = (notification as NSNotification).userInfo,
            let changeReason = userInfo["AVSystemController_AudioVolumeChangeReasonNotificationParameter"] as? String
            , changeReason == "ExplicitVolumeChange" else { return }
        
        slider.setValue(volume, animated: false)
        takePicture()
    }
    
    func adjustButtonTitle(_ notification: Notification) {
        
        // Added by mbecker: Show only done buton; cancel button is now on the left
        self.doneButton.setTitle(Configuration.doneButtonTitle, for: UIControlState())
        self.doneButton.setTitleColor(Configuration.doneButtonColor, for: UIControlState())
        
    }
    
    // MARK: - Helpers
    
    open override var prefersStatusBarHidden : Bool {
        return self.statusBarHidden
    }
    
    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
    open func collapseGalleryView(_ completion: (() -> Void)?) {
        galleryView.collectionViewLayout.invalidateLayout()
        UIView.animate(withDuration: 0.3, animations: {
            self.updateGalleryViewFrames(self.galleryView.topSeparator.frame.height)
            self.galleryView.collectionView.transform = CGAffineTransform.identity
            self.galleryView.collectionView.contentInset = UIEdgeInsets.zero
            }, completion: { _ in
                completion?()
        })
    }
    
    open func showGalleryView() {
        galleryView.collectionViewLayout.invalidateLayout()
        UIView.animate(withDuration: 0.3, animations: {
            self.updateGalleryViewFrames(GestureConstants.minimumHeight)
            self.galleryView.collectionView.transform = CGAffineTransform.identity
            self.galleryView.collectionView.contentInset = UIEdgeInsets.zero
        })
    }
    
    open func expandGalleryView() {
        galleryView.collectionViewLayout.invalidateLayout()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.updateGalleryViewFrames(GestureConstants.maximumHeight)
            
            let scale = (GestureConstants.maximumHeight - ImageGalleryView.Dimensions.galleryBarHeight) / (GestureConstants.minimumHeight - ImageGalleryView.Dimensions.galleryBarHeight)
            self.galleryView.collectionView.transform = CGAffineTransform(scaleX: scale, y: scale)
            
            let value = self.view.frame.width * (scale - 1) / scale
            self.galleryView.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right:  value)
        })
    }
    
    func updateGalleryViewFrames(_ constant: CGFloat) {
        galleryView.frame.origin.y = totalSize.height - bottomContainer.frame.height - constant
        galleryView.frame.size.height = constant
    }
    
    func enableGestures(_ enabled: Bool) {
        galleryView.alpha = enabled ? 1 : 0
        bottomContainer.pickerButton.isEnabled = enabled
        // Update by mbecker: No imagestackview anymore
        //    bottomContainer.tapGestureRecognizer.isEnabled = enabled
        topView.flashButton.isEnabled = enabled
        topView.rotateCamera.isEnabled = Configuration.canRotateCamera
    }
    
    fileprivate func isBelowImageLimit() -> Bool {
        return (imageLimit == 0 || imageLimit > galleryView.selectedStack.assets.count)
    }
    
    fileprivate func takePicture() {
        guard isBelowImageLimit() && !isTakingPicture else { return }
        isTakingPicture = true
        bottomContainer.pickerButton.isEnabled = false
        // Update by mbecker: Comment next line
        // bottomContainer.stackView.startLoader()
        let action: (Void) -> Void = { [unowned self] in
            self.cameraController.takePicture { self.isTakingPicture = false }
        }
        
        if Configuration.collapseCollectionViewWhileShot {
            collapseGalleryView(action)
        } else {
            action()
        }
    }
    
    func doneButtonDidPress() {
        
        // Added by mbecker: If statement to check if stack.asset is empty
        if stack.assets.isEmpty {
            let alert = UIAlertView()
            alert.title = "Camera"
            alert.addButton(withTitle: "OK")
            alert.message = "Please select at least one image"
            alert.show()
        } else {
            var images: [UIImage]
            if let preferredImageSize = preferredImageSize {
                images = AssetManager.resolveAssets(stack.assets, size: preferredImageSize)
            } else {
                images = AssetManager.resolveAssets(stack.assets)
            }
            
            // Added by mbecker: Crop
            showCrop(images: images)
            
        }
        
    }
    
    func cancelButtonDidPress() {
        dismiss(animated: true, completion: nil)
        delegate?.cancelButtonDidPress(self)
    }
}

// MARK: - Action methods

extension ImagePickerController: BottomContainerViewDelegate {
    
    func pickerButtonDidPress() {
        takePicture()
    }
    
}

extension ImagePickerController: CameraViewDelegate {
    
    func setFlashButtonHidden(_ hidden: Bool) {
        topView.flashButton.isHidden = hidden
    }
    
    func imageToLibrary() {
        guard let collectionSize = galleryView.collectionSize else { return }
        
        galleryView.fetchPhotos() {
            guard let asset = self.galleryView.assets.first else { return }
            self.stack.pushAsset(asset)
            
            // Added by mbecker: Crop
            let images = AssetManager.resolveAssets(self.stack.assets)
            self.showCrop(images: images)
            
        }
        galleryView.shouldTransform = true
        bottomContainer.pickerButton.isEnabled = true
        
        UIView.animate(withDuration: 0.3, animations: {
            self.galleryView.collectionView.transform = CGAffineTransform(translationX: collectionSize.width, y: 0)
            }, completion: { _ in
                self.galleryView.collectionView.transform = CGAffineTransform.identity
        })
        
        
        
    }
    
    func cameraNotAvailable() {
        topView.flashButton.isHidden = true
        topView.rotateCamera.isHidden = true
        bottomContainer.pickerButton.isEnabled = false
    }
    
    // MARK: - Rotation
    
    open override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .portrait
    }
    
    public func handleRotation(_ note: Notification) {
        let rotate = Helper.rotationTransform()
        
        UIView.animate(withDuration: 0.25, animations: {
            // Update by mbecker: Remove self.bottomContainer.stackView form array
            [self.topView.rotateCamera, self.bottomContainer.pickerButton,
             self.cancelButton, self.doneButton].forEach {
                $0.transform = rotate
            }
            
            self.galleryView.collectionViewLayout.invalidateLayout()
            
            let translate: CGAffineTransform
            if [UIDeviceOrientation.landscapeLeft, UIDeviceOrientation.landscapeRight]
                .contains(UIDevice.current.orientation) {
                translate = CGAffineTransform(translationX: -20, y: 15)
            } else {
                translate = CGAffineTransform.identity
            }
            
            self.topView.flashButton.transform = rotate.concatenating(translate)
        })
    }
    
    func showCrop(images: [UIImage]){
        let cropViewController = TOCropViewController(image: images[0])
        cropViewController.delegate = self
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.resetAspectRatioEnabled = false
        cropViewController.aspectRatioPickerButtonHidden = true // Buton to select different ratios
        cropViewController.customAspectRatio = CGSize(width: 375, height: 300)
        cropViewController.rotateButtonsHidden = false
        cropViewController.rotateClockwiseButtonHidden = false
        
        self.navigationController?.pushViewController(cropViewController, animated: false)
    }
}

// MARK: - TopView delegate methods

extension ImagePickerController: TopViewDelegate {
    
    func flashButtonDidPress(_ title: String) {
        cameraController.flashCamera(title)
    }
    
    func rotateDeviceDidPress() {
        cameraController.rotateCamera()
    }
}

// MARK: - Pan gesture handler

extension ImagePickerController: ImageGalleryPanGestureDelegate {
    
    func panGestureDidStart() {
        guard let collectionSize = galleryView.collectionSize else { return }
        
        initialFrame = galleryView.frame
        initialContentOffset = galleryView.collectionView.contentOffset
        if let contentOffset = initialContentOffset { numberOfCells = Int(contentOffset.x / collectionSize.width) }
    }
    
    func panGestureRecognizerHandler(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        
        if gesture.location(in: view).y > galleryView.frame.origin.y - 25 {
            gesture.state == .began ? panGestureDidStart() : panGestureDidChange(translation)
        }
        
        if gesture.state == .ended {
            panGestureDidEnd(translation, velocity: velocity)
        }
    }
    
    func panGestureDidChange(_ translation: CGPoint) {
        guard let initialFrame = initialFrame else { return }
        
        let galleryHeight = initialFrame.height - translation.y
        
        if galleryHeight >= GestureConstants.maximumHeight { return }
        
        if galleryHeight <= ImageGalleryView.Dimensions.galleryBarHeight {
            updateGalleryViewFrames(ImageGalleryView.Dimensions.galleryBarHeight)
            
        } else if galleryHeight >= GestureConstants.minimumHeight {
            
            let scale = (galleryHeight - ImageGalleryView.Dimensions.galleryBarHeight) / (GestureConstants.minimumHeight - ImageGalleryView.Dimensions.galleryBarHeight)
            galleryView.collectionView.transform = CGAffineTransform(scaleX: scale, y: scale)
            galleryView.frame.origin.y = initialFrame.origin.y + translation.y
            galleryView.frame.size.height = initialFrame.height - translation.y
            
            let value = view.frame.width * (scale - 1) / scale
            galleryView.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right:  value)
            
        } else {
            
            galleryView.frame.origin.y = initialFrame.origin.y + translation.y
            galleryView.frame.size.height = initialFrame.height - translation.y
        }
        
        galleryView.updateNoImagesLabel()
    }
    
    func panGestureDidEnd(_ translation: CGPoint, velocity: CGPoint) {
        guard let initialFrame = initialFrame else { return }
        
        let galleryHeight = initialFrame.height - translation.y
        
        if galleryView.frame.height < GestureConstants.minimumHeight && velocity.y < 0 {
            showGalleryView()
        } else if velocity.y < -GestureConstants.velocity {
            expandGalleryView()
        } else if velocity.y > GestureConstants.velocity || galleryHeight < GestureConstants.minimumHeight {
            collapseGalleryView(nil)
        }
    }
    
}

extension ImagePickerController: TOCropViewControllerDelegate {
    
    
    @objc(cropViewController:original:didCropToImage:withRect:angle:) public func cropViewController(_ cropViewController: TOCropViewController, original originalImage: UIImage, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        let formViewController = FormViewController(originalImage: originalImage, resizedImage: image, location: self.locationManager.latestLocation?.coordinate)
        formViewController.delegate = self
        self.navigationController?.pushViewController(formViewController, animated: false)
    }
    
}

extension ImagePickerController : FormViewControllerDelegate {
    public func formViewControllerDone(originalImage: UIImage, resizedImage: UIImage, type: whatTypes, name: String?, items: [String], position: CLLocationCoordinate2D) {
        self.delegate?.doneButtonDidPress(self, originalImages: [originalImage], resizedImages: [resizedImage], types: [type], names: [name], items: [0: items], positions: [position])
    }
}


