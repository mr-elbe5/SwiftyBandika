//
//  AppStatics.swift
//  
//
//  Created by Michael Rönnau on 02.02.21.
//

import Foundation

class Statics: Codable{

    static var instance = Statics()

    static var title = "Swifty Bandika"
    static var startSize = NSMakeSize(1000, 750)

    static func initialize(){
        Log.info("initializing statics")
        if !Files.fileExists(url: Paths.staticsFile){
            instance.initDefaults()
            if !instance.save(){
                Log.error("could not save statics")
            }
            else {
                Log.info("created statics")
            }
        }
        if let str = Files.readTextFile(url: Paths.staticsFile){
            if let statics : Statics = Statics.fromJSON(encoded: str){
                instance = statics
                Log.info("loaded app statics")
            }
        }
    }
    
    private enum SectionDataCodingKeys: CodingKey{
        case salt
        case defaultPassword
        case defaultLocale
    }
    
    var salt: String
    var defaultPassword: String
    var defaultLocale: Locale
    
    required init(){
        salt = ""
        defaultPassword = ""
        defaultLocale = Locale(identifier: "en")
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: SectionDataCodingKeys.self)
        salt = try values.decode(String.self, forKey: .salt)
        defaultPassword = try values.decode(String.self, forKey: .defaultPassword)
        defaultLocale = try values.decode(Locale.self, forKey: .defaultLocale)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SectionDataCodingKeys.self)
        try container.encode(salt, forKey: .salt)
        try container.encode(defaultPassword, forKey: .defaultPassword)
        try container.encode(defaultLocale, forKey: .defaultLocale)
    }
    
    func initDefaults(){
        salt = UserSecurity.generateSaltString()
        defaultPassword =  UserSecurity.encryptPassword(password: "pass", salt: salt)
        defaultLocale = Locale(identifier: "en")
    }
    
    func save() -> Bool{
        Log.info("saving app statics")
        let json = toJSON()
        if !Files.saveFile(text: json, url: Paths.staticsFile){
            Log.warn("app statics could not be saved")
            return false
        }
        return true
    }
    
}