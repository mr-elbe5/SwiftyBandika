//
//  Configuration.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 10.02.21.
//

import Foundation

class Configuration: DataContainer{

    static var instance = Configuration()

    static func initialize(){
        Log.info("initializing configuration")
        if !Files.fileExists(url: Paths.configFile){
            let config = Configuration()
            if !config.save(){
                Log.error("could not save default configuration")
            }
            else {
                Log.info("created default configuration")
            }
        }
        if let str = Files.readTextFile(url: Paths.configFile){
            if let config : Configuration = Configuration.fromJSON(encoded: str){
                instance = config
                Log.info("loaded app configuration")
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case host
        case webPort
        case applicationName
        case autostart
        
        func placeholder() -> String{
            "[\(self.rawValue.uppercased())]"
        }
    }

    var host : String
    var webPort : Int
    var applicationName : String
    var autostart = false
    
    private let configSemaphore = DispatchSemaphore(value: 1)
    
    required init(){
        host = "localhost"
        webPort = 8080
        applicationName = "SwiftyBandika"
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        host = try values.decodeIfPresent(String.self, forKey: .host) ?? "localhost"
        webPort = try values.decodeIfPresent(Int.self, forKey: .webPort) ?? 0
        applicationName = try values.decodeIfPresent(String.self, forKey: .applicationName) ?? "SwiftyBandika"
        autostart = try values.decodeIfPresent(Bool.self, forKey: .autostart) ?? false
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try super.encode(to: encoder)
        try container.encode(host, forKey: .host)
        try container.encode(webPort, forKey: .webPort)
        try container.encode(applicationName, forKey: .applicationName)
        try container.encode(autostart, forKey: .autostart)
    }
    
    private func lock(){
        configSemaphore.wait()
    }
    
    private func unlock(){
        configSemaphore.signal()
    }

    override func checkChanged(){
        if (changed) {
            if save() {
                Log.info("configuration saved")
                changed = false;
            }
        }
    }
    
    override func save() -> Bool{
        Log.info("saving configuration")
        lock()
        defer{unlock()}
        let json = toJSON()
        if !Files.saveFile(text: json, url: Paths.configFile){
            Log.warn("config file could not be saved")
            return false
        }
        return true
    }
    
}
