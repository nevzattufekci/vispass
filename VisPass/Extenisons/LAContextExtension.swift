//
//  LAContextExtension.swift
//  VisPass
//
//  Created by Nevzat TUFEKCI.
//
// Inspired from https://stackoverflow.com/questions/46887547/how-to-programmatically-check-support-of-face-id-and-touch-id

import LocalAuthentication

extension LAContext {
    enum BiometricType: String {
        case none
        case touchID
        case faceID
    }

    var biometricType: BiometricType {
        var error: NSError?

        guard self.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }

        if #available(iOS 11.0, *) {
            switch self.biometryType {
            case .none:
                return .none
            case .touchID:
                return .touchID
            case .faceID:
                return .faceID
            @unknown default:
                #warning("Handle new Biometric type")
            }
        }
        
        return  self.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ? .touchID : .none
    }
}
