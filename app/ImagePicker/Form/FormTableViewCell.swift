//
//  FormTableViewCell.swift
//  ImagePicker
//
//  Created by Mats Becker on 10/25/16.
//  Copyright © 2016 Hyper Interaktiv AS. All rights reserved.
//

import UIKit

class FormTableViewCell: UITableViewCell {
  
  let headingLabel = UILabel()
  let textField = UITextField()
  let placeholder = "Add name"
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:)")
  }
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    self.headingLabel.tintColor = UIColor(red:0.24, green:0.24, blue:0.24, alpha:1.00) // Baltic sea
    self.headingLabel.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(self.headingLabel)
    
    self.textField.delegate = self
    self.textField.clearButtonMode = .always
    
    self.textField.tintColor = UIColor(red:0.09, green:0.59, blue:0.48, alpha:1.00) // Mint Dark
    self.textField.textAlignment = .right
    self.textField.attributedText = NSAttributedString(
      string: placeholder,
      attributes: [
        NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 23)!,
        NSForegroundColorAttributeName: UIColor(red:0.09, green:0.59, blue:0.48, alpha:1.00), // Mint Dark
        NSKernAttributeName: 0.6,
        ])
    self.textField.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(self.textField)
    
    addDoneButtonOnKeyboard()
    
    
    let constraintLeftHeadingLabel = NSLayoutConstraint(item: self.headingLabel, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 20)
    let constraintCenterYHeadingLabel = NSLayoutConstraint(item: self.headingLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
    
    self.addConstraint(constraintLeftHeadingLabel)
    self.addConstraint(constraintCenterYHeadingLabel)
    
    let constraintWidtTextField = NSLayoutConstraint(item: self.textField, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant:  -40-100)
    let constraintRighTextField = NSLayoutConstraint(item: self.textField, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -20)
    let constraintCenterYTextField = NSLayoutConstraint(item: self.textField, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
    let constrainTHeightTextField = NSLayoutConstraint(item: self.textField, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0)
    
    self.addConstraint(constraintWidtTextField)
    self.addConstraint(constraintRighTextField)
    self.addConstraint(constraintCenterYTextField)
    self.addConstraint(constrainTHeightTextField)
    
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.headingLabel.attributedText = NSAttributedString(
      string: self.headingLabel.text!,
      attributes: [
        NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 23)!,
        NSForegroundColorAttributeName: UIColor(red:0.24, green:0.24, blue:0.24, alpha:1.00), // Baltic sea
        NSKernAttributeName: 0.6,
        ])
    
    self.textField.attributedText = NSAttributedString(
      string: self.textField.text!,
      attributes: [
        NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 23)!,
        NSForegroundColorAttributeName: UIColor(red:0.09, green:0.59, blue:0.48, alpha:1.00), // Mint Dark
        NSKernAttributeName: 0.6,
        ])
    
  }
  
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
  func addDoneButtonOnKeyboard() {
    let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 50))
    doneToolbar.barStyle       = UIBarStyle.default
    doneToolbar.barTintColor    = UIColor.white
    let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
    let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(self.doneButtonAction))
    
    var items = [UIBarButtonItem]()
    items.append(flexSpace)
    items.append(done)
    
    doneToolbar.items = items
    doneToolbar.sizeToFit()
    
    self.textField.inputAccessoryView = doneToolbar
  }
  
  func doneButtonAction() {
    self.textField.resignFirstResponder()
  }
  
  /**
   * Called when the user click on the view (outside the UITextField).
   */
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.endEditing(true)
  }
  
}

extension FormTableViewCell : UITextFieldDelegate {
  /**
   * 1.) Before becoming the first responder, the text field calls its delegate’s textFieldShouldBeginEditing(_:) method.
   *     Use that method to allow or prevent the editing of the text field’s contents.
   */
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    if self.textField.text == self.placeholder {
        self.textField.text = ""
    }
    return true
  }
  
  /**
   * 5.) Before resigning as first responder, the text field calls its delegate’s textFieldShouldEndEditing(_:) method.
   *     Use that method to validate the current text.
   */
  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    self.textField.resignFirstResponder()
    return true
  }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.characters.count == 0 {
            textField.text = placeholder
        }
    }
  
  
}

/**
 * FormTableLabelCell
 */
class FormTableLabelCell: UITableViewCell {
  
  let headingLabel = UILabel()
  let detailLabel = UILabel()
  let descriptionLabel = UILabel()
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:)")
  }
  
  init(style: UITableViewCellStyle, reuseIdentifier: String?, heading: String, detail: String, description: String){
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.headingLabel.tintColor = UIColor(red:0.24, green:0.24, blue:0.24, alpha:1.00) // Baltic sea
    self.headingLabel.translatesAutoresizingMaskIntoConstraints = false
    self.headingLabel.text = heading
    self.addSubview(self.headingLabel)
    
    self.detailLabel.tintColor = UIColor(red:0.09, green:0.59, blue:0.48, alpha:1.00) // Mint Dark
    self.detailLabel.attributedText = NSAttributedString(
      string: detail,
      attributes: [
        NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 23)!,
        NSForegroundColorAttributeName: UIColor(red:0.09, green:0.59, blue:0.48, alpha:1.00), // Mint Dark
        NSKernAttributeName: 0.6,
        ])
    self.detailLabel.textAlignment = .right
    self.detailLabel.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(self.detailLabel)
    
    
    self.descriptionLabel.attributedText = NSAttributedString(
      string: description,
      attributes: [
        NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 14)!,
        NSForegroundColorAttributeName: UIColor(red:0.24, green:0.24, blue:0.24, alpha:1.00), // Baltic sea
        NSKernAttributeName: 0.6,
        ])
    self.descriptionLabel.textAlignment = .right
    self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(self.descriptionLabel)
    
    let constraintLeftHeadingLabel = NSLayoutConstraint(item: self.headingLabel, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 20)
    let constraintCenterYHeadingLabel = NSLayoutConstraint(item: self.headingLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
    
    self.addConstraint(constraintLeftHeadingLabel)
    self.addConstraint(constraintCenterYHeadingLabel)
    
    let constraintWidtTextField = NSLayoutConstraint(item: self.detailLabel, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant:  -40-100)
    let constraintRighTextField = NSLayoutConstraint(item: self.detailLabel, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -20)
    let constraintCenterYTextField = NSLayoutConstraint(item: self.detailLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
    let constrainTHeightTextField = NSLayoutConstraint(item: self.detailLabel, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0)
    
    self.addConstraint(constraintWidtTextField)
    self.addConstraint(constraintRighTextField)
    self.addConstraint(constraintCenterYTextField)
    self.addConstraint(constrainTHeightTextField)
    
    let constraintWidtDesc = NSLayoutConstraint(item: self.descriptionLabel, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant:  -40-100)
    let constraintRighDesc = NSLayoutConstraint(item: self.descriptionLabel, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -20)
    let constraintCenterYDesc = NSLayoutConstraint(item: self.descriptionLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 20)
    let constrainTHeightDesc = NSLayoutConstraint(item: self.descriptionLabel, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0)
    
    self.addConstraint(constraintWidtDesc)
    self.addConstraint(constraintRighDesc)
    self.addConstraint(constraintCenterYDesc)
    self.addConstraint(constrainTHeightDesc)

  }
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    self.headingLabel.attributedText = NSAttributedString(
      string: self.headingLabel.text!,
      attributes: [
        NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 23)!,
        NSForegroundColorAttributeName: UIColor(red:0.24, green:0.24, blue:0.24, alpha:1.00), // Baltic sea
        NSKernAttributeName: 0.6,
        ])
    
    self.detailLabel.attributedText = NSAttributedString(
      string: self.detailLabel.text!,
      attributes: [
        NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 23)!,
        NSForegroundColorAttributeName: UIColor(red:0.09, green:0.59, blue:0.48, alpha:1.00), // Mint Dark
        NSKernAttributeName: 0.6,
        ])
    
    self.descriptionLabel.attributedText = NSAttributedString(
      string: self.descriptionLabel.text!,
      attributes: [
        NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 14)!,
        NSForegroundColorAttributeName: UIColor(red:0.24, green:0.24, blue:0.24, alpha:1.00), // Baltic sea
        NSKernAttributeName: 0.6,
        ])
  }
    
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
}


/**
 * FormTableImageCell
 */
class FormTableImageCell: UITableViewCell {
    
    let spotImageView = UIImageView()
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    init(style: UITableViewCellStyle, reuseIdentifier: String?, image: UIImage){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.spotImageView.image = image.resizedImageWithinRect(rectSize: CGSize(width: 375, height: 300))
        self.spotImageView.contentMode = .redraw
        self.spotImageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.spotImageView)
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let top = NSLayoutConstraint(item: self.spotImageView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 10)
        let width = NSLayoutConstraint(item: self.spotImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 327.0)
        let centerX = NSLayoutConstraint(item: self.spotImageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        let centerY = NSLayoutConstraint(item: self.spotImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        
        self.addConstraint(top)
        self.addConstraint(centerX)
        self.addConstraint(centerY)
        self.addConstraint(width)
        print("IMAGE HEIGHT - \(self.frame)")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

