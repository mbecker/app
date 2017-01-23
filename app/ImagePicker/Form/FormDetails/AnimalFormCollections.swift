//
//  AnimalFormViewController.swift
//  ImagePicker
//
//  Created by Mats Becker on 10/27/16.
//  Copyright © 2016 Hyper Interaktiv AS. All rights reserved.
//

import UIKit

protocol AnimalFormCollectionDelegate: class {
    
    func saveItems(index: [IndexPath], items: [String])
}

class AnimalFormCollections: UIViewController {
    var navigationBarSnapshot: UIView!
    var navigationBarHeight: CGFloat = 0
    let collectionViewLayout = UICollectionViewFlowLayout()
    var collectionView: UICollectionView!
    let kCellReuse : String = "AnimalCell"
    let kHeaderReuse = "HeaderCell"
    weak var delegate: AnimalFormCollectionDelegate?
    
    let data = [
        "Alligator" :   "Alligator-66.png",
        "Bat"       :   "Bat-66.png",
        "Bear"      :   "Bear-66.png",
        "Chicken"   :   "Chicken-66.png",
        "Deer"      :   "Deer-66.png",
        "Dinosaur"  :   "Dinosaur-66.png",
        "Dolphin"   :   "Dolphin-66.png",
        "Duck"      :   "Duck-66.png",
        "Elephant"  :   "Elephant_64.png",
        "Faclon"    :   "Falcon-66.png",
        "Flamingo"  :   "Flamingo-66.png",
        "Forg"      :   "Frog-66.png",
        "Giraffe"   :   "Giraffe-66.png",
        "Gorilla"   :   "Gorilla-66.png",
        "Hummingbird" : "Hummingbird-66.png",
        "Ladybird"  :   "Ladybird-66.png",
        "Lion"      :   "Lion-66.png",
        "Owl"       :   "Owl-66.png",
        "Pelican"   :   "Pelican-66.png",
        "Pinguin"   :   "Pinguin-66.png",
        "Rhinoceros":   "Rhinoceros-66.png",
        "Rabbit"    :   "Running Rabbit-66.png",
        "Stork"     :   "Stork-66.png",
        "Turtle"    :   "Turtle-66.png",
        "Bird"      :   "Twitter-66.png",
        "Tiger"     :   "Year of Tiger-66.png",
        "Bufallo"   :   "buffalo.png",
        "Butterlfy" :   "butterfly-with-a-heart-on-frontal-wing-on-side-view.png",
        "Goat"      :   "goat.png",
        "Sheep"     :   "sheep.png",
        "Snake"     :   "snake66.png",
        "Unicorn"   :   "unicorn.png",
        "Creek"     :   "Creek-66.png",
        "Forest"    :   "Forest-66.png",
        "Fountain"  :   "Fountain-66.png",
        "Park Bench":   "Park Bench-66.png",
        "Parking"   :   "Parking-66.png",
        "Treehouse" :   "Treehouse-66.png",
        "Hiking"    :   "backpacker.png",
        "Bicyle Parking"    :   "bicycle-parking.png",
        "Campfire"  :   "bonfire.png",
        "Church"    :   "church.png",
        "Cutlery"   :   "cutlery.png",
        "Panels"    :   "panel.png",
        "Tent"      :   "tent.png"
    ]
    
    let animalsData = [
        "Alligator",
        "Bat",
        "Bear",
        "Chicken",
        "Deer",
        "Dinosaur",
        "Dolphin",
        "Duck",
        "Elephant",
        "Faclon",
        "Flamingo",
        "Forg",
        "Giraffe",
        "Gorilla",
        "Hummingbird",
        "Ladybird",
        "Lion",
        "Owl",
        "Pelican",
        "Pinguin",
        "Rhinoceros",
        "Rabbit",
        "Stork",
        "Turtle",
        "Bird",
        "Tiger",
        "Bufallo",
        "Butterlfy",
        "Goat",
        "Sheep",
        "Snake",
        "Unicorn"
    ]
    
    let attractionsData = [
        "Creek",
        "Forest",
        "Fountain",
        "Park Bench",
        "Parking",
        "Treehouse",
        "Hiking",
        "Bicyle Parking",
        "Campfire",
        "Church",
        "Cutlery",
        "Panels",
        "Tent"
    ]
    
    let collectionViewData : [String]
    
    let navBarTitle: String
    var selectedCells: [IndexPath]
    
    
    init(title: String, type: whatTypes, selectedCells: [IndexPath]) {
        self.navBarTitle = title
        
        switch type {
        case .Animal:
            self.collectionViewData = self.animalsData
            break
        case .Attraction:
            self.collectionViewData = self.attractionsData
            break
        default:
            self.collectionViewData = self.animalsData
        }
        
        self.selectedCells = selectedCells
        
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red:0.10, green:0.71, blue:0.57, alpha:1.00)
        
        /**
         * Buttons
         */
        let saveButton = SaveCancelButton(title: "Save", position: .Right, type: .Normal, showimage: true)
        let clearButton = SaveCancelButton(title: "Clear", position: .Left, type: .Normal, showimage: true)
        saveButton.addTarget(self, action: #selector(self.save), for: UIControlEvents.touchUpInside)
        clearButton.addTarget(self, action: #selector(self.clearItems), for: UIControlEvents.touchUpInside)
        
        
        /**
         * Collection View
         */
        
        self.collectionViewLayout.scrollDirection = .vertical
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.collectionViewLayout)
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.backgroundColor = UIColor.clear
        self.collectionView.isScrollEnabled = true
        self.collectionView.allowsMultipleSelection = true
        self.collectionView.register(AnimalCellHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: kHeaderReuse)
        self.collectionView.register(AnimalCell.self, forCellWithReuseIdentifier: kCellReuse)
        for index in self.selectedCells {
            self.collectionView.selectItem(at: index, animated: true, scrollPosition: .top)
        }
        
        self.view.addSubview(self.collectionView)
        self.view.addSubview(saveButton)
        self.view.addSubview(clearButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //    self.navigationController?.navigationBar.isHidden = false
        //    self.navigationController?.navigationBar.setBackgroundImage(UIImage.colorForNavBar(color: UIColor(red:0.10, green:0.71, blue:0.57, alpha:1.00)), for: .any, barMetrics: .default)
        
    }
    
    override func viewWillLayoutSubviews() {
        self.collectionView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        self.collectionView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 64, right: 0)
    }
    
    /**
     * Custom methods
     */
    
    func popBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func save(){
        let selectedCells = self.collectionView.indexPathsForSelectedItems
        var selectedItems = [String]()
        if (selectedCells?.count)! > 0 {
            for item in selectedCells! {
                let animal = self.collectionViewData[item.row]
                selectedItems.append(animal)
                print(animal)
            }
        }
        
        self.delegate?.saveItems(index: selectedCells!, items: selectedItems)
        
    }
    
    func clearItems(){
        for index in self.collectionView.indexPathsForSelectedItems! {
            self.collectionView.deselectItem(at: index, animated: true)
        }
        
        self.selectedCells = []
        
    }
    
    func showTitle(title: String){
        let navLabel = UILabel()
        navLabel.attributedText = NSAttributedString(
            string: title,
            attributes: [
                NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 23)!,
                NSForegroundColorAttributeName: UIColor.white,
                NSKernAttributeName: 0.6,
                ])
        navLabel.sizeToFit()
        self.navigationItem.titleView = navLabel
    }
    
}

// MARK: ExpandingTransitionPresentedViewController
extension AnimalFormCollections : ExpandingTransitionPresentedViewController {
    
    func expandingTransition(transition: ExpandingCellTransition, navigationBarSnapshot: UIView) {
        self.navigationBarSnapshot = navigationBarSnapshot
        self.navigationBarHeight = navigationBarSnapshot.frame.height
    }
    
}

// MARK: UICollectionViewDataSource
extension AnimalFormCollections : UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.collectionViewData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.kCellReuse, for: indexPath) as! AnimalCell
        
        DispatchQueue.global(qos: .userInitiated).async {
            let imageName = self.data[self.collectionViewData[indexPath.row]]
            let image = AssetManager.getImage(imageName!).withRenderingMode(.alwaysTemplate)
            // Bounce back to the main thread to update the UI
            DispatchQueue.main.async {
                cell.imageView.image = image
                if cell.isSelected {
                    cell.backgroundColor = UIColor.white
                    cell.imageView.tintColor = UIColor(red:0.24, green:0.24, blue:0.24, alpha:1.00)
                } else {
                    cell.backgroundColor = UIColor.clear
                    cell.imageView.tintColor = UIColor.white
                }
                
            }
            
        }
        cell.layer.borderColor = UIColor(red:0.97, green:0.97, blue:0.98, alpha:1.00).cgColor
        cell.layer.borderWidth = 2
        cell.layer.cornerRadius = 90 / 2
        
        return cell // Create UICollectionViewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 64)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: self.kHeaderReuse, for: indexPath) as! AnimalCellHeader
            view.backgroundColor = UIColor.clear
            view.delegate = self
            view.textLabel.attributedText = NSAttributedString(
                string: self.navBarTitle,
                attributes: [
                    NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 23)!,
                    NSForegroundColorAttributeName: UIColor.white,
                    NSKernAttributeName: 0.6,
                    ])
            
            return view
        }
        return UIView() as! UICollectionReusableView
    }
    
}

extension AnimalFormCollections : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // didSelect
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        //
    }
    
}

extension AnimalFormCollections : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 90, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let frame : CGRect = self.view.frame
        let margin = (frame.width - 90 * 3) / 6.0
        print(":: MARGIN -- \(margin)")
        return UIEdgeInsetsMake(10, margin, 10, margin) // margin between cells
    }
}

extension AnimalFormCollections : AnimalCellDelegate {
    func headerButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
}
