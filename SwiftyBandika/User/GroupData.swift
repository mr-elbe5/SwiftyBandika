/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation


public class GroupData: BaseData{
    
    public static var ID_ALL : Int = 0
    public static var ID_GLOBAL_ADMINISTRATORS : Int = 1
    public static var ID_GLOBAL_APPROVERS : Int = 2
    public static var ID_GLOBAL_EDITORS : Int = 3
    public static var ID_GLOBAL_READERS : Int = 4

    public static var ID_MAX_FINAL : Int = 4
    
    private enum GroupDataCodingKeys: CodingKey{
        case name
        case notes
        case systemRights
        case userIds
    }
    
    public var name: String
    public var notes: String
    public var systemRights: Array<SystemZone>
    public var userIds: Array<Int>

    override public var type : DataType{
        get {
            .group
        }
    }
    
    override public init(){
        name = ""
        notes = ""
        systemRights = Array<SystemZone>()
        userIds = Array<Int>()
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: GroupDataCodingKeys.self)
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        notes = try values.decodeIfPresent(String.self, forKey: .notes) ?? ""
        systemRights = try values.decodeIfPresent(Array<SystemZone>.self, forKey: .systemRights) ?? Array<SystemZone>()
        userIds = try values.decodeIfPresent(Array<Int>.self, forKey: .userIds) ?? Array<Int>()
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: GroupDataCodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(notes, forKey: .notes)
        try container.encode(systemRights, forKey: .systemRights)
        try container.encode(userIds, forKey: .userIds)
    }
    
    override public func copyEditableAttributes(from data: TypedData) {
        super.copyEditableAttributes(from: data)
        if let groupData = data as? GroupData{
            name = groupData.name
            notes = groupData.notes
            systemRights = groupData.systemRights
            userIds = groupData.userIds
        }
    }
    
    public func addUserId(_ id: Int){
        userIds.append(id)
    }
    
    public func removeUserId(_ id: Int){
        userIds.remove(obj: id)
    }
    
    override public func readRequest(_ request: Request) {
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
    
    public func addSystemRight(zone: SystemZone) {
        systemRights.append(zone)
    }
    
    public func hasSystemRight(zone: SystemZone) -> Bool{
        systemRights.contains(zone)
    }
    
}

