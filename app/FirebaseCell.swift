//
//  FirebaseCell.swift
//  Sample
//
//  Created by Mats Becker on 10/3/16.
//  Copyright © 2016 Facebook. All rights reserved.
//
import UIKit
import AsyncDisplayKit
import FirebaseDatabase
import FirebaseStorage

class FirebaseCell: ASCellNode, ASCollectionDelegate, ASCollectionDataSource {
  
  var collectionNode: ASCollectionNode?
  
  var section: Section!
  var ref: FIRDatabaseReference = FIRDatabaseReference()
  var storage: FIRStorage!
  var sectionSize: CGSize
  var itemSize: CGSize
  
  var items: [SectionData] = [SectionData]()
  
  
  init(section: Section, sectionSize: CGSize) {
    self.section  = section
    self.sectionSize = sectionSize
    self.itemSize = CGSize(width: sectionSize.width - 48, height: sectionSize.height)
    ref           = FIRDatabase.database().reference()
    storage       = FIRStorage.storage()
    
    super.init()
    
    // Disabel tabel cell selection
    self.selectionStyle = UITableViewCellSelectionStyle.none
  }
  
  
  override func didLoad() {
    super.didLoad()
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 12
    layout.sectionInset = airBnbInset
    layout.itemSize = self.itemSize
    layout.estimatedItemSize = self.itemSize
    
    
    
    // Ccollection view node: ASCollectionDelegate, ASCollectionDataSource
    self.collectionNode = ASCollectionNode(frame: CGRect.zero, collectionViewLayout: layout)
    self.collectionNode!.frame = self.frame
    self.collectionNode!.view.asyncDelegate = self
    self.collectionNode!.view.asyncDataSource = self
    self.collectionNode!.view.showsHorizontalScrollIndicator = false
    self.collectionNode!.view.backgroundColor = UIColor.white
    self.collectionNode!.borderWidth = 0.0
    
    self.addSubnode(collectionNode!)
    
    
    // Listen for added snapshots
    self.ref.child(self.section.path).observe(.childAdded, with: { (snapshot) -> Void in
      let item = SectionData(snapshot: snapshot)
      OperationQueue.main.addOperation({
        self.items.insert(item, at: 0)
        let indexPath = IndexPath(item: 0, section: 0)
        self.collectionNode?.view.insertItems(at: [indexPath])
        self.collectionNode?.view.reloadItems(at: [indexPath])
      })
    })
    
    // Listen for removed snapshots
    self.ref.child((self.section?.path)!).observe(.childRemoved, with: { (snapshot) -> Void in
      let item = SectionData(snapshot: snapshot)
      if let i = self.items.index(where: {$0.key == item.key}) {
        self.items.remove(at: i)
        let indexPath = IndexPath(item: i, section: 0)
        self.collectionNode?.view.deleteItems(at: [indexPath])
      } else {
        print("FIREBASE SDK :: Remove item in array - No element found for: \(item.name)")
      }
    })
  }
  
  override func didEnterPreloadState() {
    
  }
  
  func viewFrame() -> CGRect {
    return CGRect(x: 0, y: 0, width: self.sectionSize.width, height: self.sectionSize.height)
  }
  
  override func calculateLayoutThatFits(_ constrainedSize: ASSizeRange) -> ASLayout {
    // FIX: sectionSize.height + 20 to show shadow of item
    return ASLayout(layoutElement: self, size: CGSize(width: self.sectionSize.width, height: self.sectionSize.height))
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.items.count
  }
  
  func collectionView(_ collectionView: ASCollectionView, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
    return {
//      let node = ASTextCellNode()
//      node.backgroundColor = UIColor(red:0.00, green:0.62, blue:0.56, alpha:1.00)
//      node.text = String(format: "%@", self.appData[(indexPath as NSIndexPath).item].name)
//      let imageNode = ASDisplayNode(viewBlock: {
//        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
//        imageView.image = UIImage(named: "Zebra1")
//        return imageView
//      })
//      let cache = KingfisherCache.sharedManager
//      let networkImageNode = ASNetworkImageNode(cache: cache, downloader: cache)
////      let networkImageNode = ASNetworkImageNode()
//      networkImageNode.frame = CGRect(x: 0, y: 0, width: self.itemSize.width, height: self.itemSize.height)
//      networkImageNode.preferredFrameSize = CGSize(width: 100, height: 100)
//      networkImageNode.shouldRenderProgressImages = true
//      networkImageNode.isLayerBacked = false
//      networkImageNode.placeholderColor = UIColor.yellow
//      networkImageNode.defaultImage = UIImage(named: "imageBackground")
//      
//      let item = self.items[indexPath.item]
//      
//      if let imageURL: String = item.url as String!, imageURL.characters.count > 0 {
//        let imgRef = self.storage.reference(forURL: imageURL)
//        print("················ \(Date().iso8601) - Start with storage url")
//        imgRef.downloadURL(completion: { (storageURL, error) -> Void in
//          if error != nil {
//            print("················ \(Date().iso8601) - download url error")
//            networkImageNode.url = URL(string: "https://dummyimage.com/345x261/000/fff.png&text=FirebaseError")
//          } else {
//            print("················ \(Date().iso8601) - storage url created")
//            networkImageNode.url = storageURL
//          }
//        })
//      } else {
//        print("················ \(Date().iso8601) - no image url")
//        networkImageNode.url = URL(string: "https://dummyimage.com/345x261/000/fff.png&text=NoImage")
//      }
//      
//      let attributedString = NSMutableAttributedString(string: item.name + " 😸")
//      
//      attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: "HelveticaNeue-Light", size: 16.0)!, range: NSRange(location: 0, length: item.name.characters.count))
//      
//      let textNode = ASTextNode()
//      textNode.attributedString = attributedString
//      textNode.frame = CGRect(x: 0, y: 25, width: 100, height: 50)
//
//      
//      
//      let nodeBlock = ASCellNode()
//      nodeBlock.frame = CGRect(x: 0, y: 0, width: self.itemSize.width, height: self.itemSize.height)
//      nodeBlock.addSubnode(networkImageNode)
//      nodeBlock.addSubnode(textNode)
//      
//      return nodeBlock
      let node = SpotASCellNode(cellData: self.items[indexPath.item], cellSize: self.itemSize)
      node.frame = CGRect(x: 0, y: 0, width: self.itemSize.width, height: self.itemSize.height)
      node.backgroundColor = UIColor.white
      return node
    }
  }
  
  func collectionView(_ collectionView: ASCollectionView, constrainedSizeForNodeAt indexPath: IndexPath) -> ASSizeRange {
    return ASSizeRangeMake(itemSize, itemSize)
    
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let item = self.items[indexPath.item]
    DatabaseModels().deleteItem(ref: item.ref)
  }
  
  
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    let pageWidth:CGFloat = scrollView.frame.width - 40 + 4
    
    let currentOffset:CGFloat = scrollView.contentOffset.x;
    let targetOffset:CGFloat = targetContentOffset.pointee.x
    var newTargetOffset:CGFloat = 0;
    
    if targetOffset > currentOffset {
      newTargetOffset = ceil(currentOffset / pageWidth) * pageWidth;
    } else {
      newTargetOffset = floor(currentOffset / pageWidth) * pageWidth;
    }
    
    if newTargetOffset < 0 {
      newTargetOffset = 0
    } else if newTargetOffset > scrollView.contentSize.width {
      newTargetOffset = scrollView.contentSize.width;
    }
    
    targetContentOffset.pointee.x = currentOffset
    
    scrollView.setContentOffset(CGPoint(x: newTargetOffset, y: 0), animated: true)
  }
  
  
}

extension Date {
  struct Formatter {
    static let iso8601: DateFormatter = {
      let formatter = DateFormatter()
      formatter.calendar = Calendar(identifier: .iso8601)
      formatter.locale = Locale(identifier: "en_US_POSIX")
      formatter.timeZone = TimeZone(secondsFromGMT: 0)
      formatter.dateFormat = "HH:mm:ss.SSS"
      return formatter
    }()
  }
  var iso8601: String {
    return Formatter.iso8601.string(from: self)
  }
}


extension String {
  var dateFromISO8601: Date? {
    return Date.Formatter.iso8601.date(from: self)
  }
}
