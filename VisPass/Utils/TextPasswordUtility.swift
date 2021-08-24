//
//  TextPasswordUtility.swift
//  VisPass
//
//  Created by Nevzat TUFEKCI.
//

import Foundation

class TextPasswordUtility {
    static let sharedInstance = TextPasswordUtility()
    
    init() {
        length = getPasswordLength()
        specialCharacters = getSpecialCharacters()
    }
    
    var length = 12
    let alphanumericCharacters = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    var specialCharacters = "#@$&!?*."
    
    func generatePassword() -> String {
        var passwordSpecialCharacterSet = CharacterSet()
        passwordSpecialCharacterSet.insert(charactersIn: specialCharacters)
        let pswdChars = alphanumericCharacters + specialCharacters
        var randomPassword: String
        repeat {
            randomPassword = String((0..<length).compactMap{ _ in pswdChars.randomElement() })
        }
        while !randomPassword.containsCharacterIn(charSet: passwordSpecialCharacterSet) || !randomPassword.containsCharacterIn(charSet: CharacterSet.decimalDigits) || !randomPassword.containsCharacterIn(charSet: CharacterSet.lowercaseLetters) || !randomPassword.containsCharacterIn(charSet: CharacterSet.uppercaseLetters) || !(randomPassword.first!.isLetter || randomPassword.first!.isNumber)
        return randomPassword
    }
    
    // MARK: Methods
    @discardableResult
    func getPasswordLength() -> Int {
        let passwordLength = UserDefaults.standard.integer(forKey: kPasswordLength)
        if passwordLength > 0 {
            return passwordLength
        } else {
            return length
        }
    }
    
    func setPasswordLength(length :Int) {
        UserDefaults().setValue(length, forKey: kPasswordLength)
        UserDefaults.standard.synchronize()
        self.length = length
    }
    
    @discardableResult
    func getSpecialCharacters() -> String {
        if let passwordSpecialCharacters = UserDefaults.standard.string(forKey: kPasswordSpecialCharacters) {
            return passwordSpecialCharacters
        } else {
            return specialCharacters
        }
    }
    
    func setSpecialCharacters(specials: String) {
        if !specials.isEmpty {
            UserDefaults().setValue(specials, forKey: kPasswordSpecialCharacters)
            UserDefaults.standard.synchronize()
            specialCharacters = specials
        }
    }
    
}
