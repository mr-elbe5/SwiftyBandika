//
// Created by Michael Rönnau on 07.04.21.
//

import Foundation


extension Session{

    public static let USER_KEY = "$USER"

    public var user : UserData?{
        get{
            getAttribute(Session.USER_KEY) as? UserData
        }
        set{
            if let usr = newValue {
                setAttribute(Session.USER_KEY, value: usr)
            }
            else{
                removeAttribute(Session.USER_KEY)
            }
        }
    }

}
