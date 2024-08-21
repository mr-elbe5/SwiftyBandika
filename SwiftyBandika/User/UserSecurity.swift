import Foundation
import CommonCrypto

public class UserSecurity{
    
    public static func verifyPassword(savedHash: String, password: String) -> Bool{
        let passwordHash : String = encryptPassword(password: password)
        if savedHash == passwordHash {
            return true
        }
        return false
    }
    
    public static func encryptPassword(password : String) -> String{
        let hashed = sha256(str: password)
        Log.debug("password hash = \(hashed)")
        return hashed
    }
    
    static func sha256(str: String) -> String {
        if let strData = str.data(using: .utf8) {
            var digest = [UInt8](repeating: 0, count:Int(CC_SHA256_DIGEST_LENGTH))
            let _ = strData.withUnsafeBytes {
                CC_SHA256($0.baseAddress, UInt32(strData.count), &digest)
            }
            var sha256String = ""
            for byte in digest {
                sha256String += String(format:"%02x", UInt8(byte))
            }
            return sha256String
        }
        return ""
    }

}
