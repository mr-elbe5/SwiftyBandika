/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation


public class DefaultUserContainer : UserContainer{
    
    public required init(){
        super.init()
        Log.info("creating root user")
        changeDate = Date()
        initializeRootUser()
        Log.info("creating default groups")
        initializeDefaultGroups()
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    private func initializeRootUser(){
        let user = UserData()
        user.isNew = true
        user.creationDate = Date()
        user.creatorId = UserData.ID_ROOT
        user.id = UserData.ID_ROOT
        user.lastName = "Administrator"
        user.email = "admin@myhost.tld"
        user.login = "root"
        user.setPassword(password: "pass")
        _ = addUser(data: user,userId: UserData.ID_ROOT)
    }
    
    private func initializeDefaultGroups(){
        var group = GroupData()
        group.isNew = true
        group.creationDate = Date()
        group.creatorId = UserData.ID_ROOT
        group.id = GroupData.ID_GLOBAL_ADMINISTRATORS
        group.name = "Administrators"
        _ = addGroup(data: group,userId: UserData.ID_ROOT)
        group = GroupData()
        group.isNew = true
        group.creationDate = Date()
        group.creatorId = UserData.ID_ROOT
        group.id = GroupData.ID_GLOBAL_APPROVERS
        group.name = "Approvers"
        _ = addGroup(data: group,userId: UserData.ID_ROOT)
        group = GroupData()
        group.isNew = true
        group.creationDate = Date()
        group.creatorId = UserData.ID_ROOT
        group.id = GroupData.ID_GLOBAL_EDITORS
        group.name = "Editors"
        _ = addGroup(data: group,userId: UserData.ID_ROOT)
        group = GroupData()
        group.isNew = true
        group.creationDate = Date()
        group.creatorId = UserData.ID_ROOT
        group.id = GroupData.ID_GLOBAL_READERS
        group.name = "Readers"
        _ = addGroup(data: group,userId: UserData.ID_ROOT)
    }
    
}
