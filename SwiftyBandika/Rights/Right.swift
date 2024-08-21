/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

public enum Right : Int, Codable{
    case NONE
    case READ
    case EDIT
    case APPROVE
    case FULL

    public func includesRight(right: Right) -> Bool{
        self.rawValue >= right.rawValue
    }

    public static func hasUserReadRight(user: UserData?, contentId : Int) -> Bool{
        if let data = ContentContainer.instance.getContent(id: contentId){
            if data.openAccess{
                return true
            }
            return hasUserReadRight(user: user, content: data)
        }
        return false
    }

    public static func hasUserReadRight(user: UserData?, content: ContentData) -> Bool{
        SystemZone.hasUserSystemRight(user: user,zone: SystemZone.contentRead) ||
                content.openAccess ||
                hasUserGroupRight(user: user, data: content, right: Right.READ)
    }

    public static func hasUserEditRight(user: UserData?, contentId: Int) -> Bool{
        if let data = ContentContainer.instance.getContent(id: contentId){
            return hasUserEditRight(user: user, content: data)
        }
        return false
    }

    public static func hasUserEditRight(user: UserData?, content: ContentData) -> Bool{
        SystemZone.hasUserSystemRight(user: user,zone: SystemZone.contentEdit) ||
                hasUserGroupRight(user: user, data: content, right: Right.EDIT)
    }

    public static func hasUserApproveRight(user: UserData?, contentId: Int) -> Bool{
        if let data = ContentContainer.instance.getContent(id: contentId){
            return hasUserApproveRight(user: user, content: data)
        }
        return false
    }

    public static func hasUserApproveRight(user: UserData?, content: ContentData) -> Bool{
        SystemZone.hasUserSystemRight(user: user,zone: SystemZone.contentApprove) ||
                hasUserGroupRight(user: user, data: content, right: Right.APPROVE)
    }

    public static func hasUserAnyGroupRight(user: UserData?, data: ContentData?) -> Bool{
        if let user = user, let data = data{
            for groupId in data.groupRights.keys{
                if user.groupIds.contains(groupId) && !data.groupRights.isEmpty{
                    return true
                }
            }
        }
        return false
    }

    public static func hasUserGroupRight(user: UserData?, data: ContentData?, right: Right) -> Bool{
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
