//
//  GroupData.swift
//  
//
//  Created by Michael Rönnau on 25.01.21.
//

import Foundation

class GroupData: BaseData{
    
    static var ID_ALL : Int = 0
    static var ID_GLOBAL_ADMINISTRATORS : Int = 1
    static var ID_GLOBAL_APPROVERS : Int = 2
    static var ID_GLOBAL_EDITORS : Int = 3
    static var ID_GLOBAL_READERS : Int = 4

    static var ID_MAX_FINAL : Int = 4
    
    private enum GroupDataCodingKeys: CodingKey{
        case name
        case notes
        case systemRights
        case userIds
    }
    
    var name: String
    var notes: String
    var systemRights: Array<SystemZone>
    var userIds: Array<Int>

    override var type : DataType{
        get {
            .group
        }
    }
    
    override init(){
        name = ""
        notes = ""
        systemRights = Array<SystemZone>()
        userIds = Array<Int>()
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: GroupDataCodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        notes = try values.decode(String.self, forKey: .notes)
        systemRights = try values.decode(Array<SystemZone>.self, forKey: .systemRights)
        userIds = try values.decode(Array<Int>.self, forKey: .userIds)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: GroupDataCodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(notes, forKey: .notes)
        try container.encode(systemRights, forKey: .systemRights)
        try container.encode(userIds, forKey: .userIds)
    }
    
    override func copyEditableAttributes(from data: TypedData) {
        super.copyEditableAttributes(from: data)
        if let groupData = data as? GroupData{
            name = groupData.name
            notes = groupData.notes
            systemRights = groupData.systemRights
            userIds = groupData.userIds
        }
    }
    
    func addUserId(_ id: Int){
        userIds.append(id)
    }
    
    func removeUserId(_ id: Int){
        userIds.remove(obj: id)
    }
    
    override func readRequest(_ request: Request) {
        super.readRequest(request)
        name = request.getString("name")
        notes = request.getString("notes")
        systemRights.removeAll()
        for zone in SystemZone.allCases {
            if request.getBool("zoneright_" + zone.rawValue){
                addSystemRight(zone: zone)
            }
        }
        userIds = request.getIntArray("userIds") ?? Array<Int>()
        if name.isEmpty {
            request.addIncompleteField("name")
        }
    }
    
    func addSystemRight(zone: SystemZone) {
        systemRights.append(zone)
    }
    
    func hasSystemRight(zone: SystemZone) -> Bool{
        systemRights.contains(zone)
    }
    
}

