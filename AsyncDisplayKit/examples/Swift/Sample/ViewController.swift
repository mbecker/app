//
//  ViewController.swift
//  Sample
//
//  Copyright (c) 2014-present, Facebook, Inc.  All rights reserved.
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree. An additional grant
//  of patent rights can be found in the PATENTS file in the same directory.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
//  FACEBOOK BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
//  ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit
import AsyncDisplayKit
import Firebase
import FirebaseDatabase
import Kingfisher
import LayoutKit

final class ViewController: ASViewController<ASDisplayNode>, ASTableDataSource, ASTableDelegate {
  
  var sections : [Section] = [Section]()
  
  var tableNode: ASTableNode {
    return node as! ASTableNode
  }
  
  // MARK: Firebase init
  var ref: FIRDatabaseReference!
  var refs: [FIRDatabaseReference] = [FIRDatabaseReference]()


  init() {
    super.init(node: ASTableNode(style: UITableViewStyle.grouped))
    tableNode.view.asyncDataSource = self
    tableNode.view.asyncDelegate = self
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // navigation bar
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(didTapAdd))
    
    navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Clear Cache", style: .plain, target: self, action: #selector(didTapClearCache))
    
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
      return FirebaseCell(section: self.sections[indexPath.section], sectionSize: CGSize(width: self.view.frame.width, height: ((self.view.frame.width - 40) / 1.61803398875) + 40 ))
    }
  }

  func numberOfSections(in tableView: UITableView) -> Int {
    return self.sections.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(_ tableView: ASTableView, constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
    return ASSizeRangeMake(CGSize(width: 0, height: 0), CGSize(width: self.view.frame.width, height: ((self.view.frame.width - 40) / 1.61803398875) + 40 ))
  }
  
  
  // MARK: - Table section header & footer
  
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = UIView()
    headerView.frame = CGRect(x: 0, y: 0, width: self.tableNode.view.bounds.size.width, height: 40)
    headerView.backgroundColor = UIColor.white
    headerView.translatesAutoresizingMaskIntoConstraints = true
//    let headerLabel   = UILabel()
//    headerLabel.font  = UIFont(name: "Calibre-Light", size: 24)
//    headerLabel.text  = self.sections[section].name
//    headerLabel.numberOfLines = 1
//    headerLabel.translatesAutoresizingMaskIntoConstraints = false
//    headerView.addSubview(headerLabel)
//    
//    let verticalConstraint = NSLayoutConstraint(item: headerLabel, attribute: .centerY, relatedBy: .equal, toItem: headerView, attribute: .centerY, multiplier: 1, constant: 0)
//    let verticalConstraintH = NSLayoutConstraint(item: headerLabel, attribute: .left, relatedBy: .equal, toItem: headerView, attribute: .left, multiplier: 1, constant: 20)
////
////    
////    NSLayoutConstraint.activate([verticalConstraint])
//    headerView.addConstraint(verticalConstraint)
//    headerView.addConstraint(verticalConstraintH)
    
    let headerSubView = SizeLayout<UIView>(height: 40, minWidth: 16, maxWidth: 16, alignment: nil, flexibility: nil, viewReuseId: nil, sublayout: nil, config: { view in
      view.backgroundColor = UIColor.clear
    })
    
    let flex = Flexibility(horizontal: Flexibility.defaultFlex, vertical: Flexibility.defaultFlex)
    let headerLabel = LabelLayout(text: self.sections[section].name, font: UIFont(name: "Calibre-Light", size: 24)!, numberOfLines: 1, alignment: .center, flexibility: flex, viewReuseId: nil, config: nil)
    
    let stack = StackLayout(
      axis: .horizontal,
      spacing: 0,
      sublayouts: [headerSubView, headerLabel])
    
    let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    let helloWorld = InsetLayout(insets: insets, sublayout: stack)
    helloWorld.arrangement().makeViews(in: headerView)
    
    return headerView
    
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 40
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let headerView = UIView()
    headerView.frame = CGRect(x: 0, y: 0, width: self.tableNode.view.bounds.size.width, height: 16)
    headerView.backgroundColor = UIColor.white
    return headerView
  }
  
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 16
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
