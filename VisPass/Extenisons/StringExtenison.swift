//
//  StringExtenison.swift
//  VisPass
//
//  Created by Nevzat TUFEKCI on 20.07.2021.
//

import Foundation

extension String {
    
    func containsCharacterIn(charSet: CharacterSet) -> Bool {
        return self.rangeOfCharacter(from: charSet) != nil ? true : false
    }
}
