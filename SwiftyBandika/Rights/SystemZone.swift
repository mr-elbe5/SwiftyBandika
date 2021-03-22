//
//  SystemZone.swift
//  
//
//  Created by Michael Rönnau on 25.01.21.
//

import Foundation

enum SystemZone : String, Codable, CaseIterable{
    case user
    case contentRead
    case contentEdit
    case contentApprove

    static func hasUserAnySystemRight(user: UserData?) -> Bool {
        if let data = user{
            if data.isRoot {
                return true
            }
            for groupId in data.groupIds{
                if let group = UserContainer.instance.getGroup(id: groupId){
                    if !group.systemRights.isEmpty{
                        return true
                    }
                }
            }
        }
        return false
    }

    static func hasUserSystemRight(user: UserData?, zone: SystemZone) -> Bool{
        if let data = user{
            if data.isRoot {
                return true
            }
            for groupId in data.groupIds {
                if let group = UserContainer.instance.getGroup(id: groupId){
                    if group.systemRights.contains(zone){
                        return true
                    }
                }
            }
        }
        return false
    }
}
