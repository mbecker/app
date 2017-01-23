import UIKit

protocol BottomContainerViewDelegate: class {

  func pickerButtonDidPress()
    
}

open class BottomContainerView: UIView {

  struct Dimensions {
    static let height: CGFloat = 101
  }

  lazy var pickerButton: ButtonPicker = { [unowned self] in
    let pickerButton = ButtonPicker()
    pickerButton.setTitleColor(UIColor.white, for: UIControlState())
    pickerButton.delegate = self

    return pickerButton
    }()

  lazy var borderPickerButton: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.clear
    // Added by mbecker: Update border color to Configuration
    view.layer.borderColor = Configuration.pickerBackgroundColor.cgColor
    view.layer.borderWidth = ButtonPicker.Dimensions.borderWidth
    view.layer.cornerRadius = ButtonPicker.Dimensions.buttonBorderSize / 2

    return view
    }()


  lazy var topSeparator: UIView = { [unowned self] in
    let view = UIView()
    view.backgroundColor = Configuration.seperatorColor

    return view
    }()

  weak var delegate: BottomContainerViewDelegate?
  var pastCount = 0

  // MARK: Initializers

  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    [borderPickerButton, pickerButton, topSeparator].forEach {
      addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }

    backgroundColor = Configuration.backgroundColor


    setupConstraints()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Action methods

  fileprivate func animateImageView(_ imageView: UIImageView) {
    imageView.transform = CGAffineTransform(scaleX: 0, y: 0)

    UIView.animate(withDuration: 0.3, animations: {
      imageView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
      }, completion: { _ in
        UIView.animate(withDuration: 0.2, animations: { _ in
          imageView.transform = CGAffineTransform.identity
        }) 
    }) 
  }
}

// MARK: - ButtonPickerDelegate methods

extension BottomContainerView: ButtonPickerDelegate {

  func buttonDidPress() {
    delegate?.pickerButtonDidPress()
  }
}

