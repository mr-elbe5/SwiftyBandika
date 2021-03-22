//
//  DataContainer.swift
//  
//
//  Created by Michael Rönnau on 25.01.21.
//

import Foundation

class DataContainer : Codable{
    
    private enum DataContainerCodingKeys: CodingKey{
        case changeDate
        case version
    }
    
    var changeDate: Date
    var version: Int
    
    var changed = false
    
    required init(){
        changeDate = Date()
        version = 1
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: DataContainerCodingKeys.self)
        changeDate = try values.decode(Date.self, forKey: .changeDate)
        version = try values.decode(Int.self, forKey: .version)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DataContainerCodingKeys.self)
        try container.encode(changeDate, forKey: .changeDate)
        try container.encode(version, forKey: .version)
    }
    
    func increaseVersion() {
        version += 1;
    }
    
    func checkChanged(){
        fatalError("not implemented")
    }
    
    func setHasChanged() {
        if (!changed) {
            increaseVersion();
            changeDate = Date()
            changed = true;
            CheckDataAction.addToQueue()
        }
    }
    
    func save() -> Bool{
        fatalError("not implemented")
    }
    
    
}
