//
//  ImageToPasswordVC.swift
//  VisPass
//
//  Created by Nevzat TUFEKCI.
//

import UIKit

protocol ImageToPasswordProtocol: NSObject {
    func didSave(image: UIImage, hash: String, authenticationCount: Int)
    func masterSave()
}

extension ImageToPasswordProtocol {
    func masterSave(){}
}

class ImageToPasswordVC: BaseViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var imgViewHash: CryptoImageView!
    @IBOutlet weak var imgViewCropped: UIImageView!
    @IBOutlet weak var lbTapCount: UILabel!
    @IBOutlet weak var btSave: UIButton!
    
    // MARK: Variables
    var image: UIImage?
    var key: String?
    
    // MARK: Delegates
    weak var delegate: ImageToPasswordProtocol?
    
    // MARK: Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: Setup
    func setup() {
        imgViewHash.delegate = self
        imgViewHash.image = image
        imgViewHash.key = key
        setSaveActive(enabled: false)
    }
    func initView() {
        imgViewHash.drawImageGrid()
    }
    
    // MARK: Methods
    func reset() {
        imgViewHash.encryptedHash = ""
        imgViewHash.order = 0
        setTapCount()
        imgViewCropped.image = nil
        lbTapCount.text = nil
        setSaveActive(enabled: false)
    }
    
    func setTapCount() {
        lbTapCount.text =  "\(imgViewHash.order)"
    }
    
    func setSaveActive(enabled: Bool) {
        btSave.isUserInteractionEnabled = enabled
        btSave.isEnabled = enabled
        btSave.alpha = enabled ? 1 : 0.6
    }
    
    func save(key: String) {
        if let image = imgViewHash.image, let hash = imgViewHash.encryptedHash {
            delegate?.didSave(image: image, hash: hash, authenticationCount: imgViewHash.order)
            if key == kMasterPasswordKey {
                delegate?.masterSave()
            }
            self.dismiss(animated: true, completion: nil)
        } else {
            self.showAlert(title: "Error", message: "An Error Occured")
        }
    }
    
    // MARK: IBActions
    @IBAction func btResetAction(_ sender: Any) {
        reset()
    }
    @IBAction func btSaveAction(_ sender: Any) {
        if let key = imgViewHash.key {
            save(key: key)
        }
    }
    
}

extension ImageToPasswordVC: CryptoImageProtocol {
    func selectImagePart(image: UIImage, rowIndex: Int, columnIndex: Int, order: Int) {
        if let image = imgViewHash.parts?[optional: rowIndex]?[optional: columnIndex] {
            UIView.transition(with: imgViewHash,
                              duration: 0.15,
                              options: .transitionCrossDissolve,
                              animations: { self.imgViewCropped.image = image },
                              completion: nil)
            if imgViewHash.order >= imgViewHash.minTapCount, let _ = imgViewHash.encryptedHash {
                setSaveActive(enabled: true)
            }
            setTapCount()
        }
    }
}
