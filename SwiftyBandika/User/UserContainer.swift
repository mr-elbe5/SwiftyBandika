/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation


public class UserContainer : DataContainer{

    public static var instance = UserContainer()

    static  public func initialize(){
        Log.info("initializing users")
        if !Files.fileExists(path: Paths.usersFile){
            let defaultContainer = DefaultUserContainer()
            if !defaultContainer.save(){
                Log.error("could not save default user")
            }
            else {
                Log.info("created default user")
            }
        }
        if let str = Files.readTextFile(path: Paths.usersFile){
            if let container : UserContainer = UserContainer.fromJSON(encoded: str){
                instance = container
                Log.info("loaded users")
            }
        }
    }
    
    private enum UserContainerCodingKeys: CodingKey{
        case users
        case groups
    }
    
    public var users: Array<UserData>
    public var groups: Array<GroupData>
    
    private var userMap = Dictionary<Int, UserData>()
    private var userLoginMap = Dictionary<String, UserData>()
    private var groupMap = Dictionary<Int, GroupData>()
    
    private let userSemaphore = DispatchSemaphore(value: 1)
    
    public required init(){
        users = Array<UserData>()
        groups = Array<GroupData>()
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: UserContainerCodingKeys.self)
        users = try values.decode(Array<UserData>.self, forKey: .users)
        groups = try values.decode(Array<GroupData>.self, forKey: .groups)
        try super.init(from: decoder)
        mapGroups()
        mapUsers()
    }
    
    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: UserContainerCodingKeys.self)
        try container.encode(users, forKey: .users)
        try container.encode(groups, forKey: .groups)
    }
    
    private func lock(){
        userSemaphore.wait()
    }
    
    private func unlock(){
        userSemaphore.signal()
    }
    
    private func mapGroups() {
        groupMap.removeAll();
        for group: GroupData in groups{
            groupMap[group.id] = group
        }
        Log.info("groups mapped to ids")
    }
    
    private func mapUsers() {
        userMap.removeAll()
        for user: UserData in users{
            userMap[user.id] = user
            userLoginMap[user.login] = user
            for gid: Int in user.groupIds{
                if let group = getGroup(id: gid){
                    group.userIds.append(user.id)
                }
            }
        }
        Log.info("users mapped to ids")
    }
    
    public func getGroup(id: Int) -> GroupData?{
        groupMap[id]
    }
    
    public func addGroup(data: GroupData, userId: Int) -> Bool{
        lock()
        defer{unlock()}
        data.isNew = false
        groups.append(data)
        groupMap[data.id] =  data
        data.changerId = userId
        data.changeDate = Date()
        setHasChanged()
        return true
    }
    
    public func updateGroup(data: GroupData, userId: Int) -> Bool{
        var success = false
        lock()
        defer{unlock()}
        if let original : GroupData = getGroup(id: data.id){
            if original.version == data.version{
                removeGroupUsers(data: original)
                original.copyEditableAttributes(from: data)
                addGroupUsers(data: original)
                original.changerId = userId
                original.changeDate = Date()
                original.increaseVersion()
                setHasChanged()
                success = true
            }
        }
        return success
    }
    
    private func removeGroupUsers(data: GroupData){
        for userId in data.userIds {
            if let user = getUser(id: userId){
                user.removeGroupId(data.id)
            }
            else{
                Log.error("removing group from user: user not found: \(userId)")
            }
        }
    }
    
    private func addGroupUsers(data: GroupData){
        for userId in data.userIds{
            if let user = getUser(id: userId){
                user.addGroupId(data.id)
            }
            else{
                Log.error("adding group to user: user not found: \(userId)")
            }
        }
    }
    
    public func removeGroup(data: GroupData) -> Bool{
        lock()
        defer{unlock()}
        removeGroupUsers(data: data)
        for i in 0..<groups.count{
            if groups[i].id == data.id{
                groups.remove(at: i)
                break
            }
        }
        groupMap[data.id] = nil
        setHasChanged()
        return true
    }
    
    // users
    
    public func getUser(login: String, pwd: String) -> UserData?{
        if let data = userLoginMap[login]{
            if UserSecurity.verifyPassword(savedHash: data.passwordHash, password: pwd){
                return data
            }
        }
        return nil
    }
    
    public func getUser(id: Int) -> UserData?{
        userMap[id]
    }
    
    public func getUser(login: String) -> UserData?{
        userLoginMap[login]
    }
    
    // user changes
    
    public func addUser(data: UserData, userId: Int) -> Bool{
        lock()
        defer{unlock()}
        data.isNew = false
        users.append(data)
        userMap[data.id] = data
        userLoginMap[data.login] = data
        if !setUserToGroups(data: data){
            return false
        }
        data.changerId = userId
        data.changeDate = Date()
        setHasChanged()
        return true
    }
    
    public func updateUser(data: UserData, userId: Int) -> Bool{
        var success = false
        lock()
        defer{unlock()}
        if let original : UserData = getUser(id: data.id){
            if original.version == data.version {
                removeUserFromGroups(data: original)
                original.copyEditableAttributes(from: data)
                if !setUserToGroups(data: original){
                    return false
                }
                original.increaseVersion()
                original.changerId = userId
                original.changeDate = Date()
                setHasChanged()
                success = true
            }
            return success
            
        }
        return false
    }
    
    public func updateUserPassword(data: UserData, newPassword: String) -> Bool{
        var success = false
        lock()
        defer{unlock()}
        data.setPassword(password: newPassword)
        data.changerId = data.id
        data.changeDate = Date()
        data.increaseVersion()
        setHasChanged()
        success = true
        //unlock
        return success
    }
    
    private func removeUserFromGroups(data: UserData){
        for groupId in data.groupIds{
            if let group = getGroup(id: groupId){
                group.removeUserId(data.id)
            }
            else{
                Log.error("removing user from group: group not found: \(groupId)")
            }
        }
    }
    
    private func setUserToGroups(data: UserData) -> Bool{
        for groupId in data.groupIds{
            if let group = getGroup(id: groupId){
                group.addUserId(data.id)
            }
            else{
                Log.error("adding user to group: group not found: \(groupId)")
            }
        }
        return true;
        
    }
    
    public func removeUser(data: UserData) -> Bool{
        lock()
        defer{unlock()}
        removeUserFromGroups(data: data)
        for i in 0..<users.count{
            if users[i].id == data.id{
                users.remove(at: i)
                break
            }
        }
        userMap[data.id] = nil
        userLoginMap[data.login] = nil
        setHasChanged()
        return true
    }
    
    //persistance

    override public func checkChanged(){
        if (changed) {
            if save() {
                Log.info("users saved")
                changed = false
            }
        }
    }
    
    override public func save() -> Bool{
        Log.info("saving user data")
        lock()
        defer{unlock()}
        let json = toJSON()
        if !Files.saveFile(text: json, path: Paths.usersFile){
            Log.warn("users file could not be saved")
            return false
        }
        return true
    }
    
}


