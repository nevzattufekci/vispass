//
//  MainVC.swift
//  VisPass
//
//  Created by Nevzat TUFEKCI.
//
// Inspired from https://www.codegrepper.com/code-examples/swift/authenticate+with+fingerprint+or+passcode+ios+swift

import UIKit
import LocalAuthentication

class MainVC: BaseViewController {
    
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
    }
    
    // MARK: Setup
    func setup() {
        if !UserDefaults.standard.bool(forKey: kInit) {
            KeyChainUtility.sharedInstance.deleteKeyChainObjectForKey(key: kMasterPasswordKey)
            KeyChainUtility.sharedInstance.deleteKeyChainObjectForKey(key: kPasswords)
            UserDefaults().set(true, forKey: kInit)
            UserDefaults().synchronize()
        }
        if let masterHash = KeyChainUtility.sharedInstance.getKeyChainObjectForKey(key: kMasterPasswordKey) as Record?, let masterImage = FileUtility.sharedInstance.readImageFromResources(directory: .documentDirectory, imageName: kMasterImage)  {
            if UserDefaults.standard.bool(forKey: kFaceId) {
                FaceId(image: masterImage, password: masterHash, authFor: .master)
            } else {
                openAuthenticateVC(image: masterImage, password: masterHash, authFor: .master)
            }
        } else {
            openMasterVC()
        }
    }
    
    // MARK: Methods
    func FaceId(image: UIImage, password: Record, authFor: AuthFor) {
        let context = LAContext()
            var error: NSError?

            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Identify yourself!"

                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                    [weak self] success, authenticationError in

                    DispatchQueue.main.async {
                        if success {
                            self?.openTabbarController()
                        } else {
                            self?.openAuthenticateVC(image: image, password: password, authFor: authFor)
                        }
                    }
                }
            } else {
                // no biometric authentication
                self.openAuthenticateVC(image: image, password: password, authFor: authFor)
            }
    }
    
    func openMasterVC() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let masterVC = storyboard.instantiateViewController(withIdentifier: String(describing: MasterVC.self)) as! MasterVC
            masterVC.modalPresentationStyle = .overFullScreen
            masterVC.openFrom = .main
            self.navigationController?.pushViewController(masterVC, animated: true)
        }
    }
    
    func openAuthenticateVC(image: UIImage, password: Record, authFor: AuthFor) {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let authenticateVC = storyboard.instantiateViewController(withIdentifier: String(describing: AuthenticateVC.self)) as! AuthenticateVC
            authenticateVC.image = image
            authenticateVC.record = password
            authenticateVC.delegate = self
            authenticateVC.authFor = authFor
            authenticateVC.modalPresentationStyle = .overFullScreen
            self.navigationController?.pushViewController(authenticateVC, animated: true)
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
}

extension MainVC: AuthenticateProtocol {
    func authenticate(authFor: AuthFor, password: Record?) {
        openTabbarController()
    }
}
