//
//  SettingsVC.swift
//  VisPass
//
//  Created by Nevzat TUFEKCI.
//

import UIKit
import LocalAuthentication

class SettingsVC: BaseViewController {

    // MARK: IBOutlets
    @IBOutlet weak var txtPasswordLength: UITextField!
    @IBOutlet weak var stpPasswordLength: UIStepper!
    @IBOutlet weak var btPasswordSave: UIButton!
    @IBOutlet weak var txtSpecialChars: UITextField!
    @IBOutlet weak var btUpdateMasterPassword: UIButton!
    @IBOutlet weak var swFaceId: UISwitch!
    @IBOutlet weak var stackFaceId: UIStackView!
    
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
        let length = Double(TextPasswordUtility.sharedInstance.getPasswordLength())
        stpPasswordLength.value = length
        txtPasswordLength.text = String(Int(length))
        txtSpecialChars.text = TextPasswordUtility.sharedInstance.getSpecialCharacters()
        txtSpecialChars.addDoneButtonOnKeyboard()
        swFaceId.isOn = getFaceId()
    }
    
    func setup() {
        hideKeyboardWhenTappedAround()
        if LAContext().biometricType == .faceID {
            stackFaceId.isHidden = false
        } else {
            stackFaceId.isHidden = true
        }
    }
    
    // MARK: Methods
    func setFaceId(isActive :Bool) {
        UserDefaults().setValue(isActive, forKey: kFaceId)
        UserDefaults.standard.synchronize()
    }
    
    func getFaceId() -> Bool {
        return UserDefaults.standard.bool(forKey: kFaceId)
    }
    func openMasterVC() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let masterVC = storyboard.instantiateViewController(withIdentifier: String(describing: MasterVC.self)) as! MasterVC
            masterVC.modalPresentationStyle = .overFullScreen
            masterVC.openFrom = .settings
            self.present(masterVC, animated: true, completion: nil)
        }
    }
    
    // MARK: IBActions
    @IBAction func swFaceIdAction(_ sender: Any) {
        setFaceId(isActive: swFaceId.isOn)
    }
    @IBAction func stpLengthAction(_ sender: Any) {
        txtPasswordLength.text = String(Int(stpPasswordLength.value))
    }
    @IBAction func btSavePasswordSettingsAction(_ sender: Any) {
        view.endEditing(true)
        TextPasswordUtility.sharedInstance.setSpecialCharacters(specials: txtSpecialChars.text!)
        TextPasswordUtility.sharedInstance.setPasswordLength(length: Int(txtPasswordLength.text ?? "0") ?? 0)
        self.showAlert(title: "Info", message: "New Password Settings Saved")
        
    }
    @IBAction func btUpdatePasswordAction(_ sender: Any) {
        openMasterVC()
    }
}
