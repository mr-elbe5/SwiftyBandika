//
//  UserSecurity.swift
//  
//
//  Created by Michael Rönnau on 25.01.21.
//

import Foundation
import CryptoKit
import CommonCrypto

class UserSecurity{
    
    private static var rounds : UInt32 = 2205
    private static var keyByteCount : Int = 160
    
    static func encryptPassword(password : String, salt: String) -> String{
        var outputBytes = Array<UInt8>(repeating: 0, count: kCCKeySizeAES256)
        let status = CCKeyDerivationPBKDF(
            CCPBKDFAlgorithm(kCCPBKDF2),
            password,
            password.utf8.count,
            salt,
            salt.utf8.count,
            CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA1),
            rounds,
            &outputBytes,
            kCCKeySizeAES256)
        guard status == kCCSuccess else {
            return ""
        }
        return Data(outputBytes).base64EncodedString()
    }
    
    static func generateSalt() -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: 8)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return bytes
    }
    
    static func generateSaltString() -> String {
        Data(bytes: generateSalt(), count: 8).base64EncodedString()
    }
    
}
