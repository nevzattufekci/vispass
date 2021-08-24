//
//  KeyChainUtility.swift
//  VisPass
//
//  Created by Nevzat TUFEKCI.
//
// Inspired from https://stackoverflow.com/questions/37539997/save-and-load-from-keychain-swift

import Foundation

final class KeyChainUtility {
    
    static let sharedInstance = KeyChainUtility()
    
    private let kSecClassValue = NSString(format: kSecClass)
    private let kSecAttrServiceValue = NSString(format: kSecAttrService)
    private let kSecAttrAccountValue = NSString(format: kSecAttrAccount)
    private let kSecValueDataValue = NSString(format: kSecValueData)
    private let kSecClassGenericPasswordValue = NSString(format: kSecClassGenericPassword)
    private let kSecAttrGenericValue = NSString(format: kSecAttrGeneric)
    private let kSecAttrAccessibleValue = NSString(format: kSecAttrAccessible)
    private let kSecAttrAccessibleAfterFirstUnlockThisDeviceOnlyValue = NSString(format: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
    private let kSecReturnDataValue = NSString(format: kSecReturnData)
    private let kSecMatchLimitValue = NSString(format: kSecMatchLimit)
    private let kSecMatchLimitOneValue = NSString(format: kSecMatchLimitOne)
    
    private let service = "VisPassService"
    
    private func prepareKeyChainDict(key: String) -> NSMutableDictionary {
        let keyData = key.data(using: String.Encoding.utf8)!
        return NSMutableDictionary(objects: [kSecClassGenericPasswordValue, service, keyData, keyData, kSecAttrAccessibleAfterFirstUnlockThisDeviceOnlyValue], forKeys: [kSecClassValue, kSecAttrServiceValue, kSecAttrAccountValue, kSecAttrGenericValue, kSecAttrAccessibleValue])
    }
    
    @discardableResult
    func deleteKeyChainObjectForKey(key: String) -> Bool {
        var result: Bool = false
        let keyChainDict  = prepareKeyChainDict(key: key)
        // Delete any existing items
        let status = SecItemDelete(keyChainDict as CFDictionary)
        if (status != errSecSuccess) {
            if #available(iOS 11.3, *) {
                if let err = SecCopyErrorMessageString(status, nil) {
                    print("Remove failed: \(err)")
                }
            }
        }
        else {
            result = true
        }
        return result
    }
    
    // MARK: String
    @discardableResult
    func getKeyChainStringForKey(key: String) -> String? {
        let keyChainDict  = prepareKeyChainDict(key: key)
        keyChainDict.setValue(kSecMatchLimitOneValue, forKey: kSecMatchLimitValue as String)
        keyChainDict.setValue(kCFBooleanTrue, forKey: kSecReturnDataValue as String)
        
        var dataTypeRef :AnyObject?
        
        // Search for the keychain items
        let status: OSStatus = SecItemCopyMatching(keyChainDict, &dataTypeRef)
        var contentsOfKeychain: String?
        
        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as? Data {
                contentsOfKeychain = String(data: retrievedData, encoding: String.Encoding.utf8)
            }
        }
        
        return contentsOfKeychain
    }
    
    @discardableResult
    func setKeyChainStringForKey(object: String?, key: String) -> Bool {
        if object != nil {
            let objectForKey = getKeyChainStringForKey(key: key)
            if(objectForKey != nil) {
                return updateKeyChainStringForKey(object: object!, key: key)
            }
            else {
                return insertKeyChainStringForKey(object: object!, key: key)
            }
        }
        else {
            return deleteKeyChainObjectForKey(key: key)
        }
        
    }
    
    @discardableResult
    private func insertKeyChainStringForKey(object: String, key: String ) -> Bool {
        var result: Bool = false
        let keyChainDict  = prepareKeyChainDict(key: key)
        
        if object.data(using: String.Encoding.utf8, allowLossyConversion: false) != nil {
            keyChainDict.setValue(object.data(using: String.Encoding.utf8), forKey: kSecValueDataValue as String)
            // Add the new keychain item
            let status = SecItemAdd(keyChainDict as CFDictionary, nil)
            if (status != errSecSuccess) {
                if #available(iOS 11.3, *) {
                    if let err = SecCopyErrorMessageString(status, nil) {
                        print("Write failed: \(err)")
                    }
                }
            }
            else {
                result = true
            }
        }
        return result
        
    }
    
    @discardableResult
    private func updateKeyChainStringForKey(object: String, key: String ) -> Bool {
        var result: Bool = false
        let keyChainDict  = prepareKeyChainDict(key: key)
        if let dataFromString: Data = object.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            
            let status = SecItemUpdate(keyChainDict as CFDictionary, [kSecValueDataValue:dataFromString] as CFDictionary)
            
            if (status != errSecSuccess) {
                if #available(iOS 11.3, *) {
                    if let err = SecCopyErrorMessageString(status, nil) {
                        print("Read failed: \(err)")
                    }
                }
            }
            else {
                result = true
            }
        }
        return result
    }
    
    
    // MARK: NSCoding
    @discardableResult
    func setKeyChainObjectForKey<T: NSCoding>(object: T?, key: String) -> Bool {
        if object != nil {
            let objectForKey = getKeyChainObjectForKey(key: key) as T?
            if(objectForKey != nil) {
                return updateKeyChainObjectForKey(object: object!, key: key)
            }
            else {
                return insertKeyChainObjectForKey(object: object!, key: key)
            }
        }
        else {
            return deleteKeyChainObjectForKey(key: key)
        }
        
    }
    
    @discardableResult
    func getKeyChainObjectForKey<T: NSCoding>(key: String) -> T? {
        let keyChainDict  = prepareKeyChainDict(key: key)
        keyChainDict.setValue(kSecMatchLimitOneValue, forKey: kSecMatchLimitValue as String)
        keyChainDict.setValue(kCFBooleanTrue, forKey: kSecReturnDataValue as String)
        
        var dataTypeRef :AnyObject?
        
        // Search for the keychain items
        let status: OSStatus = SecItemCopyMatching(keyChainDict, &dataTypeRef)
        var contentsOfKeychain: T?
        
        
        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as? Data {
                do {
                    try contentsOfKeychain = NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(retrievedData) as? T
                } catch  {
                    print(error.localizedDescription)
                }
                
            }
        }
        
        return contentsOfKeychain
    }
    
    @discardableResult
    private func insertKeyChainObjectForKey<T: NSCoding>(object: T, key: String ) -> Bool {
        var result: Bool = false
        let keyChainDict  = prepareKeyChainDict(key: key)
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: false)
            keyChainDict.setValue(data, forKey: kSecValueDataValue as String)
            let status = SecItemAdd(keyChainDict as CFDictionary, nil)
            if (status != errSecSuccess) {
                if #available(iOS 11.3, *) {
                    if let err = SecCopyErrorMessageString(status, nil) {
                        print("Write failed: \(err)")
                    }
                }
            }
            else {
                result = true
            }
        } catch {
            print(error.localizedDescription)
            result = false
        }
        return result
    }
    
    @discardableResult
    private func updateKeyChainObjectForKey<T: NSCoding>(object: T, key: String ) -> Bool {
        var result: Bool = false
        let keyChainDict  = prepareKeyChainDict(key: key)
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: false)
            let status = SecItemUpdate(keyChainDict as CFDictionary, [kSecValueDataValue:data] as CFDictionary)
            if (status != errSecSuccess) {
                if #available(iOS 11.3, *) {
                    if let err = SecCopyErrorMessageString(status, nil) {
                        print("Read failed: \(err)")
                    }
                }
            }
            else {
                result = true
            }
        } catch  {
            
        }
        return result
    }
    
    // MARK: NSMutableDictionary
    @discardableResult
    func passwordDictionaryForKey(key: String, object: Record?) -> Bool {
        if let dict = getKeyChainObjectForKey(key: kPasswords) as NSMutableDictionary? {
            dict[key] = object
            return setKeyChainObjectForKey(object: dict, key: kPasswords)
        }
        let newDict: NSMutableDictionary = [key: object]
        return setKeyChainObjectForKey(object: newDict, key: kPasswords)
    }
}
