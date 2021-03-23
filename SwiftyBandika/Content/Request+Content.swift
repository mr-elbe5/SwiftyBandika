/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

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