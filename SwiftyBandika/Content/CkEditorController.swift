//
// Created by Michael Rönnau on 04.03.21.
//

import Foundation

class CkEditorController: Controller {

    static var instance = CkEditorController()

    override class var type: ControllerType {
        get {
            .ckeditor
        }
    }

    override func processRequest(method: String, id: Int?, request: Request) -> Response? {
        switch method {
        case "openLinkBrowser": return openLinkBrowser(id: id, request: request)
        case "openImageBrowser": return openImageBrowser(id: id, request: request)
        default:
            return nil
        }
    }

    func openLinkBrowser(id: Int?, request: Request) -> Response {
        if let data = request.getSessionContent(), id == data.id{
            if !Right.hasUserEditRight(user: request.user, contentId: data.id) {
                return Response(code: .forbidden)
            }
            return showBrowseLinks(request: request)
        }
        return Response(code: .badRequest)
    }

    func openImageBrowser(id: Int?, request: Request) -> Response {
        if let data = request.getSessionContent(), id == data.id {
            if !Right.hasUserEditRight(user: request.user, contentId: data.id) {
                return Response(code: .forbidden)
            }
            return showBrowseImages(request: request)
        }
        return Response(code: .badRequest)
    }

    func showBrowseLinks(request: Request) -> Response{
        request.setParam("type", "all")
        request.addPageVar("callbackNum", String(request.getInt("CKEditorFuncNum")))
        return ForwardResponse(page: "ckeditor/browseFiles.ajax", request: request)
    }

    func showBrowseImages(request: Request) -> Response{
        request.setParam("type", "image")
        request.addPageVar("callbackNum", String(request.getInt("CKEditorFuncNum")))
        return ForwardResponse(page: "ckeditor/browseFiles.ajax", request: request)
    }

}