/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation
import NIO
import NIOHTTP1


public class Request {
    
    public var path: String = ""
    public var method: HTTPMethod = .GET
    public var uri: String = ""
    public var headers: [String: String] = [:]
    public var language = "en"
    public var bytes = [UInt8]()
    public var params: [String: Any] = [:]
    public var files = [String:MemoryFile]()
    public var session : Session? = nil

    // page related
    public var viewType : ViewType = .show
    public var message : Message? = nil
    public var formError: FormError? = nil
    public var pageParams = [String: String]()
    public var pageObjects = [String: Any]()

    public var address : String?{
        get{
            headers["host"]
        }
    }

    public var referer : String?{
        get{
            headers["referer"]
        }
    }

    public var userAgent : String?{
        get{
            headers["user-agent"]
        }
    }

    public var accept : String?{
        get{
            headers["accept"]
        }
    }

    public var acceptLanguage : String?{
        get{
            headers["accept-language"]
        }
    }

    public var keepAlive : Bool{
        get{
            headers["connection"] == "keep-alive"
        }
    }

    public var contentTypeTokens : [String]{
        get{
            if let contentTypeHeader = headers["content-type"]{
                return contentTypeHeader.components(separatedBy: ";").map { $0.trimmingCharacters(in: .whitespaces) }
            }
            return []
        }
    }

    public var contentType : String{
        get{
            let tokens = contentTypeTokens
            return tokens.first ?? ""
        }
    }

    public var contentLength : Int?{
        get{
            Int(headers["content-length"] ?? "")
        }
    }

    public var sessionId: String{
        get{
            if let cookies = headers["cookie"]?.split(";"){
                for cookie in cookies{
                    let cookieParts = cookie.split("=")
                    if cookieParts[0].trim().lowercased() == "sessionid"{
                        return cookieParts[1].trim()
                    }
                }
            }
            return ""
        }
    }

    public var hasMessage: Bool {
        get {
            message != nil
        }
    }

    public var hasFormError: Bool {
        get {
            formError != nil && !formError!.isEmpty
        }
    }

    public init(){
    }

    public func setLanguage(){
        if var lang = acceptLanguage{
            lang = lang.lowercased()
            if lang.count > 2{
                lang = String(lang[lang.startIndex...lang.index(lang.startIndex, offsetBy: 1)])
            }
            language = lang
        }
        else {
            language = "en"
        }
    }

    public func setParam(_ name: String, _ value: Any){
        params[name] = value
    }

    public func removeParam(_ name: String){
        params[name] = nil
    }

    public func getParam(_ name: String) -> Any?{
        params[name]
    }

    public func getParam<T>(_ name: String, type: T.Type) -> T?{
        getParam(name) as? T
    }

    public func getString(_ name: String, def: String = "") -> String{
        if let s = getParam(name) as? String {
            return s
        }
        if let arr = getParam(name) as? Array<String> {
            return arr.first ?? def
        }
        return def
    }

    public func getStringArray(_ name: String) -> Array<String>?{
        getParam(name) as? Array<String>
    }

    public func getInt(_ name: String, def: Int = -1) -> Int{
        let s = getString(name)
        return Int(s) ?? def
    }

    public func getIntArray(_ name: String) -> Array<Int>?{
        if let stringSet = getStringArray(name){
            var array = Array<Int>()
            for s in stringSet{
                if let i = Int(s){
                    array.append(i)
                }
            }
            return array
        }
        return nil
    }

    public func getBool(_ name: String) -> Bool{
        let s = getString(name)
        return Bool(s) ?? false
    }

    public func getFile(_ name: String) -> MemoryFile?{
        files[name]
    }

    public func dump() {
        Log.debug(">>request data:")
        Log.debug("method = \(method.rawValue)")
        Log.debug("uri = \(uri)")
        Log.debug("path = \(path)")
        Log.debug("params = \(params)")
        Log.debug("address = \(address ?? "")")
        Log.debug("referer = \(referer ?? "")")
        Log.debug("user agent = \(userAgent ?? "")")
        Log.debug("keepAlive = \(keepAlive)")
        Log.debug("contentType = \(contentType)")
        Log.debug("content length = \(contentLength ?? -1)")
        Log.debug("sessionId = \(sessionId)")
        if session != nil {
            Log.debug("sessionAttributes = \(session!.attributes)")
        }
        Log.debug("<<end request data")
    }

    public func dumpPageVars() {
        Log.debug(">>request page data:")
        Log.debug("pageParams = \(pageParams)")
        Log.debug("pageObjects = \(pageObjects)")
        Log.debug("<<end request")
    }

}
