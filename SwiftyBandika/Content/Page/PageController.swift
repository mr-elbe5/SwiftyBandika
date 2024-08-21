/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation



public class PageController: ContentController {

    override public func processRequest(method: String, id: Int?, request: Request) -> Response? {
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

    public func openEditPage(id: Int?, request: Request) -> Response {
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

    public func savePage(id: Int?, request: Request) -> Response {
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

    public func cancelEditPage(id: Int?, request: Request) -> Response {
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
