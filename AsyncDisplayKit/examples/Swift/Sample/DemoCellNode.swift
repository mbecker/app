import UIKit
import AsyncDisplayKit

class DemoCellNode: ASCellNode {
  
  var loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
  var imageNode = ASNetworkImageNode()
  var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
  var captionContainerNode = ASDisplayNode()
  var captionLabelNode = ASTextNode()
  
  let glacierScenic: GlacierScenic
  var nodeSize: CGSize {
    let spacing: CGFloat = 1
    let screenWidth = UIScreen.main.bounds.width
    let itemWidth = floor((screenWidth / 2) - (spacing / 2))
    let itemHeight = floor((screenWidth / 3) - (spacing / 2))
    return CGSize(width: itemWidth, height: itemHeight)
  }
  
  init(glacierScenic: GlacierScenic) {
    self.glacierScenic = glacierScenic
    super.init()
    configure()
  }
  
  func configure() {
    backgroundColor = UIColor.black
    configureLoadingIndicator()
//    configureImageNode()
//    configureCaptionNodes()
  }
  
  func configureLoadingIndicator() {
    loadingIndicator.center = loadingIndicatorCenter()
    view.addSubview(loadingIndicator)
    loadingIndicator.startAnimating()
    view.addSubview(loadingIndicator)
  }
  
  func loadingIndicatorCenter() -> CGPoint {
    let centerX = nodeSize.width / 2
    let centerY = nodeSize.height / 2 - captionContainerFrame().height / 2
    return CGPoint(x: centerX, y: centerY)
  }
  
  func configureImageNode() {
    imageNode = ASNetworkImageNode()
    imageNode.frame = viewFrame()
    imageNode.url = URL(string: glacierScenic.photoURLString)
    imageNode.isLayerBacked = true
    imageNode.delegate = self
    addSubnode(imageNode)
  }
  
  func configureCaptionNodes() {
    configureCaptionBlurView()
    configureCaptionContainerNode()
    configureCaptionLabelNode()
  }
  
  func configureCaptionBlurView() {
    blurView.frame = captionContainerFrame()
    view.addSubview(blurView)
  }
  
  func configureCaptionContainerNode() {
    captionContainerNode.frame = captionContainerFrame()
    captionContainerNode.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    captionContainerNode.isLayerBacked = true
    addSubnode(captionContainerNode)
  }
  
  func configureCaptionLabelNode() {
    
    captionLabelNode.attributedText = NSAttributedString(string: glacierScenic.name)
    
    let constrainedSize = CGSize(width: nodeSize.width, height: CGFloat.greatestFiniteMagnitude)
    let labelNodeHeight: CGFloat = captionLabelNode.attributedString!.boundingRect(with: constrainedSize, options: .usesFontLeading, context: nil).height
    let labelNodeYValue = captionContainerFrame().height / 2 - labelNodeHeight / 2
    captionLabelNode.frame = CGRect(x: 0, y: labelNodeYValue, width: nodeSize.width, height: labelNodeHeight)
    captionContainerNode.layer.addSublayer(captionLabelNode.layer)
  }
  
  func captionContainerFrame() -> CGRect {
    let containerHeight: CGFloat = 35
    return CGRect(x: 0, y: nodeSize.height - containerHeight, width: nodeSize.width, height: containerHeight)
  }
  
  func viewFrame() -> CGRect {
    return CGRect(x: 0, y: 0, width: nodeSize.width, height: nodeSize.height)
  }
  
  override func calculateLayoutThatFits(_ constrainedSize: ASSizeRange) -> ASLayout {
    return ASLayout(layoutElement: self, size: nodeSize)
  }
  
}

extension DemoCellNode: ASNetworkImageNodeDelegate {
  
  func imageNode(_ imageNode: ASNetworkImageNode, didLoad image: UIImage) {
    loadingIndicator.stopAnimating()
  }
  
}
