//
// Created by Michael Rönnau on 19.03.21.
//

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