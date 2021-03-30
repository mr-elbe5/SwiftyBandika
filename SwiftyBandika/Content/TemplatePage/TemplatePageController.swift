/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

class TemplatePageController: PageController {

    static let instance = TemplatePageController()

    override class var type: ControllerType {
        get {
            .templatepage
        }
    }

    override func processRequest(method: String, id: Int?, request: Request) -> Response? {
        if let response = super.processRequest(method: method, id: id, request: request) {
            return response
        }
        switch method {
        case "addPart": return addPart(id: id, request: request)
        default:
            return nil
        }
    }

    func addPart(id: Int?, request: Request) -> Response {
        if let data = request.getSessionContent(type: TemplatePageData.self) , id == data.id {
            if Right.hasUserEditRight(user: request.user, contentId: data.id) {
                let fromPartId = request.getInt("fromPartId", def: -1)
                if let partType = PartType(rawValue: request.getString("partType")) {
                    if let pdata = PartType.getNewPart(type: partType) {
                        pdata.setCreateValues(request: request)
                        data.addPart(part: pdata, fromPartId: fromPartId)
                        request.setSessionAttribute("part", value: pdata)
                        request.setContent(data)
                        return Response(html: pdata.getNewPartHtml(request: request))
                    }
                }
            }
        }
        return Response(code: .badRequest)
    }

    override func showEditContent(contentData: ContentData, request: Request) -> Response {
        if let cnt = request.getSessionContent(type: TemplatePageData.self){
            request.setContent(cnt)
        }
        request.addPageVar("url", "/ctrl/templatepage/saveContentData/\(contentData.id)")
        setEditPageVars(contentData: contentData, request: request)
        return ForwardResponse(page: "templatepage/editContentData.ajax", request: request)
    }

    override func setEditPageVars(contentData: ContentData, request: Request) {
        super.setEditPageVars(contentData: contentData, request: request)
        if let pageData = contentData as? TemplatePageData {
            var str = """
                      <option value="" "\(pageData.template.isEmpty ? "selected" : "") > \("_pleaseSelect".toLocalizedHtml(language: request.language)) </option>
                      """
            if let templates = TemplateCache.getTemplates(type: .page) {
                for tpl in templates.keys {
                    str.append(
                            """
                            <option value="\(tpl.toHtml())" " \(pageData.template == tpl ? "selected" : "")>\(tpl.toHtml()) </option>
                            """)
                }
            }
            request.addPageVar("templateOptions", str)
        }
    }

}
