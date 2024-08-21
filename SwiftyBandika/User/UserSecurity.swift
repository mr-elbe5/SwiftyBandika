/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

import Crypto

public class UserSecurity{
    
    private static var rounds : UInt32 = 2205
    private static var keyByteCount : Int = 160
    
    public static func verifyPassword(savedHash: String, password: String) -> Bool{
        let passwordHash : String = encryptPassword(password: password)
        if savedHash == passwordHash {
            return true
        }
        return false
    }
    
    public static func encryptPassword(password : String) -> String{
        let inputData = Data(password.utf8)
        let hashed = SHA256.hash(data: inputData)
        let hashString = hashed.compactMap{
            String(format: "%02x", $0)
        }.joined()
        Log.debug("password hash = \(hashString)")
        return hashString
    }
    

}
