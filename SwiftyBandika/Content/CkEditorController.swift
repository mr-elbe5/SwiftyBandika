/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation


public class CkEditorController: TypedController {

    public static var instance = CkEditorController()

    override public class var type: ControllerType {
        get {
            "ckeditor"
        }
    }

    override public func processRequest(method: String, id: Int?, request: Request) -> Response? {
        switch method {
        case "openLinkBrowser": return openLinkBrowser(id: id, request: request)
        case "openImageBrowser": return openImageBrowser(id: id, request: request)
        default:
            return nil
        }
    }

    public func openLinkBrowser(id: Int?, request: Request) -> Response {
        if let data = request.getSessionContent(), id == data.id{
            if !Right.hasUserEditRight(user: request.user, contentId: data.id) {
                return Response(code: .forbidden)
            }
            return showBrowseLinks(request: request)
        }
        return Response(code: .badRequest)
    }

    public func openImageBrowser(id: Int?, request: Request) -> Response {
        if let data = request.getSessionContent(), id == data.id {
            if !Right.hasUserEditRight(user: request.user, contentId: data.id) {
                return Response(code: .forbidden)
            }
            return showBrowseImages(request: request)
        }
        return Response(code: .badRequest)
    }

    public func showBrowseLinks(request: Request) -> Response{
        request.addPageString("type", "all")
        request.addPageInt("callbackNum", request.getInt("CKEditorpublic funcNum"))
        return ForwardResponse(path: "ckeditor/browseFiles.ajax", request: request)
    }

    public func showBrowseImages(request: Request) -> Response{
        request.setParam("type", "image")
        request.addPageString("callbackNum", String(request.getInt("CKEditorpublic funcNum")))
        return ForwardResponse(path: "ckeditor/browseFiles.ajax", request: request)
    }

}
