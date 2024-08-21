//
// Created by Michael Rönnau on 07.04.21.
//

import Foundation

extension Request{

    public func addPageString(_ key: String, _ value: String){
        pageParams[key] = value
    }

    public func addConditionalPageString(_ name: String, _ value: String, if condition: Bool){
        if condition{
            addPageString(name, value)
        }
    }

    public func addPageInt(_ key: String, _ value: Int){
        pageParams[key] = String(value)
    }

    public func addPageBool(_ key: String, _ value: Bool){
        pageParams[key] = String(value)
    }

    public func getPageString(_ key: String)-> String?{
        pageParams[key]
    }

    public func getPageInt(_ key: String,def : Int = 0) -> Int{
        if let val = pageParams[key] {
            return Int(val) ?? def
        }
        return def
    }

    public func getPageBool(_ key: String)-> Bool{
        if let val = pageParams[key] {
            return Bool(val) ?? false
        }
        return false
    }

    public func addPageObject(_ key: String, _ value: Any){
        pageObjects[key] = value
    }

    public func getPageObject<T>(_ key: String, type: T.Type) -> T?{
        pageObjects[key] as? T
    }

    public func clearPageParams(){
        pageParams.removeAll()
    }

    public func clearPageObjects(){
        pageObjects.removeAll()
    }

    public func setMessage(_ msg: String, type: MessageType) {
        message = Message(type: type, text: msg)
    }

    public func getFormError(create: Bool) -> FormError {
        if formError == nil && create {
            formError = FormError()
        }
        return formError!
    }

    public func addFormError(_ s: String) {
        getFormError(create: true).addFormError(s)
    }

    public func addFormField(_ field: String) {
        getFormError(create: true).addFormField(field)
    }

    public func addIncompleteField(_ field: String) {
        getFormError(create: true).addFormField(field)
        getFormError(create: false).formIncomplete = true
    }

    public func hasFormErrorField(_ name: String) -> Bool {
        if formError == nil {
            return false
        }
        return formError!.hasFormErrorField(name: name)
    }

}