//
//  ApplicationExtension.swift
//  VisPass
//
//  Created by Nevzat TUFEKCI.
//

import UIKit

extension UIApplication {
    func getTopViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        } else {
            return nil
        }
    }
}
