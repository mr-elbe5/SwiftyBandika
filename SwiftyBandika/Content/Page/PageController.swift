//
// Created by Michael Rönnau on 19.03.21.
//

import Foundation

class PageController: ContentController {

    override func processRequest(method: String, id: Int?, request: Request) -> Response? {
        if let response = super.processRequest(method: method, id: id, request: request) {
            return response
        }
        switch method {
        case "openEditPage": return openEditPage(id: id, request: request)
        case "savePage": return savePage(id: id, request: request)
        case "cancelEditPage": return cancelEditPage(id: id, request: request)
        default:
            return nil
        }
    }

    func openEditPage(id: Int?, request: Request) -> Response {
        if let id = id, let original = ContentContainer.instance.getContent(id: id) as? PageData {
            if !Right.hasUserEditRight(user: request.user, contentId: original.id) {
                return Response(code: .forbidden)
            }
            if let data = DataFactory.create(type: original.type) as? PageData{
                data.copyFixedAttributes(from: original)
                data.copyEditableAttributes(from: original)
                data.copyPageAttributes(from: original)
                request.setSessionContent(data)
                request.viewType = .edit
                return show(id: data.id, request: request) ?? Response(code: .internalServerError)
            }
        }
        return Response(code: .badRequest)
    }

    func savePage(id: Int?, request: Request) -> Response {
        if let id = id, let data = request.getSessionContent(type: PageData.self), data.id == id {
            if !Right.hasUserEditRight(user: request.user, content: data) {
                return Response(code: .forbidden)
            }
            data.readPageRequest(request)
            if request.hasFormError {
                request.viewType = .edit
                return show(id: data.id, request: request) ?? Response(code: .internalServerError)
            }
            if !ContentContainer.instance.updateContent(data: data, userId: request.userId) {
                Log.warn("original data not found for update")
                request.setMessage("_versionError", type: .danger)
                request.viewType = .edit
                return show(id: data.id, request: request) ?? Response(code: .internalServerError)
            }
            request.removeSessionContent()
            return show(id: id, request: request) ?? Response(code: .internalServerError)
        }
        return Response(code: .badRequest)
    }

    func cancelEditPage(id: Int?, request: Request) -> Response {
        if let id = id {
            if !Right.hasUserReadRight(user: request.user, contentId: id) {
                return Response(code: .forbidden)
            }
            request.removeSessionContent()
            request.viewType = .show
            return show(id: id, request: request) ?? Response(code: .internalServerError)
        }
        return Response(code: .badRequest)
    }

}
