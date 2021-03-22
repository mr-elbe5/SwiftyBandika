//
// Created by Michael Rönnau on 03.03.21.
//

import Foundation

extension Request{

    static let CONTENT_KEY = "$CONTENT"
    static let FILE_KEY = "$FILE"

    func setContent(_ content: ContentData){
        setParam(Request.CONTENT_KEY, content)
    }

    func getContent() -> ContentData?{
        getParam(Request.CONTENT_KEY, type: ContentData.self)
    }

    func getSafeContent() -> ContentData{
        getParam(Request.CONTENT_KEY, type: ContentData.self) ?? ContentContainer.instance.contentRoot
    }

    func getContent<T : ContentData>(type: T.Type) -> T?{
        getParam(Request.CONTENT_KEY, type: type)
    }

    func setSessionContent(_ content: ContentData){
        setSessionAttribute(Request.CONTENT_KEY, value: content)
    }

    func getSessionContent() -> ContentData?{
        getSessionAttribute(Request.CONTENT_KEY, type: ContentData.self)
    }

    func getSessionContent<T : ContentData>(type: T.Type) -> T?{
        getSessionAttribute(Request.CONTENT_KEY, type: type)
    }

    func removeSessionContent(){
        removeSessionAttribute(Request.CONTENT_KEY)
    }

    func setSessionFile(_ file: FileData){
        setSessionAttribute(Request.FILE_KEY, value: file)
    }

    func getSessionFile() -> FileData?{
        getSessionAttribute(Request.FILE_KEY, type: FileData.self)
    }

    func removeSessionFile(){
        removeSessionAttribute(Request.FILE_KEY)
    }

}