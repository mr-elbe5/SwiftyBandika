/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

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
