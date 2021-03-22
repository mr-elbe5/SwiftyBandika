//
//  HttpRequest.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 28.02.21.
//

import Foundation
import NIO
import NIOHTTP1

class Request {
    
    var path: String = ""
    var method: HTTPMethod = .GET
    var uri: String = ""
    var headers: [String: String] = [:]
    var bytes = [UInt8]()
    var params: [String: Any] = [:]
    var files = [String:MemoryFile]()
    var session : Session? = nil
    var viewType : ViewType = .show
    var message : Message? = nil
    var formError: FormError? = nil
    var pageVars = [String: String]()

    var address : String?{
        get{
            headers["host"]
        }
    }

    var referer : String?{
        get{
            headers["referer"]
        }
    }

    var userAgent : String?{
        get{
            headers["user-agent"]
        }
    }

    var accept : String?{
        get{
            headers["accept"]
        }
    }

    var acceptLanguage : String?{
        get{
            headers["accept-language"]
        }
    }

    var keepAlive : Bool{
        get{
            headers["connection"] == "keep-alive"
        }
    }

    var contentTypeTokens : [String]{
        get{
            if let contentTypeHeader = headers["content-type"]{
                return contentTypeHeader.components(separatedBy: ";").map { $0.trimmingCharacters(in: .whitespaces) }
            }
            return []
        }
    }

    var contentType : String{
        get{
            let tokens = contentTypeTokens
            return tokens.first ?? ""
        }
    }

    var contentLength : Int?{
        get{
            Int(headers["content-length"] ?? "")
        }
    }

    var sessionId: String{
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

    var user : UserData?{
        get{
            session?.user
        }
    }

    var isLoggedIn: Bool {
        get {
            user != nil
        }
    }

    var userId: Int {
        get {
            user == nil ? 0 : user!.id
        }
    }

    var hasMessage: Bool {
        get {
            message != nil
        }
    }

    var hasFormError: Bool {
        get {
            formError != nil && !formError!.isEmpty
        }
    }

    init(){
    }

    func setParam(_ name: String, _ value: Any){
        params[name] = value
    }

    func removeParam(_ name: String){
        params[name] = nil
    }

    func getParam(_ name: String) -> Any?{
        params[name]
    }

    func getParam<T>(_ name: String, type: T.Type) -> T?{
        getParam(name) as? T
    }

    func getString(_ name: String, def: String = "") -> String{
        if let s = getParam(name) as? String {
            return s
        }
        if let arr = getParam(name) as? Array<String> {
            return arr.first ?? def
        }
        return def
    }

    func getStringArray(_ name: String) -> Array<String>?{
        getParam(name) as? Array<String>
    }

    func getInt(_ name: String, def: Int = -1) -> Int{
        let s = getString(name)
        return Int(s) ?? def
    }

    func getIntArray(_ name: String) -> Array<Int>?{
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

    func getBool(_ name: String) -> Bool{
        let s = getString(name)
        return Bool(s) ?? false
    }

    func getFile(_ name: String) -> MemoryFile?{
        print("files: \(files.keys)")
        return files[name]
    }

    func setSessionAttribute(_ name: String, value: Any){
        session?.setAttribute(name, value: value)
    }

    func removeSessionAttribute(_ name: String){
        session?.removeAttribute(name)
    }

    func getSessionAttributeNames() -> Set<String>{
        session?.getAttributeNames() ?? Set<String>()
    }

    func getSessionAttribute(_ name: String) -> Any?{
        session?.getAttribute(name)
    }

    func getSessionAttribute<T>(_ name: String, type: T.Type) -> T?{
        getSessionAttribute(name) as? T
    }

    func getSessionString(_ name: String, def : String = "") -> String{
        getSessionAttribute(name) as? String ?? def
    }

    func getSessionInt(_ name: String, def: Int = -1) -> Int{
        if let i = getSessionAttribute(name) as? Int{
            return i
        }
        if let s = getSessionAttribute(name) as? String{
            return Int(s) ?? def
        }
        return def
    }

    func getSessionBool(_ name: String) -> Bool{
        if let b = getSessionAttribute(name) as? Bool{
            return b
        }
        if let s = getSessionAttribute(name) as? String{
            return Bool(s) ?? false
        }
        return false
    }

    func addPageVar(_ name: String,_ value: String){
        pageVars[name] = value
    }

    func addConditionalPageVar(_ name: String,_ value: String, if condition: Bool){
        if condition{
            addPageVar(name, value)
        }
    }

    func setMessage(_ msg: String, type: MessageType) {
        message = Message(type: type, text: msg)
    }

    func getFormError(create: Bool) -> FormError {
        if formError == nil && create {
            formError = FormError()
        }
        return formError!
    }

    func addFormError(_ s: String) {
        getFormError(create: true).addFormError(s)
    }

    func addFormField(_ field: String) {
        getFormError(create: true).addFormField(field)
    }

    func addIncompleteField(_ field: String) {
        getFormError(create: true).addFormField(field)
        getFormError(create: false).formIncomplete = true
    }

    func hasFormErrorField(_ name: String) -> Bool {
        if formError == nil {
            return false
        }
        return formError!.hasFormErrorField(name: name)
    }

    func dump() {
        Log.info(">>start request")
        Log.info("method = \(method.rawValue)")
        Log.info("uri = \(uri)")
        Log.info("path = \(path)")
        Log.info("params = \(params)")
        Log.info("pageVars = \(pageVars)")
        Log.info("address = \(address ?? "")")
        Log.info("referer = \(referer ?? "")")
        Log.info("user agent = \(userAgent ?? "")")
        Log.info("keepAlive = \(keepAlive)")
        Log.info("contentType = \(contentType)")
        Log.info("content length = \(contentLength ?? -1)")
        Log.info("sessionId = \(sessionId)")
        if session != nil {
            Log.info("sessionAttributes = \(session!.attributes)")
        }
        Log.info("<<end request")
    }

}
