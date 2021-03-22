//
//  Configuration.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 10.02.21.
//

import Foundation

class Preferences: DataContainer{

    static var instance = Preferences()

    static func initialize(){
        Log.info("initializing preferences")
        if !Files.fileExists(url: Paths.preferencesFile){
            instance.initDefaults()
            if !instance.save(){
                Log.error("could not save default preferences")
            }
            else {
                Log.info("created default preferences")
            }
        }
        if let str = Files.readTextFile(url: Paths.preferencesFile){
            if let preferences: Preferences = Preferences.fromJSON(encoded: str){
                instance = preferences
                Log.info("loaded preferences")
            }
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case serviceInterval
        case cleanupInterval
        
        func placeholder() -> String{
            "[\(self.rawValue.uppercased())]"
        }
    }

    var serviceInterval : Int = 5 //in min
    var cleanupInterval : Int = 10 //in min
    
    private let preferencesSemaphore = DispatchSemaphore(value: 1)
    
    required init(){
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        serviceInterval = try values.decodeIfPresent(Int.self, forKey: .serviceInterval) ?? 0
        cleanupInterval = try values.decodeIfPresent(Int.self, forKey: .cleanupInterval) ?? 0
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try super.encode(to: encoder)
        try container.encode(serviceInterval, forKey: .serviceInterval)
        try container.encode(cleanupInterval, forKey: .cleanupInterval)
    }
    
    private func lock(){
        preferencesSemaphore.wait()
    }
    
    private func unlock(){
        preferencesSemaphore.signal()
    }
    
    func initDefaults(){
        
    }

    override func checkChanged(){
        if (changed) {
            if save() {
                Log.info("preferences saved")
                changed = false;
            }
        }
    }
    
    override func save() -> Bool{
        Log.info("saving preferences")
        lock()
        defer{unlock()}
        let json = toJSON()
        if !Files.saveFile(text: json, url: Paths.preferencesFile){
            Log.warn("preferences file could not be saved")
            return false
        }
        return true
    }
    
}
