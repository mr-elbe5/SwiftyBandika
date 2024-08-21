/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

public enum SystemZone : String, Codable, CaseIterable{
    case user
    case contentRead
    case contentEdit
    case contentApprove

    public static func hasUserAnySystemRight(user: UserData?) -> Bool {
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

    public static func hasUserSystemRight(user: UserData?, zone: SystemZone) -> Bool{
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
