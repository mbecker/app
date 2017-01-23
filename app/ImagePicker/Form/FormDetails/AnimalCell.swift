//
//  AnimalCell
//  ImagePicker
//
//  Created by Mats Becker on 10/27/16.
//  Copyright © 2016 Hyper Interaktiv AS. All rights reserved.
//

import UIKit

class AnimalCell: UICollectionViewCell {
  
  var textLabel: UILabel!
  var imageView: UIImageView!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    imageView = UIImageView(frame: CGRect(x: self.frame.size.width / 2 - 60 / 2, y: self.frame.size.height / 2 - 60 / 2, width: 60, height: 60))
    imageView.center = self.center
    imageView.contentMode = UIViewContentMode.scaleAspectFit
    contentView.addSubview(imageView)
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    self.imageView.frame = CGRect(x: self.frame.size.width / 2 - 60 / 2, y: self.frame.size.height / 2 - 60 / 2, width: 60, height: 60)
  }
  
  override var isHighlighted: Bool {
    didSet {
      if isHighlighted {
        self.backgroundColor = UIColor.white
        self.imageView.tintColor = UIColor(red:0.24, green:0.24, blue:0.24, alpha:1.00)
      } else {
        self.backgroundColor = UIColor.clear
        self.imageView.tintColor = UIColor.white
      }
    }
  }
  
  override var isSelected: Bool {
    didSet {
      if isSelected {
        self.backgroundColor = UIColor.white
        self.imageView.tintColor = UIColor(red:0.24, green:0.24, blue:0.24, alpha:1.00)
      } else {
        self.backgroundColor = UIColor.clear
        self.imageView.tintColor = UIColor.white
      }
    }
  }
  
}
