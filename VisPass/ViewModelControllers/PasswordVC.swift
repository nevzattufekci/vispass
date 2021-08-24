//
//  PasswordVC.swift
//  VisPass
//
//  Created by Nevzat TUFEKCI.
//
// Inspired from https://stackoverflow.com/questions/27646107/how-to-check-if-the-user-gave-permission-to-use-the-camera

import UIKit
import AVFoundation
import Photos

protocol PasswordProtocol: NSObject {
    func refresh()
}

class PasswordVC: BaseViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var svPassword: UIScrollView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var lbPassword: UILabel!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btRandomPassword: UIButton!
    @IBOutlet weak var btCopy: UIButton!
    @IBOutlet weak var swImageAuthentication: UISwitch!
    @IBOutlet weak var btChooseImage: UIButton!
    @IBOutlet weak var viewImageHash: UIView!
    @IBOutlet weak var imgViewHash: UIImageView!
    @IBOutlet weak var lbAdditionalData: UILabel!
    @IBOutlet weak var txvAdditionalData: UITextView!
    @IBOutlet weak var txvView: UIView!
    @IBOutlet weak var btToglleAdditional: UIButton!
    @IBOutlet weak var btSave: UIButton!
    
    // MARK: Variables
    var record: Record?
    var hashKey: String?
    var imageName: String?
    var hashImage: UIImage?
    var passwordAuthenticationCount: Int?
    
    let btTooglePassword = UIButton(type: .custom)
    var imagePicker: UIImagePickerController!
    
    // MARK: Delegates
    weak var delegate: PasswordProtocol?
    
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
        
        hideKeyboardWhenTappedAround()
        txtTitle.addDoneButtonOnKeyboard()
        txtPassword.addDoneButtonOnKeyboard()
        txvAdditionalData.addDoneButtonOnKeyboard()
        registerForKeyboardWillShowNotification(scrollView: svPassword)
        registerForKeyboardWillHideNotification(scrollView: svPassword)
        btTooglePassword.tintColor = .black
        btTooglePassword.imageEdgeInsets = UIEdgeInsets(top: 0, left: -24, bottom: 0, right: 0)
        btTooglePassword.frame = CGRect(x: CGFloat(txtPassword.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
        btTooglePassword.addTarget(self, action: #selector(self.tooglePassword), for: .touchUpInside)
        txtPassword.rightView = btTooglePassword
        txtPassword.rightViewMode = .always
        
        initPassword()
        tooglePassword()
        toogleAdditional()
        toogleImageSwitch()
    }
    
    func resetView() {
        txtTitle.text = ""
        txtPassword.isSecureTextEntry = true
        txtPassword.text = ""
        tooglePassword()
        swImageAuthentication.isOn = false
        toogleImageSwitch()
        
        txvAdditionalData.text = ""
        txvAdditionalData.isSecureTextEntry = true
        toogleAdditional()
        txtTitle.resignFirstResponder()
        txvAdditionalData.resignFirstResponder()
        viewImageHash.isHidden = true
        view.endEditing(true)
        
        if let tabbar = tabBarController?.tabBar, tabbar.items?.count ?? 0 > 0 {
            tabBarController?.selectedIndex = 0
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func setup() {
        txtTitle.delegate = self
        txtPassword.delegate = self
        txvAdditionalData.delegate = self
    }
    
    // MARK: Methods
    func initPassword() {
        if let password = record {
            txtTitle.text = password.title
            txtPassword.text = password.password
            txvAdditionalData.text = password.additionalData
            swImageAuthentication.isOn = password.imageAuthenticationEnabled ?? false
            txtPassword.isSecureTextEntry = false
            txvAdditionalData.isSecureTextEntry = false
            
            if let strImageName = password.imageName, let image = FileUtility.sharedInstance.readImageFromResources(directory: .documentDirectory, imageName: strImageName) {
                hashImage = image
                imgViewHash.image = hashImage
                viewImageHash.isHidden = false
                hashKey = password.imageAuthenticationHash
                imageName = strImageName
                passwordAuthenticationCount = password.touchCount
            } else {
                viewImageHash.isHidden = true
                hashImage = nil
            }
        } else {
            txtPassword.isSecureTextEntry = true
            txvAdditionalData.isSecureTextEntry = true
        }
        
        
    }
    @objc func tooglePassword() {
        txtPassword.isSecureTextEntry = !txtPassword.isSecureTextEntry
        if txtPassword.isSecureTextEntry {
            btTooglePassword.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        } else {
            btTooglePassword.setImage(UIImage(systemName: "eye"), for: .normal)
        }
    }
    
    func toogleAdditional() {
        txvAdditionalData.isSecureTextEntry = !txvAdditionalData.isSecureTextEntry
        if txvAdditionalData.isSecureTextEntry {
            btToglleAdditional.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            txvView.addBlurEffect(style: .light)
        } else {
            btToglleAdditional.setImage(UIImage(systemName: "eye"), for: .normal)
            txvView.removeBlurEffect()
        }
    }
    
    func toogleImageSwitch() {
        if swImageAuthentication.isOn {
            btChooseImage.isHidden = false
        } else {
            btChooseImage.isHidden = true
            viewImageHash.isHidden = true
            hashImage = nil
            imageName = nil
            hashKey = nil
        }
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
    
    func choosePhoto(_ source: UIImagePickerController.SourceType) {
        DispatchQueue.main.async {
            if UIImagePickerController.isSourceTypeAvailable(source) {
                self.imagePicker =  UIImagePickerController()
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = source
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    func showPhotoActionSheet(title: String?, message: String?) -> Void {
        var alertStyle = UIAlertController.Style.actionSheet
        if (UIDevice.current.userInterfaceIdiom == .pad) {
          alertStyle = UIAlertController.Style.alert
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (_) in
            self.choosePhoto(.photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "From Camera", style: .default, handler: { (_) in
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
                if response {
                    self.choosePhoto(.camera)
                } else {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Info", message: "Please change camera access permissions from settings")
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Saved Photos", style: .default, handler: { (_) in
            self.choosePhoto(.savedPhotosAlbum)
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (_) in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: IBActions
    @IBAction func btToggleAdditional(_ sender: Any) {
        toogleAdditional()
    }
    @IBAction func btRandomPasswordAction(_ sender: Any) {
        txtPassword.text = TextPasswordUtility.sharedInstance.generatePassword()
    }
    @IBAction func btChooseImageAction(_ sender: Any) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        showPhotoActionSheet(title: "Image Password", message: "Choose Photo")
    }
    @IBAction func swImageAuthenticationAction(_ sender: Any) {
        toogleImageSwitch()
    }
    @IBAction func btSaveAction(_ sender: Any) {
        var id = UUID().uuidString
        if let pid = record?.id {
            id = pid
        }
        let title = txtTitle.text
        let securePassword = txtPassword.text
        let additionalData = txvAdditionalData.text
        let imageAuthenticationEnabled = swImageAuthentication.isOn
        let touchCount = passwordAuthenticationCount ?? 0
        let date = Date()
        let passObject = Record(id: id,
                                  title: title,
                                  imageAuthenticationHash: hashKey,
                                  password: securePassword,
                                  additionalData: additionalData,
                                  imageName: imageName,
                                  imageAuthenticationEnabled: imageAuthenticationEnabled,
                                  touchCount: touchCount,
                                  createdDate: date)
        
        
        if title?.isEmpty ?? true {
            showAlert(title: "Info", message: "Please Enter Title")
            return
        }
        
        if imageAuthenticationEnabled, hashImage == nil {
            showAlert(title: "Info", message: "Please Choose Image")
            return
        }
        
        if KeyChainUtility.sharedInstance.passwordDictionaryForKey(key: id, object: passObject) {
            resetView()
            delegate?.refresh()
        } else {
            showAlert(title: "Error", message: "Save Error")
        }
        
    }
    @IBAction func btCopyAction(_ sender: Any) {
        UIPasteboard.general.string = txtPassword.text
    }
}

extension PasswordVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true) {
            guard let selectedImage = info[.originalImage] as? UIImage else {
                print("Image not found!")
                return
            }
            if let cgImage = selectedImage.cgImage {
                DispatchQueue.main.async {
                    let image = UIImage(cgImage: cgImage, scale: selectedImage.scale, orientation: selectedImage.imageOrientation)
                    let imageName = UUID().uuidString
                    FileUtility.sharedInstance.writeImgetoResources(directory: .cachesDirectory, image: image.fixOrientation(), imageName: imageName)
                    self.imageName = imageName
                    if let img = FileUtility.sharedInstance.readImageFromResources(directory: .cachesDirectory, imageName: imageName) {
                        self.openImageToPasswordVC(image: img)
                    }
                }
               
            }
        }
    }
}

extension PasswordVC: ImageToPasswordProtocol {
    func didSave(image: UIImage, hash: String, authenticationCount: Int) {
        hashKey = hash
        passwordAuthenticationCount = authenticationCount
        hashImage = image
        FileUtility.sharedInstance.writeImgetoResources(directory: .documentDirectory, image: image, imageName: imageName ?? "")
        DispatchQueue.main.async {
            self.viewImageHash.isHidden = false
            self.imgViewHash.image = image
        }
    }
}

extension PasswordVC: UITextFieldDelegate, UITextViewDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
}
