//
//  Crypto.swift
//  VisPass
//
//  Created by Nevzat TUFEKCI.
//
// Inspired from https://stackoverflow.com/questions/25388747/sha256-in-swift

import Foundation
import CommonCrypto

extension String {
    
    func sha256() -> Data? {
        guard let data = self.data(using: String.Encoding.utf8) else {
            return nil
        }
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash)
    }
}
