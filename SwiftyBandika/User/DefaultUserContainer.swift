//
//  File.swift
//  
//
//  Created by Michael Rönnau on 01.02.21.
//

import Foundation

class DefaultUserContainer : UserContainer{
    
    required init(){
        super.init()
        Log.info("creating root user")
        changeDate = Date()
        initializeRootUser()
        Log.info("creating default groups")
        initializeDefaultGroups()
    }
    
    required init(from decoder: Decoder) throws {
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
