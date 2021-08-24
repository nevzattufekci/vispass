//
//  MasterVC.swift
//  VisPass
//
//  Created by Nevzat TUFEKCI.
//

import UIKit

enum OpenFrom {
    case main
    case settings
}

class MasterVC: BaseViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var imgMasterPassword: PhotoView!
    @IBOutlet weak var btSelectImage: UIButton!
    @IBOutlet weak var btClose: UIButton!
    @IBOutlet weak var lbDescription: UILabel!
    
    var openFrom: OpenFrom = .settings
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        initView()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    // MARK: Setup
    func initView() {
        if openFrom != .main {
            btClose.isHidden = false
            lbDescription.isHidden = true
            imgMasterPassword.isHidden = false
        } else {
            btClose.isHidden = true
            lbDescription.isHidden = false
            imgMasterPassword.isHidden = true
        }
    }
    
    func setup() {
        // MARK: Master Hash Null Check
        if let _ = KeyChainUtility.sharedInstance.getKeyChainObjectForKey(key: kMasterPasswordKey) as Record? {
            btSelectImage.setTitle("Update Master Password", for: .normal)
            if let masterImage = FileUtility.sharedInstance.readImageFromResources(directory: .documentDirectory, imageName: kMasterImage) {
                imgMasterPassword.image = masterImage
            } else {
                btSelectImage.setTitle("Generate Master Password", for: .normal)
            }
        } else {
            btSelectImage.setTitle("Generate Master Password", for: .normal)
        }
        imgMasterPassword.delegate = self
    }
    
    // MARK: Methods
    func generateMasterPassword(masterPassword: String) {
        KeyChainUtility.sharedInstance.setKeyChainStringForKey(object: masterPassword, key: kMasterPasswordKey)
    }

    func openImageToPasswordVC(image: UIImage) {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let imageToPasswordVC = storyboard.instantiateViewController(withIdentifier: String(describing: ImageToPasswordVC.self)) as! ImageToPasswordVC
            imageToPasswordVC.image = image
            imageToPasswordVC.key = kMasterPasswordKey
            imageToPasswordVC.delegate = self
            self.present(imageToPasswordVC, animated: true, completion: nil)
        }
    }
    
    func openTabbarController() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tabBarController = storyboard.instantiateViewController(withIdentifier: String(describing: TabBarController.self)) as! TabBarController
            tabBarController.modalPresentationStyle = .overFullScreen
            self.present(tabBarController, animated: true, completion: nil)
        }
    }
    
    // MARK: IBActions
    @IBAction func btSelectImageAction(_ sender: Any) {
        imgMasterPassword.showPhotoActionSheet(title: "Master Password", message: "Choose Photo")
    }

    @IBAction func btCloseAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension MasterVC: ImageToPasswordProtocol {
    func didSave(image: UIImage, hash: String, authenticationCount: Int) {
        let imageName = kMasterImage
        FileUtility.sharedInstance.writeImgetoResources(directory: .documentDirectory, image: image.fixOrientation(), imageName: imageName)
        let passObject = Record(id: kMasterPasswordKey,
                                  title: kMasterPasswordKey,
                                  imageAuthenticationHash: hash,
                                  password: nil,
                                  additionalData: nil,
                                  imageName: imageName,
                                  imageAuthenticationEnabled: true,
                                  touchCount: authenticationCount,
                                  createdDate: Date())
        KeyChainUtility.sharedInstance.setKeyChainObjectForKey(object: passObject, key: kMasterPasswordKey)
    }
    
    func masterSave() {
        if self.openFrom == .main {
            openTabbarController()
        } else {
            DispatchQueue.main.async {
                self.parentViewController?.dismiss(animated: false, completion: nil)
            }
        }
    }
}

extension MasterVC: PhotoViewProtocol {
    func didImageChanged() {
        if let image = imgMasterPassword.image {
            openImageToPasswordVC(image: image)
        }
    }
}
