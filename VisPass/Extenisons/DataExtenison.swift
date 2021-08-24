//
//  DataExtenison.swift
//  VisPass
//
//  Created by Nevzat TUFEKCI.
//
// Inspired from https://stackoverflow.com/questions/25388747/sha256-in-swift

import Foundation
import CommonCrypto

extension Data {
    func toBase64() -> String? {
        return self.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
    
    func sha256() -> Data? {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        self.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(self.count), &hash)
        }
        return Data(hash)
    }
}
