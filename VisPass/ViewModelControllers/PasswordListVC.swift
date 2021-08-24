//
//  PasswordListVC.swift
//  VisPass
//
//  Created by Nevzat TUFEKCI.
//

import UIKit

enum AuthFor {
    case open
    case copy
    case master
}

class PasswordListVC: BaseViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var tvPasswordLİst: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: Variables
    var passwords: NSMutableDictionary?
    var keys: Array<Any>?
    var filteredKeys: Array<Any>?
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        initView()
        initVM()
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
    }
    
    func initVM() {
        fetchPasswords()
    }
    
    func setup() {
        tvPasswordLİst.delegate = self
        tvPasswordLİst.dataSource = self
        tvPasswordLİst.register(UINib(nibName: String(describing: PasswordCell.self), bundle: .main), forCellReuseIdentifier: String(describing: PasswordCell.self))
        searchBar.delegate = self
        (tabBarController?.viewControllers?.filter{ $0 is PasswordVC }.first as? PasswordVC)?.delegate = self
    }
    
    // MARK: Methods
    func reloadData() {
        DispatchQueue.main.async {
            self.tvPasswordLİst.reloadData()
        }
    }
    
    func fetchPasswords() {
        passwords = KeyChainUtility.sharedInstance.getKeyChainObjectForKey(key: kPasswords)
        keys = passwords?.sorted(by: { ($0.value as? Record)?.createdDate?.compare((($1.value as? Record)?.createdDate)!) == .orderedDescending }).compactMap({ password in
            return password.key
        })
        filteredKeys = keys
        reloadData()
    }
    
    func deletePassword(key: String) {
        KeyChainUtility.sharedInstance.passwordDictionaryForKey(key: key, object: nil)
    }
    
    func selectItem(indexPath: IndexPath) {
        guard let password = passwords?[filteredKeys?[indexPath.row]] as? Record else {
            return
        }
        if let authentication = password.imageAuthenticationEnabled, let imageName = password.imageName, let hashkey = password.imageAuthenticationHash, let image = FileUtility.sharedInstance.readImageFromResources(directory: .documentDirectory, imageName: imageName), authentication {
            openAuthenticateVC(image: image, password: password, authFor: .open)
            
        } else {
            openPasswordVC(password: password)
        }
    }
    
    func copyItem(indexPath: IndexPath) {
        guard let password = passwords?[filteredKeys?[indexPath.row]] as? Record else {
            return
        }
        if let authentication = password.imageAuthenticationEnabled, let imageName = password.imageName, let hashkey = password.imageAuthenticationHash, let image = FileUtility.sharedInstance.readImageFromResources(directory: .documentDirectory, imageName: imageName), authentication {
            openAuthenticateVC(image: image, password: password, authFor: .copy)
        }
        else {
            UIPasteboard.general.string = password.password
        }
        
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
    
    func openAuthenticateVC(image: UIImage, password: Record, authFor: AuthFor) {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let authenticateVC = storyboard.instantiateViewController(withIdentifier: String(describing: AuthenticateVC.self)) as! AuthenticateVC
            authenticateVC.image = image
            authenticateVC.record = password
            authenticateVC.delegate = self
            authenticateVC.authFor = authFor
            self.present(authenticateVC, animated: true, completion: nil)
        }
    }
}

extension PasswordListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredKeys?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let passwordCell = tvPasswordLİst.dequeueReusableCell(withIdentifier: String(describing: PasswordCell.self), for: indexPath) as! PasswordCell
        passwordCell.password = passwords?[filteredKeys?[indexPath.row]] as? Record
        return passwordCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectItem(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .none) {
            // handle delete (by removing the data from your array and updating the tableview)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { [weak self] action, view, complete in
            
            let alert = UIAlertController(title: "Info", message: "Are you sure to delete this record?", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "YES", style: .destructive, handler: { (alertActionYes) in
                if let key = self?.filteredKeys?[indexPath.row] {
                    self?.deletePassword(key: key as! String)
                    self?.fetchPasswords()
                    self?.searchBar.resignFirstResponder()
                    self?.searchBar.text = ""
                }
            }))
            alert.addAction(UIAlertAction(title: "NO", style: .default, handler: { (alertActionNo) in
            }))
            self?.present(alert, animated: true, completion: nil)
            complete(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .red
        
        let showAction = UIContextualAction(style: .normal, title: "Show") { [weak self] action, view, complete in
            self?.selectItem(indexPath: indexPath)
            complete(true)
        }
        showAction.image = UIImage(systemName: "eye")
        showAction.backgroundColor = UIColor(red: 190, green: 190, blue: 190)
        
        let copyAction = UIContextualAction(style: .normal, title: "Copy") { [weak self] action, view, complete in
            guard let password = self?.passwords?[self?.filteredKeys?[indexPath.row]] as? Record else {
                return
            }
            self?.copyItem(indexPath: indexPath)
            complete(true)
        }
        copyAction.image = UIImage(systemName: "doc.on.doc.fill")
        copyAction.backgroundColor = UIColor(red: 170, green: 170, blue: 170)
        
        var actions = UISwipeActionsConfiguration().actions
        actions.append(deleteAction)
        actions.append(showAction)
        actions.append(copyAction)
        
        return UISwipeActionsConfiguration(actions: actions)
    }
    
}

extension PasswordListVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let filteredPasswords = passwords?.filter({ (key: Any, value: Any) in
            let password = value as? Record
            if let title = password?.title {
                return title.uppercased().hasPrefix(searchText.uppercased())
            } else {
                return false
            }
        })
        
        filteredKeys = filteredPasswords?.compactMap({ (key: Any, value: Any) in
            return key
        })
        reloadData()
    }
}

extension PasswordListVC: PasswordProtocol {
    func refresh() {
        fetchPasswords()
    }
}
extension PasswordListVC: AuthenticateProtocol {
    func authenticate(authFor: AuthFor, password: Record?) {
        if authFor == .copy {
            self.dismiss(animated: true, completion: nil)
            UIPasteboard.general.string = password?.password
        } else {
            self.dismiss(animated: false, completion: nil)
            openPasswordVC(password: password)
        }
    }
}
