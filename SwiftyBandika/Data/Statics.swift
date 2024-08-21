/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation


public class Statics: Codable{

    public static var instance = Statics()

    public static var title = "Swifty Bandika"
    public static var startSize = NSMakeSize(1000, 750)

    public static func initialize(){
        Log.info("initializing statics")
        if !Files.fileExists(path: Paths.staticsFile){
            instance.initDefaults()
            if !instance.save(){
                Log.error("could not save statics")
            }
            else {
                Log.info("created statics")
            }
        }
        if let str = Files.readTextFile(path: Paths.staticsFile){
            if let statics : Statics = Statics.fromJSON(encoded: str){
                instance = statics
                Log.info("loaded app statics")
                if !statics.save(){
                    Log.warn("statics could not be saved")
                }
            }
        }
    }
    
    private enum SectionDataCodingKeys: CodingKey{
        case defaultPassword
        case cleanupInterval
        case shutdownCode
    }
    
    public var defaultPassword: String
    public var cleanupInterval : Int = 10
    public var shutdownCode : String

    public required init(){
        defaultPassword = UserSecurity.encryptPassword(password: "pass")
        shutdownCode = Statics.generateShutdownCode()
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: SectionDataCodingKeys.self)
        defaultPassword = try values.decodeIfPresent(String.self, forKey: .defaultPassword) ?? ""
        cleanupInterval = try values.decodeIfPresent(Int.self, forKey: .cleanupInterval) ?? 10
        shutdownCode = try values.decodeIfPresent(String.self, forKey: .shutdownCode) ?? Statics.generateShutdownCode()
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SectionDataCodingKeys.self)
        try container.encode(defaultPassword, forKey: .defaultPassword)
        try container.encode(shutdownCode, forKey: .shutdownCode)
    }
    
    public func initDefaults(){
        defaultPassword =  UserSecurity.encryptPassword(password: "pass")
        shutdownCode = Statics.generateShutdownCode()
    }
    
    public func save() -> Bool{
        Log.info("saving app statics")
        let json = toJSON()
        if !Files.saveFile(text: json, path: Paths.staticsFile){
            Log.warn("\(Paths.staticsFile) not saved")
            return false
        }
        return true
    }

    private static func generateShutdownCode() -> String {
        let code = String.generateRandomString(length: 8)
        Log.debug("generated shutdown code '\(code)'")
        return code
    }
    
}
