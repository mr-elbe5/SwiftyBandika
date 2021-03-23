/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

extension Request{

    static let GROUP_KEY = "$GROUP"
    static let USER_KEY = "$USER"

    func setSessionGroup(_ group: GroupData){
        setSessionAttribute(Request.GROUP_KEY, value: group)
    }

    func getSessionGroup() -> GroupData?{
        getSessionAttribute(Request.GROUP_KEY, type: GroupData.self)
    }

    func removeSessionGroup(){
        removeSessionAttribute(Request.GROUP_KEY)
    }

    func setSessionUser(_ user: UserData){
        setSessionAttribute(Request.USER_KEY, value: user)
    }

    func getSessionUser() -> UserData?{
        getSessionAttribute(Request.USER_KEY, type: UserData.self)
    }

    func removeSessionUser(){
        removeSessionAttribute(Request.USER_KEY)
    }

}