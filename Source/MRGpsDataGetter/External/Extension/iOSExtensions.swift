//
//  Extensions.swift
//  Prova2
//
//  Created by Marcello Catelli on 07/06/2017.
//  Copyright (c) 2017 Swift srl. All rights reserved.
//

import UIKit
import AVFoundation

public extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = "."
        formatter.numberStyle = .decimal
        return formatter
    }()
}

public extension Int {
    var formattedWithSeparator: String {
        return Formatter.withSeparator.string(for: self) ?? ""
    }
    func toUIColor() -> UIColor {
        return UIColor(
            red: CGFloat((self & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((self & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(self & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func toCGColor() -> CGColor {
        return self.toUIColor().cgColor
    }
}

public extension UInt {
    
    func toUIColor() -> UIColor {
        return UIColor(
            red: CGFloat((self & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((self & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(self & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func toCGColor() -> CGColor {
        return self.toUIColor().cgColor
    }
}

// CGFloat
public extension CGFloat {
    var degreesToRadians: CGFloat { return self * .pi / 180 }
    var radiansToDegrees: CGFloat { return self * 180 / .pi }
}

// Float
public extension Float {
    var degreesToRadians: Float { return self * .pi / 180 }
    var radiansToDegrees: Float { return self * 180 / .pi }
}

// NSObject
public extension NSObject{
    class var nameOfClass : String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    var nameOfClass : String {
        return NSStringFromClass(type(of: self)).components(separatedBy: ".").last!
    }
}

// FileManager
public extension FileManager {
    class func documentsDir() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }
    
    class func cachesDir() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }
}

extension StringProtocol {
    
    var firstUppercased: String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }
    
    var firstLowercased: String {
        guard let first = first else { return "" }
        return String(first).lowercased() + dropFirst()
    }
    
    var firstCapitalized: String {
        guard let first = first else { return "" }
        return String(first).capitalized + dropFirst()
    }
    
    func nsRange(from range: Range<Index>) -> NSRange {
        return .init(range, in: self)
    }
    
}

public extension String {
    
    func indexOf(target: String) -> Int? {
        let range = (self as NSString).range(of: target)
        guard Range.init(range) != nil else { return nil }
        return range.location
    }
    
    func toDate (format: String) -> Date? {
        return DateFormatter(format: format).date(from: self)
    }
    
    func toDateString (inputFormat: String, outputFormat:String) -> String? {
        if let date = toDate(format: inputFormat) {
            return DateFormatter(format: outputFormat).string(from: date)
        }
        return nil
    }
    
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return boundingBox.height
    }
    
    func slicingFirstCharter(length: Int) -> String {
        if length <= 0 {
            return  self
        } else if let to = self.index(self.startIndex, offsetBy: length, limitedBy: self.endIndex) {
            return String(self[to...])
        } else {
            return ""
        }
    }
    
}

public extension UIFont {
    
    static func system(weight: FontWeight, size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: self.weight(for: weight))
    }
    
    private static func weight(for weight: FontWeight) -> UIFont.Weight {
        switch weight {
            case .ultraLight: return UIFont.Weight.ultraLight
            case .light: return UIFont.Weight.light
            case .medium: return UIFont.Weight.medium
            case .regular: return UIFont.Weight.regular
            case .bold: return UIFont.Weight.bold
            case .demiBold: return UIFont.Weight.semibold
            case .heavy: return UIFont.Weight.heavy
            default: return UIFont.Weight.regular
        }
    }
    
    enum FontWeight {
        case regular
        case medium
        case light
        case ultraLight
        case heavy
        case bold
        case demiBold
        case none
    }
    
}

#if os(iOS)

// UITextField
public extension UITextField {
    func setIcon(_ image: UIImage){
        let iconView = UIImageView(frame: CGRect(x: 5, y: 5, width: 20, height: 20))
        //        iconView.backgroundColor = .green
        iconView.image = image
        
        let iconContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        //        iconContainerView.backgroundColor = .orange
        iconContainerView.addSubview(iconView)
        
        leftView = iconContainerView
        leftViewMode = .always
    }
}

// UILabel
public extension UILabel {
    
    func setLineSpacing(_ lineSpacing: CGFloat) {
        guard let labelText = self.text else { return }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        let attributedString:NSMutableAttributedString
        if let labelattributedText = self.attributedText {
            attributedString = NSMutableAttributedString(attributedString: labelattributedText)
        } else {
            attributedString = NSMutableAttributedString(string: labelText)
        }
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        self.attributedText = attributedString
    }
    
    func setShadowOffsetForLetters(blurRadius: CGFloat = 0, widthOffset: CGFloat = 0, heightOffset: CGFloat, opacity: CGFloat) {
        self.layer.shadowRadius = blurRadius
        self.layer.shadowOffset = CGSize(
            width: widthOffset,
            height: heightOffset
        )
        self.layer.shadowOpacity = Float(opacity)
    }
    
    func setShadowOffsetFactorForLetters(blurRadius: CGFloat = 0, widthOffsetFactor: CGFloat = 0, heightOffsetFactor: CGFloat, opacity: CGFloat) {
        let widthOffset = widthOffsetFactor * self.frame.width
        let heightOffset = heightOffsetFactor * self.frame.height
        self.setShadowOffsetForLetters(blurRadius: blurRadius, widthOffset: widthOffset, heightOffset: heightOffset, opacity: opacity)
    }
    
    func removeShadowForLetters() {
        self.setShadowOffsetForLetters(blurRadius: 0, widthOffset: 0, heightOffset: 0, opacity: 0)
    }
    
    func setCenterAlignment() {
        self.textAlignment = .center
        self.baselineAdjustment = .alignCenters
    }
    
    func setLettersSpacing(_ value: CGFloat) {
        if let textString = text {
            let attrs: [NSAttributedString.Key : Any] = [.kern: value]
            attributedText = NSAttributedString(string: textString, attributes: attrs)
        }
    }
    
    func setLineSpacing(_ lineSpacing: CGFloat = 0.0, lineHeightMultiple: CGFloat = 0.0) {
        
        guard let labelText = self.text else { return }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        
        let attributedString: NSMutableAttributedString
        if let labelattributedText = self.attributedText {
            attributedString = NSMutableAttributedString(attributedString: labelattributedText)
        } else {
            attributedString = NSMutableAttributedString(string: labelText)
        }
        
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        
        self.attributedText = attributedString
    }
    
    func setFormat(text: String, positions: [FormatPosition], font: UIFont, textColor: UIColor, backgroundColor: UIColor = .clear) {
        
        let title = NSMutableAttributedString.init(string: text)
        
        for position in positions {
            title.addAttributes(
                [
                    NSAttributedString.Key.backgroundColor : backgroundColor,
                    NSAttributedString.Key.foregroundColor : textColor,
                    NSAttributedString.Key.font : font
                ],
                range: NSRange.init(location: position.start, length: position.length)
            )
        }
        
        self.attributedText = title
    }
    
    struct FormatPosition {
        
        var start: Int
        var length: Int
    }
    
}

// UINavigationBar
public extension UINavigationBar {
    
    func addDropShadow(with color: UIColor = UIColor.black, opacity: Float = 0.75, offSet: CGSize = CGSize(width: -1, height: 1), radius: CGFloat = 1, scale: Bool = true, shouldRasterize: Bool = true) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offSet
        self.layer.shadowRadius = radius
    }
    
}

// UIViewController
public extension UIViewController{
    
    func isInPopover() -> Bool {
        guard UIDevice.current.userInterfaceIdiom == .pad else { return false }
        var checkingVC: UIViewController? = self
        repeat {
            if checkingVC?.modalPresentationStyle == .popover {
                return true
            }
            checkingVC = checkingVC?.parent
        } while checkingVC != nil
        return false
    }
    
    func present(_ viewControllerToPresent: UIViewController, completion: (() -> Swift.Void)? = nil) {
        self.present(viewControllerToPresent, animated: true, completion: completion)
    }
    
    @objc func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    var safeArea: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return self.view.safeAreaInsets
        } else {
            return UIEdgeInsets.zero
        }
    }
    
    var navigationBarHeight: CGFloat {
        return self.navigationController?.navigationBar.frame.height ?? 0
    }
    
    var navigationTitleColor: UIColor? {
        get {
            return (self.navigationController?.navigationBar.titleTextAttributes?[NSAttributedString.Key.foregroundColor] as? UIColor) ?? nil
        }
        set {
            let textAttributes: [NSAttributedString.Key: Any]? = [NSAttributedString.Key.foregroundColor: newValue ?? UIColor.black]
            self.navigationController?.navigationBar.titleTextAttributes = textAttributes
            if #available(iOS 11.0, *) {
                self.navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
            }
        }
    }
    
}

// UINavigationController
public extension UINavigationController {
    func hasViewController(ofKind kind: AnyClass) -> UIViewController? {
        return self.viewControllers.first(where: {$0.isKind(of: kind)})
    }
}

// CGRect
public extension CGRect {
    
    var minEdge: CGFloat {
        return min(width, height)
    }
    
    var bottomX: CGFloat {
        get { return self.origin.x + self.width }
        set { self.origin.x = newValue - self.width }
    }
    
    var bottomY: CGFloat {
        get { return self.origin.y + self.height }
        set { self.origin.y = newValue - self.height }
    }
    
    var minSide: CGFloat {
        return min(self.width, self.height)
    }
    
    mutating func set(width: CGFloat) {
        self = CGRect.init(x: self.origin.x, y: self.origin.y, width: width, height: self.height)
    }
    
    mutating func set(height: CGFloat) {
        self = CGRect.init(x: self.origin.x, y: self.origin.y, width: self.width, height: height)
    }
    
    mutating func set(width: CGFloat, height: CGFloat) {
        self = CGRect.init(x: self.origin.x, y: self.origin.y, width: width, height: height)
    }
}

// UIView
public extension UIView {
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func round() {
        self.layer.cornerRadius = self.frame.minSide / 2
    }
    
    func addAlignedConstrains() {
        translatesAutoresizingMaskIntoConstraints = false
        addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute.top)
        addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute.leading)
        addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute.trailing)
        addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute.bottom)
    }
    
    func addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute) {
        superview?.addConstraint(
            NSLayoutConstraint(
                item: self,
                attribute: attribute,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: superview,
                attribute: attribute,
                multiplier: 1,
                constant: 0
            )
        )
    }
    
    func addParallax(X horizontal:Float, Y vertical:Float) {
        
        let parallaxOnX = UIInterpolatingMotionEffect(keyPath: "center.x", type: UIInterpolatingMotionEffect.EffectType.tiltAlongHorizontalAxis)
        parallaxOnX.minimumRelativeValue = -horizontal
        parallaxOnX.maximumRelativeValue = horizontal
        
        let parallaxOnY = UIInterpolatingMotionEffect(keyPath: "center.y", type: UIInterpolatingMotionEffect.EffectType.tiltAlongVerticalAxis)
        parallaxOnY.minimumRelativeValue = -vertical
        parallaxOnY.maximumRelativeValue = vertical
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [parallaxOnX, parallaxOnY]
        self.addMotionEffect(group)
    }
    
    func blurMyBackgroundDark(adjust b:Bool, white v:CGFloat, alpha a:CGFloat) {
        
        for v in self.subviews {
            if v is UIVisualEffectView {
                v.removeFromSuperview()
            }
        }
        
        let blur = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let fxView = UIVisualEffectView(effect: blur)
        
        if b {
            fxView.contentView.backgroundColor = UIColor(white:v, alpha:a)
        }
        
        fxView.frame = self.bounds
        
        self.addSubview(fxView)
        self.sendSubviewToBack(fxView)
    }
    
    func blurMyBackgroundLight() {
        
        for v in self.subviews {
            if v is UIVisualEffectView {
                v.removeFromSuperview()
            }
        }
        
        let blur = UIBlurEffect(style: UIBlurEffect.Style.light)
        let fxView = UIVisualEffectView(effect: blur)
        
        var rect = self.bounds
        rect.size.width = CGFloat(2500)
        
        fxView.frame = rect
        
        self.addSubview(fxView)
        
        self.sendSubviewToBack(fxView)
    }
    
    func capture() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, self.isOpaque, UIScreen.main.scale)
        self.drawHierarchy(in: self.frame, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    func convertRectCorrectly(_ rect: CGRect, toView view: UIView) -> CGRect {
        if UIScreen.main.scale == 1 {
            return self.convert(rect, to: view)
        } else if self == view {
            return rect
        } else {
            var rectInParent = self.convert(rect, to: self.superview)
            rectInParent.origin.x /= UIScreen.main.scale
            rectInParent.origin.y /= UIScreen.main.scale
            let superViewRect = self.superview!.convertRectCorrectly(self.superview!.frame, toView: view)
            rectInParent.origin.x += superViewRect.origin.x
            rectInParent.origin.y += superViewRect.origin.y
            return rectInParent
        }
    }
    
    func imageSnapshotCroppedToFrame(_ frame: CGRect?) -> UIImage {
        let scaleFactor = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, scaleFactor)
        self.drawHierarchy(in: bounds, afterScreenUpdates: true)
        var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        if let frame = frame {
            // UIImages are measured in points, but CGImages are measured in pixels
            let scaledRect = frame.applying(CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))
            
            if let imageRef = image.cgImage?.cropping(to: scaledRect) {
                image = UIImage(cgImage: imageRef)
            }
        }
        return image
    }
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

// UIImageView
extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
#endif

// UIImage
public extension UIImage {
    
    class func preferredImageSize(for size: CGSize, with aspectRatio: CGFloat) -> CGSize {
        guard aspectRatio != 1.0 else {
            return CGSize(width: size.height, height: size.height)
        }
        
        let widthDifference = abs(size.width - size.height * aspectRatio) // /
        let heightDiffence = abs(size.height - size.width / aspectRatio)  // *
        
        if widthDifference < heightDiffence {
            return CGSize(width: size.height * aspectRatio, height: size.height)
        } else if widthDifference > heightDiffence {
            return CGSize(width: size.width, height: size.width / aspectRatio)
        } else {
            // If can not determine which difference is greater then the returned size should be based on the specified height
            return CGSize(width: heightDiffence * aspectRatio, height: size.height)
        }
    }
    
    /// More action icon. Aspect ratio 4:1
    class func moreIcon(size: CGSize, color fillColor: UIColor!) -> UIImage {
        let aspectRatio: CGFloat = 4.0
        let preferredSize = UIImage.preferredImageSize(for: size, with: aspectRatio)
        let frame = CGRect(x: 0, y: 0, width: preferredSize.width, height: preferredSize.height)
        
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
        
        //PaintCode here
        let morePath = UIBezierPath()
        morePath.move(to: CGPoint(x: frame.minX + 0.12500 * frame.width, y: frame.minY + 0.00000 * frame.height))
        morePath.addLine(to: CGPoint(x: frame.minX + 0.12500 * frame.width, y: frame.minY + 0.00000 * frame.height))
        morePath.addCurve(to: CGPoint(x: frame.minX + 0.25000 * frame.width, y: frame.minY + 0.50000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.19404 * frame.width, y: frame.minY + 0.00000 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.25000 * frame.width, y: frame.minY + 0.22386 * frame.height))
        morePath.addCurve(to: CGPoint(x: frame.minX + 0.12500 * frame.width, y: frame.minY + 1.00000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.25000 * frame.width, y: frame.minY + 0.77614 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.19404 * frame.width, y: frame.minY + 1.00000 * frame.height))
        morePath.addCurve(to: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.50000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.05596 * frame.width, y: frame.minY + 1.00000 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.77614 * frame.height))
        morePath.addLine(to: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.50000 * frame.height))
        morePath.addCurve(to: CGPoint(x: frame.minX + 0.12500 * frame.width, y: frame.minY + 0.00000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.22386 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.05596 * frame.width, y: frame.minY + 0.00000 * frame.height))
        morePath.close()
        morePath.move(to: CGPoint(x: frame.minX + 0.50000 * frame.width, y: frame.minY + 0.00000 * frame.height))
        morePath.addLine(to: CGPoint(x: frame.minX + 0.50000 * frame.width, y: frame.minY + 0.00000 * frame.height))
        morePath.addCurve(to: CGPoint(x: frame.minX + 0.62500 * frame.width, y: frame.minY + 0.50000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.56904 * frame.width, y: frame.minY + 0.00000 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.62500 * frame.width, y: frame.minY + 0.22386 * frame.height))
        morePath.addCurve(to: CGPoint(x: frame.minX + 0.50000 * frame.width, y: frame.minY + 1.00000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.62500 * frame.width, y: frame.minY + 0.77614 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.56904 * frame.width, y: frame.minY + 1.00000 * frame.height))
        morePath.addCurve(to: CGPoint(x: frame.minX + 0.37500 * frame.width, y: frame.minY + 0.50000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.43096 * frame.width, y: frame.minY + 1.00000 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.37500 * frame.width, y: frame.minY + 0.77614 * frame.height))
        morePath.addLine(to: CGPoint(x: frame.minX + 0.37500 * frame.width, y: frame.minY + 0.50000 * frame.height))
        morePath.addCurve(to: CGPoint(x: frame.minX + 0.50000 * frame.width, y: frame.minY + 0.00000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.37500 * frame.width, y: frame.minY + 0.22386 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.43096 * frame.width, y: frame.minY + 0.00000 * frame.height))
        morePath.close()
        morePath.move(to: CGPoint(x: frame.minX + 0.87500 * frame.width, y: frame.minY + 0.00000 * frame.height))
        morePath.addLine(to: CGPoint(x: frame.minX + 0.87500 * frame.width, y: frame.minY + 0.00000 * frame.height))
        morePath.addCurve(to: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 0.50000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.94404 * frame.width, y: frame.minY + 0.00000 * frame.height), controlPoint2: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 0.22386 * frame.height))
        morePath.addCurve(to: CGPoint(x: frame.minX + 0.87500 * frame.width, y: frame.minY + 1.00000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 0.77614 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.94404 * frame.width, y: frame.minY + 1.00000 * frame.height))
        morePath.addCurve(to: CGPoint(x: frame.minX + 0.75000 * frame.width, y: frame.minY + 0.50000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.80596 * frame.width, y: frame.minY + 1.00000 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.75000 * frame.width, y: frame.minY + 0.77614 * frame.height))
        morePath.addLine(to: CGPoint(x: frame.minX + 0.75000 * frame.width, y: frame.minY + 0.50000 * frame.height))
        morePath.addCurve(to: CGPoint(x: frame.minX + 0.87500 * frame.width, y: frame.minY + 0.00000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.75000 * frame.width, y: frame.minY + 0.22386 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.80596 * frame.width, y: frame.minY + 0.00000 * frame.height))
        morePath.close()
        morePath.usesEvenOddFillRule = true
        fillColor.setFill()
        morePath.fill()
        
        //swiftlint:disable force_unwrapping
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
    
    /// Cancel X icon. Aspect ratio 1:1
    class func cancelIcon(size: CGSize, color fillColor: UIColor!) -> UIImage {
        let aspectRatio: CGFloat = 1.0
        let preferredSize = UIImage.preferredImageSize(for: size, with: aspectRatio)
        let frame = CGRect(x: 0, y: 0, width: preferredSize.width, height: preferredSize.height)
        
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
        
        /// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: frame.minX + 0.08337 * frame.width, y: frame.minY + 0.99873 * frame.height))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 0.08334 * frame.width, y: frame.minY + 0.99873 * frame.height))
        bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.91546 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.03731 * frame.width, y: frame.minY + 0.99873 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.96145 * frame.height))
        bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.02441 * frame.width, y: frame.minY + 0.85658 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.89338 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.00878 * frame.width, y: frame.minY + 0.87220 * frame.height))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 0.38352 * frame.width, y: frame.minY + 0.49754 * frame.height))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 0.03062 * frame.width, y: frame.minY + 0.14184 * frame.height))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 0.03102 * frame.width, y: frame.minY + 0.14227 * frame.height))
        bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.03308 * frame.width, y: frame.minY + 0.02457 * frame.height), controlPoint1: CGPoint(x: frame.minX + -0.00094 * frame.width, y: frame.minY + 0.10920 * frame.height), controlPoint2: CGPoint(x: frame.minX + -0.00002 * frame.width, y: frame.minY + 0.05651 * frame.height))
        bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.14881 * frame.width, y: frame.minY + 0.02457 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.06536 * frame.width, y: frame.minY + -0.00658 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.11653 * frame.width, y: frame.minY + -0.00658 * frame.height))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 0.50126 * frame.width, y: frame.minY + 0.37985 * frame.height))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 0.85673 * frame.width, y: frame.minY + 0.02437 * frame.height))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 0.85673 * frame.width, y: frame.minY + 0.02437 * frame.height))
        bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.97451 * frame.width, y: frame.minY + 0.02437 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.88925 * frame.width, y: frame.minY + -0.00812 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.94198 * frame.width, y: frame.minY + -0.00812 * frame.height))
        bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.97451 * frame.width, y: frame.minY + 0.14206 * frame.height), controlPoint1: CGPoint(x: frame.minX + 1.00703 * frame.width, y: frame.minY + 0.05687 * frame.height), controlPoint2: CGPoint(x: frame.minX + 1.00703 * frame.width, y: frame.minY + 0.10956 * frame.height))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 0.61868 * frame.width, y: frame.minY + 0.49797 * frame.height))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 0.97451 * frame.width, y: frame.minY + 0.85683 * frame.height))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 0.97456 * frame.width, y: frame.minY + 0.85689 * frame.height))
        bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.97662 * frame.width, y: frame.minY + 0.97458 * frame.height), controlPoint1: CGPoint(x: frame.minX + 1.00766 * frame.width, y: frame.minY + 0.88882 * frame.height), controlPoint2: CGPoint(x: frame.minX + 1.00858 * frame.width, y: frame.minY + 0.94152 * frame.height))
        bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.85883 * frame.width, y: frame.minY + 0.97664 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.94466 * frame.width, y: frame.minY + 1.00765 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.89193 * frame.width, y: frame.minY + 1.00857 * frame.height))
        bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.85678 * frame.width, y: frame.minY + 0.97458 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.85814 * frame.width, y: frame.minY + 0.97597 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.85745 * frame.width, y: frame.minY + 0.97528 * frame.height))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 0.50079 * frame.width, y: frame.minY + 0.61562 * frame.height))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 0.14218 * frame.width, y: frame.minY + 0.97420 * frame.height))
        bezierPath.addLine(to: CGPoint(x: frame.minX + 0.14188 * frame.width, y: frame.minY + 0.97450 * frame.height))
        bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.08337 * frame.width, y: frame.minY + 0.99873 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.12635 * frame.width, y: frame.minY + 0.99002 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.10533 * frame.width, y: frame.minY + 0.99873 * frame.height))
        bezierPath.close()
        bezierPath.usesEvenOddFillRule = true
        fillColor.setFill()
        bezierPath.fill()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
    
    
    func imageWithInsets(insetDimen: CGFloat) -> UIImage {
        return imageWithInset(insets: UIEdgeInsets(top: insetDimen, left: insetDimen, bottom: insetDimen, right: insetDimen))
    }
    
    func imageWithInsetTop(insetDimen: CGFloat) -> UIImage {
        return imageWithInset(insets: UIEdgeInsets(top: insetDimen, left: 0, bottom: 0, right: 0))
    }
    
    func imageWithInsetLeft(insetDimen: CGFloat) -> UIImage {
        return imageWithInset(insets: UIEdgeInsets(top: 0, left: insetDimen, bottom: 0, right: 0))
    }
    
    func imageWithInsetBottom(insetDimen: CGFloat) -> UIImage {
        return imageWithInset(insets: UIEdgeInsets(top: 0, left: 0, bottom: insetDimen, right: 0))
    }
    
    func imageWithInsetRight(insetDimen: CGFloat) -> UIImage {
        return imageWithInset(insets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: insetDimen))
    }
    
    func imageWithInset(insets: UIEdgeInsets) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: self.size.width + insets.left + insets.right, height: self.size.height + insets.top + insets.bottom), false, self.scale)
        let origin = CGPoint(x: insets.left, y: insets.top)
        self.draw(at: origin)
        let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageWithInsets!
    }
    
    #if os(iOS)
    static func pdfImage(with name: String, width: CGFloat, pageNumber: Int = 1) -> UIImage? {
        
        guard let url = resourceURLForName(name) else { return nil }
        return _pdfImage(with: url, size: CGSize(width: width, height: 0), pageNumber: pageNumber)
    }
    
    static func pdfImage(with name: String, height: CGFloat, pageNumber: Int = 1) -> UIImage? {
        
        guard let url = resourceURLForName(name) else { return nil }
        return _pdfImage(with: url, size: CGSize(width: 0, height: height), pageNumber: pageNumber)
    }
    
    static func pdfImage(with name: String, pageNumber: Int = 1) -> UIImage? {
        
        guard let url = resourceURLForName(name) else { return nil }
        return _pdfImage(with: url, size: CGSize(width: 0, height: 0), pageNumber: pageNumber)
    }
    
    static func pdfImage(with name: String, size: CGSize, pageNumber: Int = 1) -> UIImage? {
        
        guard let url = resourceURLForName(name) else { return nil }
        return _pdfImage(with: url, size: size, pageNumber: pageNumber)
    }
    
    static func pdfImage(with url: URL, width: CGFloat, pageNumber: Int = 1) -> UIImage? {
        
        return _pdfImage(with: url, size: CGSize(width: width, height: 0), pageNumber: pageNumber)
    }
    
    static func pdfImage(with url: URL, height: CGFloat, pageNumber: Int = 1) -> UIImage? {
        
        return _pdfImage(with: url, size: CGSize(width: 0, height: height), pageNumber: pageNumber)
    }
    
    static func pdfImage(with url: URL, pageNumber: Int = 1) -> UIImage? {
        
        return _pdfImage(with: url, size: CGSize(width: 0, height: 0), pageNumber: pageNumber)
    }
    
    static func pdfImage(with url: URL, size: CGSize, pageNumber: Int = 1) -> UIImage? {
        
        return _pdfImage(with:url, size: size, pageNumber: pageNumber)
    }
    
    private static func _pdfImage(with url: URL, size: CGSize, pageNumber: Int) -> UIImage? {
        guard
            let pdf = CGPDFDocument(url as CFURL),
            let page = pdf.page(at: pageNumber)
            else { return nil }
        
        
        let size = pdfSize(
            withOrginalSize: page.getBoxRect(.mediaBox).size,
            selectedSize: size
        )
        
        if
            pdfCacheInMemory,
            let image = memoryCachedImage(url: url, size: size, pageNumber: pageNumber) {
            
            return image
        }
        
        guard
            let imageUrl = pdfCacheOnDisk ? pdfCacheURL(with: url, size: size, pageNumber: pageNumber) : url
            else { return nil }
        
        if
            pdfCacheOnDisk,
            FileManager.default.fileExists(atPath: imageUrl.path),
            let image = UIImage(contentsOfFile: imageUrl.path),
            let cgImage = image.cgImage {
            
            return UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.concatenate(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height))
        let rect = page.getBoxRect(.mediaBox)
        context.translateBy(x: -rect.origin.x, y: -rect.origin.y)
        context.scaleBy(x: size.width / rect.size.width, y: size.height / rect.size.height)
        context.drawPDFPage(page)
        let imageFromContext = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard
            let image = imageFromContext,
            let imageData = image.pngData(),
            let cgImage = image.cgImage
            else { return nil }
        
        if pdfCacheOnDisk      { cacheOnDisk(date: imageData, url: imageUrl) }
        if pdfCacheInMemory    { cacheImageInMemory(image, url: url, size: size, pageNumber: pageNumber) }
        
        return UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .up)
    }
    
    private static func resourceURLForName(_ resourceName: String) -> URL? {
        
        let isSuffix = resourceName.lowercased().hasSuffix(".pdf")
        let name = isSuffix ? resourceName : resourceName + ".pdf"
        
        if let path = Bundle.main.path(forResource: name, ofType: nil) {
            return URL(fileURLWithPath: path)
        }
        return nil
    }
    
    private static func pdfSize(with url: URL, size: CGSize, pageNumber: Int) -> CGSize? {
        
        guard
            let pdf = CGPDFDocument(url as CFURL),
            let page = pdf.page(at: pageNumber)
            else { return nil }
        
        return pdfSize(
            withOrginalSize: page.getBoxRect(.mediaBox).size,
            selectedSize: size
        )
    }
    
    private static func pdfSize(withOrginalSize orginalSize: CGSize, selectedSize: CGSize) -> CGSize {
        
        guard selectedSize != .zero else { return orginalSize }
        guard selectedSize.width == 0 || selectedSize.height == 0 else { return selectedSize }
        
        let multiplier = (
            selectedSize.width == 0 ? selectedSize.height / orginalSize.height : selectedSize.width / orginalSize.width
        )
        
        return CGSize(
            width: ceil(orginalSize.width * multiplier),
            height: ceil(orginalSize.height * multiplier)
        )
    }
    
    static var pdfCacheOnDisk = false
    static var pdfCacheInMemory = true
    
    //all
    
    static func removeAllPDFCache() {
        
        removeAllPDFDiskCache()
        removeAllPDFMemoryCache()
    }
    
    static func removeAllPDFMemoryCache() {
        
        imageCache.removeAllObjects()
    }
    
    static func removeAllPDFDiskCache() {
        
        let cacheDirectory = NSSearchPathForDirectoriesInDomains(
            .cachesDirectory,
            .userDomainMask,
            true
            )[0] + "/" + kDiskCacheFolderName
        
        try? FileManager.default.removeItem(atPath: cacheDirectory)
    }
    
    //memory
    
    static func removeMemoryCachedPDFImage(with name: String, size: CGSize, pageNumber: Int = 1) {
        
        guard let url = resourceURLForName(name) else { return }
        removeMemoryCachedPDFImage(with: url, size: size, pageNumber: pageNumber)
    }
    
    static func removeMemoryCachedPDFImage(with url: URL, size: CGSize, pageNumber: Int = 1) {
        
        guard
            let size = pdfSize(with: url, size: size, pageNumber: pageNumber),
            let hash = pdfCacheHashString(with: url, size: size, pageNumber: pageNumber)
            else { return }
        
        imageCache.removeObject(forKey: NSString(string: String(hash)))
    }
    
    //disk
    
    static func removeDiskCachedPDFImage(with name: String, size: CGSize, pageNumber: Int = 1) {
        
        guard let url = resourceURLForName(name) else { return }
        removeDiskCachedPDFImage(with: url, size: size, pageNumber: pageNumber)
    }
    
    static func removeDiskCachedPDFImage(with url: URL, size: CGSize, pageNumber: Int = 1) {
        
        guard
            let size = pdfSize(with: url, size: size, pageNumber: pageNumber),
            let imageUrl = pdfCacheURL(with: url, size: size, pageNumber: pageNumber)
            else { return }
        
        try? FileManager.default.removeItem(at: imageUrl)
    }
    
    // MARK: - Memory Cache
    
    private static let imageCache = NSCache<NSString, UIImage>()
    
    private static func cacheImageInMemory(_ image: UIImage, url: URL, size: CGSize, pageNumber: Int) {
        
        guard let hash = pdfCacheHashString(with: url, size: size, pageNumber: pageNumber) else { return }
        imageCache.setObject(image, forKey: NSString(string: String(hash)))
    }
    
    private static func memoryCachedImage(url: URL, size: CGSize, pageNumber: Int) -> UIImage? {
        
        guard let hash = pdfCacheHashString(with: url, size: size, pageNumber: pageNumber) else { return nil }
        return imageCache.object(forKey: NSString(string: String(hash)))
    }
    
    // MARK: - Disk Cache
    
    private static let kDiskCacheFolderName = "PDFCache"
    
    private static func cacheOnDisk(date: Data, url: URL) {
        
        try? date.write(to: url, options: [])
    }
    
    private static func pdfCacheURL(with url: URL, size: CGSize, pageNumber: Int) -> URL? {
        
        do {
            guard let hash = pdfCacheHashString(with: url, size: size, pageNumber: pageNumber) else { return nil }
            
            let cacheDirectory = NSSearchPathForDirectoriesInDomains(
                .cachesDirectory,
                .userDomainMask,
                true
                )[0] + "/" + kDiskCacheFolderName
            
            try FileManager.default.createDirectory(
                atPath: cacheDirectory,
                withIntermediateDirectories: true,
                attributes: nil
            )
            
            return URL(fileURLWithPath: cacheDirectory + "/" + String(format:"%2X", hash) + ".png")
            
        } catch { return nil }
    }
    
    private static func pdfCacheHashString(with url: URL, size: CGSize, pageNumber: Int) -> Int? {
        
        guard
            let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
            let fileSize = attributes[.size] as? NSNumber,
            let fileDate = attributes[.modificationDate] as? Date
            else { return nil }
        
        let hashables =
            url.path +
                fileSize.stringValue +
                String(fileDate.timeIntervalSince1970) +
                String(describing: size) +
                String(describing: pageNumber)
        
        return hashables.hash
    }
    
    
    func crop( rect: CGRect) -> UIImage {
        var rect = rect
        rect.origin.x*=self.scale
        rect.origin.y*=self.scale
        rect.size.width*=self.scale
        rect.size.height*=self.scale
        
        let imageRef = self.cgImage!.cropping(to: rect)
        let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return image
    }
    
    func resize(withWidth newWidth: CGFloat) -> UIImage? {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    
    
    func fromLandscapeToPortrait(_ rotate: Bool!) -> UIImage {
        let container : UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 320, height: 568))
        container.contentMode = UIView.ContentMode.scaleAspectFill
        container.clipsToBounds = true
        container.image = self
        
        UIGraphicsBeginImageContextWithOptions(container.bounds.size, true, 0);
        container.drawHierarchy(in: container.bounds, afterScreenUpdates: true)
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if !rotate {
            return normalizedImage!
        } else {
            let rotatedImage = UIImage(cgImage: (normalizedImage?.cgImage!)!, scale: 1.0, orientation: UIImage.Orientation.left)
            
            UIGraphicsBeginImageContextWithOptions(rotatedImage.size, true, 1);
            rotatedImage.draw(in: CGRect(x: 0, y: 0, width: rotatedImage.size.width, height: rotatedImage.size.height))
            let normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            return normalizedImage!
        }
    }
    #endif
    
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, true, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func imageWithColor(_ color: UIColor) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        context?.setBlendMode(.normal)
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        context?.clip(to: rect, mask: self.cgImage!)
        color.setFill()
        context?.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    #if os(iOS)
    func areaAverage() -> UIColor {
        var bitmap = [UInt8](repeating: 0, count: 4)
        
        let context = CIContext()
        let inputImage = ciImage ?? CoreImage.CIImage(cgImage: cgImage!)
        let extent = inputImage.extent
        let inputExtent = CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)
        let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: inputExtent])!
        let outputImage = filter.outputImage!
        let outputExtent = outputImage.extent
        assert(outputExtent.size.width == 1 && outputExtent.size.height == 1)
        
        // Render to bitmap.
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: CIFormat.RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
        
        // Compute result.
        let result = UIColor(red: CGFloat(bitmap[0]) / 255.0, green: CGFloat(bitmap[1]) / 255.0, blue: CGFloat(bitmap[2]) / 255.0, alpha: CGFloat(bitmap[3]) / 255.0)
        return result
    }
    #endif
    
    func imageByCroppingImage(_ size: CGSize) -> UIImage {
        let newCropWidth, newCropHeight : CGFloat;
        
        if(self.size.width < self.size.height) {
            if (self.size.width < size.width) {
                newCropWidth = self.size.width;
            }
            else {
                newCropWidth = size.width;
            }
            newCropHeight = (newCropWidth * size.height)/size.width;
        } else {
            if (self.size.height < size.height) {
                newCropHeight = self.size.height;
            }
            else {
                newCropHeight = size.height;
            }
            newCropWidth = (newCropHeight * size.width)/size.height;
        }
        
        let x = self.size.width / 2 - newCropWidth / 2;
        let y = self.size.height / 2 - newCropHeight / 2;
        
        let cropRect = CGRect(x: x, y: y, width: newCropWidth, height: newCropHeight);
        let imageRef = self.cgImage?.cropping(to: cropRect);
        
        let croppedImage : UIImage = UIImage(cgImage: imageRef!, scale: 0, orientation: self.imageOrientation);
        
        return croppedImage;
    }
    
    func imageWithSize(_ size:CGSize) -> UIImage
    {
        var scaledImageRect = CGRect.zero;
        
        let aspectWidth:CGFloat = size.width / self.size.width;
        let aspectHeight:CGFloat = size.height / self.size.height;
        let aspectRatio:CGFloat = min(aspectWidth, aspectHeight);
        
        scaledImageRect.size.width = self.size.width * aspectRatio;
        scaledImageRect.size.height = self.size.height * aspectRatio;
        scaledImageRect.origin.x = (size.width - scaledImageRect.size.width) / 2.0;
        scaledImageRect.origin.y = (size.height - scaledImageRect.size.height) / 2.0;
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        
        self.draw(in: scaledImageRect);
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return scaledImage!;
    }
    
    #if os(iOS)
    var rounded: UIImage? {
        let imageView = UIImageView(image: self)
        imageView.layer.cornerRadius = min(size.height/4, size.width/4)
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    var circle: UIImage? {
        let square = CGSize(width: min(size.width, size.height), height: min(size.width, size.height))
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
        imageView.contentMode = .scaleAspectFill
        imageView.image = self
        imageView.layer.cornerRadius = square.width/2
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    #endif
}

extension UIColor {
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
    
}

// UITableView
#if os(iOS)
public extension UITableViewController {
    
    func insertBackground(image: UIImage) {
        let imVi = UIImageView(frame: tableView.frame)
        imVi.contentMode = .scaleToFill
        imVi.image = image
        tableView.backgroundView = imVi
    }
    
    func createNoPaintBlur(_ effectStyle: UIBlurEffect.Style, withImage image:UIImage?, lineVibrance:Bool) {
        
        let blurEffect = UIBlurEffect(style: effectStyle)
        let packView = UIView(frame: tableView.frame)
        
        if let imageTest = image {
            
            let imVi = UIImageView(frame: packView.frame)
            imVi.contentMode = .scaleToFill
            imVi.image = imageTest
            packView.addSubview(imVi)
            
            let fx = UIVisualEffectView(effect: blurEffect)
            fx.frame = packView.frame
            packView.addSubview(fx)
            
            tableView.backgroundView = packView
        } else {
            tableView.backgroundColor = UIColor.clear
            tableView.backgroundView = UIVisualEffectView(effect: blurEffect)
        }
        
        if let popover = navigationController?.popoverPresentationController {
            popover.backgroundColor = UIColor.clear
        }
        
        if !lineVibrance { return }
        tableView.separatorEffect = UIVibrancyEffect(blurEffect: blurEffect)
    }
    
    func createBlur(_ effectStyle: UIBlurEffect.Style, withImage image:UIImage?, lineVibrance:Bool) {
        
        if let imageTest = image {
            tableView.backgroundColor = UIColor(patternImage: imageTest)
        } else {
            tableView.backgroundColor = UIColor.clear
        }
        
        if let popover = navigationController?.popoverPresentationController {
            popover.backgroundColor = UIColor.clear
        }
        
        let blurEffect = UIBlurEffect(style: effectStyle)
        tableView.backgroundView = UIVisualEffectView(effect: blurEffect)
        if !lineVibrance { return }
        tableView.separatorEffect = UIVibrancyEffect(blurEffect: blurEffect)
    }
}

public extension UITableView {
    
    func createBlur(_ effectStyle: UIBlurEffect.Style, withImage image:UIImage?, lineVibrance:Bool) {
        
        if let imageTest = image {
            self.backgroundColor = UIColor(patternImage: imageTest)
        } else {
            self.backgroundColor = UIColor.clear
        }
        
        let blurEffect = UIBlurEffect(style: effectStyle)
        self.backgroundView = UIVisualEffectView(effect: blurEffect)
        if !lineVibrance { return }
        self.separatorEffect = UIVibrancyEffect(blurEffect: blurEffect)
    }
    
    func createNoPaintBlur(_ effectStyle: UIBlurEffect.Style, withImage image:UIImage?, lineVibrance:Bool) {
        
        let blurEffect = UIBlurEffect(style: effectStyle)
        let packView = UIView(frame: self.frame)
        
        if let imageTest = image {
            
            let imVi = UIImageView(frame: packView.frame)
            imVi.contentMode = .scaleToFill
            imVi.image = imageTest
            packView.addSubview(imVi)
            
            let fx = UIVisualEffectView(effect: blurEffect)
            fx.frame = packView.frame
            packView.addSubview(fx)
            
            self.backgroundView = packView
        } else {
            self.backgroundColor = UIColor.clear
            self.backgroundView = UIVisualEffectView(effect: blurEffect)
        }
        
        if !lineVibrance { return }
        self.separatorEffect = UIVibrancyEffect(blurEffect: blurEffect)
    }
}
#endif

// Date
let componentFlags : Set<Calendar.Component> = [Calendar.Component.year, Calendar.Component.month, Calendar.Component.day, Calendar.Component.weekdayOrdinal, Calendar.Component.hour,Calendar.Component.minute, Calendar.Component.second, Calendar.Component.weekday, Calendar.Component.weekdayOrdinal]

public extension DateComponents {
    mutating func to12am() {
        self.hour = 0
        self.minute = 0
        self.second = 0
    }
    
    mutating func to12pm() {
        self.hour = 23
        self.minute = 59
        self.second = 59
    }
}

public extension DateFormatter {
    convenience init (format: String) {
        self.init()
        dateFormat = format
        locale = Locale.current
    }
}

public extension Date {
    
    func toString (format:String) -> String? {
        return DateFormatter(format: format).string(from: self)
    }
    
    //Crea una data direttamente dai valori passati
    static func customDate(year ye:Int, month mo:Int, day da:Int, hour ho:Int, minute mi:Int, second se:Int) -> Date {
        var comps = DateComponents()
        comps.year = ye
        comps.month = mo
        comps.day = da
        comps.hour = ho
        comps.minute = mi
        comps.second = se
        let date = NSCalendar.current.date(from: comps)
        return date!
    }
    
    func localeString() -> String {
        let df = DateFormatter()
        df.locale = NSLocale.current
        df.timeStyle = .medium
        df.dateStyle = .short
        return df.string(from: self)
    }
    
    struct Gregorian {
        static let calendar = Calendar(identifier: .gregorian)
    }
    var startOfWeek: Date? {
        return Gregorian.calendar.date(from: Gregorian.calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
    }
    
    func startOfWeek(weekday: Int?) -> Date {
        var cal = Calendar.current
        var component = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        component.to12am()
        cal.firstWeekday = weekday ?? 1
        return cal.date(from: component)!
    }
    
    func endOfWeek(weekday: Int) -> Date {
        let cal = Calendar.current
        var component = DateComponents()
        component.weekOfYear = 1
        component.day = -1
        component.to12pm()
        return cal.date(byAdding: component, to: startOfWeek(weekday: weekday))!
    }
    
    static func customDateUInt(year ye:UInt, month mo:UInt, day da:UInt, hour ho:UInt, minute mi:UInt, second se:UInt) -> Date {
        var comps = DateComponents()
        comps.year = Int(ye)
        comps.month = Int(mo)
        comps.day = Int(da)
        comps.hour = Int(ho)
        comps.minute = Int(mi)
        comps.second = Int(se)
        let date = NSCalendar.current.date(from: comps)
        return date!
    }
    
    static func dateOfMonthAgo() -> Date {
        return Date().addingTimeInterval(-24 * 30 * 60 * 60)
    }
    
    static func dateOfWeekAgo() -> Date {
        return Date().addingTimeInterval(-24 * 7 * 60 * 60)
    }
    
    func sameDate(ofDate:Date) -> Bool {
        let cal = NSCalendar.current
        let dif = cal.compare(self, to: ofDate, toGranularity: Calendar.Component.day)
        if dif == .orderedSame {
            return true
        } else {
            return false
        }
    }
    
    static func currentCalendar() -> Calendar {
        return Calendar.autoupdatingCurrent
    }
    
    func isEqualToDateIgnoringTime(_ aDate:Date) -> Bool {
        let components1 = Date.currentCalendar().dateComponents(componentFlags, from: self)
        let components2 = Date.currentCalendar().dateComponents(componentFlags, from: aDate)
        
        return ((components1.year == components2.year) &&
            (components1.month == components2.month) &&
            (components1.day == components2.day))
    }
    
    func plusSeconds(_ s: Int) -> Date {
        return self.addComponentsToDate(seconds: s, minutes: 0, hours: 0, days: 0, weeks: 0, months: 0, years: 0)
    }
    
    func minusSeconds(_ s: UInt) -> Date {
        return self.addComponentsToDate(seconds: -Int(s), minutes: 0, hours: 0, days: 0, weeks: 0, months: 0, years: 0)
    }
    
    func plusMinutes(_ m: Int) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: m, hours: 0, days: 0, weeks: 0, months: 0, years: 0)
    }
    
    func minusMinutes(_ m: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: -Int(m), hours: 0, days: 0, weeks: 0, months: 0, years: 0)
    }
    
    func plusHours(_ h: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: Int(h), days: 0, weeks: 0, months: 0, years: 0)
    }
    
    func minusHours(_ h: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: -Int(h), days: 0, weeks: 0, months: 0, years: 0)
    }
    
    func plusDays(_ d: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: Int(d), weeks: 0, months: 0, years: 0)
    }
    
    func minusDays(_ d: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: -Int(d), weeks: 0, months: 0, years: 0)
    }
    
    func plusWeeks(_ w: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: Int(w), months: 0, years: 0)
    }
    
    func minusWeeks(_ w: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: -Int(w), months: 0, years: 0)
    }
    
    func plusMonths(_ m: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: 0, months: Int(m), years: 0)
    }
    
    func minusMonths(_ m: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: 0, months: -Int(m), years: 0)
    }
    
    func plusYears(_ y: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: 0, months: 0, years: Int(y))
    }
    
    func minusYears(_ y: UInt) -> Date {
        return self.addComponentsToDate(seconds: 0, minutes: 0, hours: 0, days: 0, weeks: 0, months: 0, years: -Int(y))
    }
    
    private func addComponentsToDate(seconds sec: Int, minutes min: Int, hours hrs: Int, days d: Int, weeks wks: Int, months mts: Int, years yrs: Int) -> Date {
        var dc:DateComponents = DateComponents()
        dc.second = sec
        dc.minute = min
        dc.hour = hrs
        dc.day = d
        dc.weekOfYear = wks
        dc.month = mts
        dc.year = yrs
        return Calendar.current.date(byAdding: dc, to: self, wrappingComponents: false)!
    }
    
    func midnightUTCDate() -> Date {
        var dc:DateComponents = Calendar.current.dateComponents([Calendar.Component.year, Calendar.Component.month, Calendar.Component.day], from: self)
        dc.hour = 0
        dc.minute = 0
        dc.second = 0
        dc.nanosecond = 0
        (dc as NSDateComponents).timeZone = TimeZone(secondsFromGMT: 0)
        
        return Calendar.current.date(from: dc)!
    }
    
    static func secondsBetween(date1 d1:Date, date2 d2:Date) -> Int {
        let dc = Calendar.current.dateComponents(componentFlags, from: d1, to: d2)
        return dc.second!
    }
    
    static func minutesBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents(componentFlags, from: d1, to: d2)
        return dc.minute!
    }
    
    static func hoursBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents(componentFlags, from: d1, to: d2)
        return dc.hour!
    }
    
    static func daysBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents(componentFlags, from: d1, to: d2)
        return dc.day!
    }
    
    static func weeksBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents(componentFlags, from: d1, to: d2)
        return dc.weekOfYear!
    }
    
    static func monthsBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents(componentFlags, from: d1, to: d2)
        return dc.month!
    }
    
    static func yearsBetween(date1 d1: Date, date2 d2: Date) -> Int {
        let dc = Calendar.current.dateComponents(componentFlags, from: d1, to: d2)
        return dc.year!
    }
    
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    
    var isLastDayOfMonth: Bool {
        return tomorrow.month != month
    }
    
    //MARK- Comparison Methods
    
    func isGreaterThan(_ date: Date) -> Bool {
        return (self.compare(date) == .orderedDescending)
    }
    
    func isLessThan(_ date: Date) -> Bool {
        return (self.compare(date) == .orderedAscending)
    }
    
    //MARK- Computed Properties
    
    var day: UInt {
        return UInt(Calendar.current.component(.day, from: self))
    }
    
    var month: UInt {
        return UInt(Calendar.current.component(.month, from: self))
    }
    
    var year: UInt {
        return UInt(Calendar.current.component(.year, from: self))
    }
    
    var hour: UInt {
        return UInt(Calendar.current.component(.hour, from: self))
    }
    
    var minute: UInt {
        return UInt(Calendar.current.component(.minute, from: self))
    }
    
    var second: UInt {
        return UInt(Calendar.current.component(.second, from: self))
    }
}

#if os(iOS)
extension UIAlertController {
    override open var shouldAutorotate: Bool {
        return false
    }
}
#endif

// Array
extension Array where Element:Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()
        
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        
        return result
    }
    
    @discardableResult
    mutating func appendIfNotContains(_ element: Element) -> Bool {
        if !contains(element) {
            append(element)
            return true
        }
        return false
    }
}

//extension Array {
//    func splitBy(subSize: Int) -> [[Element]] {
//        return 0.stride(to: self.count, by: subSize).map { startIndex in
//            let endIndex = startIndex.advancedBy(subSize, limit: self.count)
//            return Array(self[startIndex ..< endIndex])
//        }
//    }
//}

// Audio fade
extension AVAudioPlayer {
    @objc func fadeOut() {
        if volume > 0.1 {
            // Fade
            volume -= 0.1
            perform(#selector(fadeOut), with: nil, afterDelay: 0.2)
        } else {
            // Stop and get the sound ready for playing again
            stop()
            prepareToPlay()
            volume = 1
        }
    }
}

#if os(iOS)
extension AVPlayer {
    
    var isPlaying: Bool {
        return ((rate != 0) && (error == nil))
    }
}
#endif

// metodi utili
public func delay(_ delay:Double, closure: @escaping ()->()) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

public func loc(_ localizedKey:String) -> String {
    return NSLocalizedString(localizedKey, comment: "")
}

func scaleImageFromWidth (_ sourceImage:UIImage, scaledToWidth: CGFloat) -> UIImage {
    let oldWidth = sourceImage.size.width
    let scaleFactor = scaledToWidth / oldWidth
    
    let newHeight = sourceImage.size.height * scaleFactor
    let newWidth = oldWidth * scaleFactor
    
    UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
    sourceImage.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage!
}

func scaleImageFromHeight (_ sourceImage:UIImage, scaledToHeight: CGFloat) -> UIImage {
    let oldHeight = sourceImage.size.height
    let scaleFactor = scaledToHeight / oldHeight
    
    let newHeight = oldHeight * scaleFactor
    let newWidth = sourceImage.size.width * scaleFactor
    
    UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
    sourceImage.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage!
}
