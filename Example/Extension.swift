import UIKit

extension UIColor {

    convenience init(hex: Int, alpha: CGFloat = 1) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(hex & 0x0000FF) / 255.0

        self.init(displayP3Red: red, green: green, blue: blue, alpha: alpha)
    }

}

extension UIImage {

    func tinted(with tintColor: UIColor) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)

        tintColor.set()
        UIRectFill(rect)
        draw(in: rect, blendMode: .destinationIn, alpha: 1.0)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return tintedImage
    }

}
