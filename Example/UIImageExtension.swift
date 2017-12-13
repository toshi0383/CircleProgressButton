//
//  UIImageExtension.swift
//  Example
//
//  Created by Toshihiro Suzuki on 2017/12/13.
//  Copyright © 2017 toshi0383. All rights reserved.
//

import UIKit

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
