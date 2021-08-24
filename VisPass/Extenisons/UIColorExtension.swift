//
//  UIColorExtension.swift
//  VisPass
//
//  Created by Nevzat TUFEKCI.
//

import UIKit

extension UIColor {
    convenience init(red: CGFloat, green: CGFloat, blue: CGFloat, a: CGFloat) {
        self.init(red: CGFloat(red) / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: a)
    }
    
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
}
