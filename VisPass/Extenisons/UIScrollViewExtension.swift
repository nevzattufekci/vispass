//
//  UIScrollViewExtension.swift
//  VisPass
//
//  Created by Nevzat TUFEKCI.
//

import UIKit

extension UIScrollView {
    func setContentInsetAndScrollIndicatorInsets(edgeInsets: UIEdgeInsets) {
        self.contentInset = edgeInsets
        self.scrollIndicatorInsets = edgeInsets
    }
}
