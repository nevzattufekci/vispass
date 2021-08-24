//
//  CryptoImageView.swift
//  VisPass
//
//  Created by Nevzat TUFEKCI.
//

import UIKit

protocol CryptoImageProtocol: AnyObject {
    func selectImagePart(image: UIImage, rowIndex: Int, columnIndex: Int, order: Int)
}

class CryptoImageView: UIImageView {
    
    // MARK: Internal Variabels
    var rowCount = 7
    var columnCount = 5
    var parts: [[UIImage]]?
    var key: String?
    var encryptedHash: String?
    var order: Int = 0
    var minTapCount = 6
    
    // MARK: Delegates
    weak var delegate: CryptoImageProtocol?
    
    // MARK: Overrides
    override var image: UIImage? {
        didSet {
            super.image = image
            parts = imageParts()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let position = touch.location(in: self)
            let columnIndex = Int(position.x/(self.bounds.width/CGFloat(columnCount)))
            let rowIndex = Int(position.y/(self.bounds.height/CGFloat(rowCount)))
            if let image = self.parts?[optional: rowIndex]?[optional: columnIndex] {
                order += 1
                encryptedHash = crypt(image: image, rowIndex: rowIndex, columnIndex: columnIndex, order: order)
                delegate?.selectImagePart(image: image, rowIndex: rowIndex, columnIndex: columnIndex, order: order)
            }
            drawCircle(point: touch.location(in: self))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeCircle()
    }
    
    // MARK: Setup
    fileprivate func setup() {
        isUserInteractionEnabled = true
    }

    func imageParts() -> [[UIImage]] {
        var images: [[UIImage]] = [[UIImage]]()
        guard let cgImage = self.image?.fixOrientation().cgImage else {
            return images
        }
        
        let width = cgImage.width/columnCount
        let height = cgImage.height/rowCount
        
        var xPos = 0
        var yPos = 0
        
        for _ in 0..<rowCount {
            var imageParts = [UIImage]()
            for _ in 0..<columnCount {
                if let cgImagePart = cgImage.cropping(to: CGRect(x: xPos, y: yPos, width: width, height: height)) {
                    imageParts.append(UIImage(cgImage: cgImagePart))
                }
                xPos += width
            }
            images.append(imageParts)
            xPos = 0
            yPos += height
        }
        return images
    }

    func crypt(image: UIImage, rowIndex: Int, columnIndex: Int, order: Int) -> String {
        var hash = ""
        if let imageData = image.cgImage?.dataProvider?.data as Data? {
            var hashData = Data()
            hashData.append(imageData)
            let touchData = ((pow(Decimal(rowIndex), 3) * 1000)
                                + (pow(Decimal(columnIndex), 2) * 100)
                                + Decimal(order + 10)
                                + Decimal(rowIndex + columnIndex - order))
                .description.sha256() ?? Data()
            hashData.append(touchData)
            hashData.append(Data(base64Encoded: encryptedHash ?? "") ?? Data())
            hash = hashData.sha256()?.toBase64() ?? ""
        }
        return hash
    }
    
    func drawCircle(point: CGPoint) {
        removeCircle()
        let circlePath = UIBezierPath(arcCenter: point, radius: 25.0, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2.0), clockwise: true)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.lineWidth = 1.5
        shapeLayer.accessibilityLabel = "circle"
        
        let drawAnimation = CABasicAnimation(keyPath: "opacity")
        drawAnimation.duration = 0.30
        drawAnimation.repeatCount = 1
        drawAnimation.fromValue = 0.5
        drawAnimation.toValue = 1
        drawAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        shapeLayer.add(drawAnimation, forKey:"opacity")
        self.layer.addSublayer(shapeLayer)
    }
    
    func drawImageGrid() {
        drawGrid(rowCount: rowCount, columnCount: columnCount)
    }
    
    func removeCircle() {
        if let subLayers = self.layer.sublayers {
            for subLayer in subLayers {
                if subLayer.accessibilityLabel == "circle" {
                    subLayer.removeFromSuperlayer()
                }
            }
        }
    }
}


