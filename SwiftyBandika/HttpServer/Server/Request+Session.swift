//
// Created by Michael Rönnau on 07.04.21.
//

import Foundation

extension Request{

    public func setSessionAttribute(_ name: String, value: Any){
        session?.setAttribute(name, value: value)
    }

    public func removeSessionAttribute(_ name: String){
        session?.removeAttribute(name)
    }

    public func getSessionAttributeNames() -> Set<String>{
        session?.getAttributeNames() ?? Set<String>()
    }

    public func getSessionAttribute(_ name: String) -> Any?{
        session?.getAttribute(name)
    }

    public func getSessionAttribute<T>(_ name: String, type: T.Type) -> T?{
        getSessionAttribute(name) as? T
    }

    public func getSessionString(_ name: String, def : String = "") -> String{
        getSessionAttribute(name) as? String ?? def
    }

    public func getSessionInt(_ name: String, def: Int = -1) -> Int{
        if let i = getSessionAttribute(name) as? Int{
            return i
        }
        if let s = getSessionAttribute(name) as? String{
            return Int(s) ?? def
        }
        return def
    }

    public func getSessionBool(_ name: String) -> Bool{
        if let b = getSessionAttribute(name) as? Bool{
            return b
        }
        if let s = getSessionAttribute(name) as? String{
            return Bool(s) ?? false
        }
        return false
    }

}