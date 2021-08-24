//
//  AuthenticateVC.swift
//  VisPass
//
//  Created by Nevzat TUFEKCI.
//

import UIKit

protocol AuthenticateProtocol: NSObject {
    func authenticate(authFor: AuthFor, password: Record?)
}

class AuthenticateVC: BaseViewController {
    
    // MARK: Variables
    var image: UIImage?
    var record: Record?
    var authFor: AuthFor = .open
    
    fileprivate var gridDrawed = false
    // MARK: IBOutlets
    @IBOutlet weak var imgViewHash: CryptoImageView!
    @IBOutlet weak var btAuthenticate: UIButton!
    
    // MARK: Delegates
    weak var delegate: AuthenticateProtocol?
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        initView()
    }
    
    // MARK: Setup
    func initView() {
        if !gridDrawed {
            imgViewHash.drawImageGrid()
            gridDrawed = true
        }
    }
    
    func setup() {
        imgViewHash.delegate = self
        imgViewHash.image = image
    }
    
    // MARK: Methods
    func reset() {
        imgViewHash.encryptedHash = nil
        imgViewHash.order = 0
    }
    
    func openPasswordVC(password: Record?) {
        if let password = password {
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let passwordVC = storyboard.instantiateViewController(withIdentifier: String(describing: PasswordVC.self)) as! PasswordVC
                passwordVC.record = password
                passwordVC.delegate = self
                self.present(passwordVC, animated: true, completion: nil)
            }
        }
    }
}

extension AuthenticateVC: PasswordProtocol {
    func refresh() {
    }
}
extension AuthenticateVC: CryptoImageProtocol {
    func selectImagePart(image: UIImage, rowIndex: Int, columnIndex: Int, order: Int) {
        if order == record?.touchCount {
            if let hash = imgViewHash.encryptedHash, hash == record?.imageAuthenticationHash {
                delegate?.authenticate(authFor:authFor, password: record)
            } else {
                DispatchQueue.main.async {
                    self.imgViewHash.removeCircle()
                    self.imgViewHash.encryptedHash = ""
                    self.showAlert(title: "Error", message: "Authentication Failed")
                }
            }
            reset()
        }
    }
}

