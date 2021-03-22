//
//  Right.swift
//  
//
//  Created by Michael Rönnau on 28.01.21.
//

import Foundation

enum Right : Int, Codable{
    case NONE
    case READ
    case EDIT
    case APPROVE
    case FULL

    func includesRight(right: Right) -> Bool{
        self.rawValue >= right.rawValue
    }

    static func hasUserReadRight(user: UserData?, contentId : Int) -> Bool{
        if let data = ContentContainer.instance.getContent(id: contentId){
            if data.openAccess{
                return true
            }
            return hasUserReadRight(user: user, content: data)
        }
        return false
    }

    static func hasUserReadRight(user: UserData?, content: ContentData) -> Bool{
        SystemZone.hasUserSystemRight(user: user,zone: SystemZone.contentRead) ||
                content.openAccess ||
                hasUserGroupRight(user: user, data: content, right: Right.READ)
    }

    static func hasUserEditRight(user: UserData?, contentId: Int) -> Bool{
        if let data = ContentContainer.instance.getContent(id: contentId){
            return hasUserEditRight(user: user, content: data)
        }
        return false
    }

    static func hasUserEditRight(user: UserData?, content: ContentData) -> Bool{
        SystemZone.hasUserSystemRight(user: user,zone: SystemZone.contentEdit) ||
                hasUserGroupRight(user: user, data: content, right: Right.EDIT)
    }

    static func hasUserApproveRight(user: UserData?, contentId: Int) -> Bool{
        if let data = ContentContainer.instance.getContent(id: contentId){
            return hasUserApproveRight(user: user, content: data)
        }
        return false
    }

    static func hasUserApproveRight(user: UserData?, content: ContentData) -> Bool{
        SystemZone.hasUserSystemRight(user: user,zone: SystemZone.contentApprove) ||
                hasUserGroupRight(user: user, data: content, right: Right.APPROVE)
    }

    static func hasUserAnyGroupRight(user: UserData?, data: ContentData?) -> Bool{
        if let user = user, let data = data{
            for groupId in data.groupRights.keys{
                if user.groupIds.contains(groupId) && !data.groupRights.isEmpty{
                    return true
                }
            }
        }
        return false
    }

    static func hasUserGroupRight(user: UserData?, data: ContentData?, right: Right) -> Bool{
        if let user = user, let data = data{
            for groupId in data.groupRights.keys{
                if user.groupIds.contains(groupId) && data.groupRights[groupId]!.includesRight(right: right){
                    return true
                }
            }
        }
        return false
    }
}
