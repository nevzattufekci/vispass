//
//  UIViewExtension.swift
//  VisPass
//
//  Created by Nevzat TUFEKCI.
//

import UIKit

extension UIView {
    
    @IBInspectable var masksToBounds: Bool {
        get {
            return layer.masksToBounds
        }
        set {
            layer.masksToBounds = newValue
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.shadowPath = UIBezierPath(roundedRect: layer.bounds, cornerRadius: cornerRadius).cgPath
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    func drawGrid(rowCount: Int, columnCount: Int) {
        
        DispatchQueue.main.async {
            let gridWidth  = self.bounds.width/CGFloat(columnCount)
            let gridHeight = self.bounds.height/CGFloat(rowCount)
            
            // MARK: Draw Columns
            for index in 0...rowCount {
                let path = UIBezierPath()
                let yPos = gridHeight * CGFloat(index)
                path.move(to: CGPoint(x: 0, y: yPos))
                path.addLine(to: CGPoint(x: self.bounds.width, y: yPos))
                let pathLayer = CAShapeLayer()
                pathLayer.path = path.cgPath
                pathLayer.strokeColor = UIColor.lightGray.cgColor
                pathLayer.lineWidth = 1.5
                pathLayer.lineDashPattern = [5,5]
                self.layer.addSublayer(pathLayer)
            }
            
            // MARK: Draw Rows
            for index in 0...columnCount {
                let path = UIBezierPath()
                let xPos = gridWidth * CGFloat(index)
                path.move(to: CGPoint(x: xPos, y: 0))
                path.addLine(to: CGPoint(x: xPos, y: self.bounds.height))
                let pathLayer = CAShapeLayer()
                pathLayer.path = path.cgPath
                pathLayer.strokeColor = UIColor.lightGray.cgColor
                pathLayer.lineWidth = 1.5
                pathLayer.lineDashPattern = [5,5]
                self.layer.addSublayer(pathLayer)
            }
            self.setNeedsDisplay()
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
        
        
    }
    
    func getElementByTag(tag: Int) -> UIView? {
        return self.viewWithTag(tag)
    }
    
    func addBlurEffect(style: UIBlurEffect.Style) {
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.tag = ViewTag.BlurEffectViewTag.rawValue
        blurEffectView.accessibilityLabel = "BlurEffectView"
        blurEffectView.layer.opacity = 0.98
        self.addSubview(blurEffectView)
    }
    
    func addBlurVibrancyEffect(style: UIBlurEffect.Style) {
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyEffectView.frame = self.bounds
        
        blurEffectView.contentView.addSubview(vibrancyEffectView)
        
        self.addSubview(blurEffectView)
    }
    
    func removeBlurEffect() {
        self.removeElementByTag(tag: ViewTag.BlurEffectViewTag.rawValue)
    }
    
    func removeElementByTag(tag: Int) {
        let element = getElementByTag(tag: tag)
        if element?.responds(to: #selector(UIView.removeFromSuperview)) ?? false {
            element?.removeFromSuperview()
        }
    }
    
}

enum ViewTag: Int {

    case SplashViewTag = 100004;
    case BlurEffectViewTag = 100005;
    case InfoError = 400001;
}

