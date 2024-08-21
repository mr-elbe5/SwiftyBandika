/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation



public class ContentController: TypedController {

    override public func processRequest(method: String, id: Int?, request: Request) -> Response? {
        switch method {
        case "show": return show(id: id, request: request)
        case "openCreateContentData": return openCreateContentData(request: request)
        case "openEditContentData": return openEditContentData(id: id, request: request)
        case "saveContentData": return saveContentData(id: id, request: request)
        case "openEditRights": return openEditRights(id: id, request: request)
        case "saveRights": return saveRights(id: id, request: request)
        case "cutContent": return cutContent(id: id, request: request)
        case "copyContent": return copyContent(id: id, request: request)
        case "pasteContent": return pasteContent(request: request)
        case "deleteContent": return deleteContent(id: id, request: request)
        case "openSortChildPages": return openSortChildPages(id: id, request: request)
        case "saveChildPageRanking": return saveChildPageRanking(id: id, request: request)
        case "showDraft": return showDraft(id: id, request: request)
        case "showPublished": return showPublished(id: id, request: request)
        case "publishPage": return publishPage(id: id, request: request)
        default:
            return nil
        }
    }

    public func show(id: Int?, request: Request) -> Response? {
        if let id = id, let content = ContentContainer.instance.getContent(id: id) {
            request.setContent(content)
            request.addPageString("title", Statics.title.toHtml())
            request.addPageString("keywords", content.keywords.toHtml())
            request.addPageString("description", content.description.trim().toHtml())
            let master = TemplateCache.getTemplate(type: TemplateType.master, name: content.master)
            if let html = master?.getHtml(request: request) {
                return Response(html: HtmlFormatter.format(src: html, indented: true))
            }
        } else {
            Log.warn("content id not found : \(id ?? 0)")
        }
        return Response(code: .notFound)
    }

    public func openCreateContentData(request: Request) -> Response {
        let parentId = request.getInt("parentId")
        if let parent = ContentContainer.instance.getContent(id: parentId) {
            if !Right.hasUserEditRight(user: request.user, content: parent) {
                return Response(code: .forbidden)
            }
            let type = request.getString("type")
            if let type = DataType(rawValue: type), let data = DataFactory.create(type: type) as? ContentData{
                data.setCreateValues(parent: parent, request: request)
                data.parentId = parent.id
                data.parentVersion = parent.version
                request.setSessionContent(data)
                if let controller = ControllerCache.get(data.type.rawValue) as? ContentController{
                    return controller.showEditContent(contentData: data, request: request)
                }
                else{
                    Log.error("controller type not found: \(type)")
                }
            }
            else{
                Log.error("data type not found: \(type)")
            }
        }
        return Response(code: .badRequest)
    }

    public func openEditContentData(id: Int?, request: Request) -> Response {
        if let id = id {
            if !Right.hasUserEditRight(user: request.user, contentId: id) {
                return Response(code: .forbidden)
            }
            if let original = ContentContainer.instance.getContent(id: id) {
                if let data = DataFactory.create(type: original.type) as? PageData {
                    data.copyFixedAttributes(from: original)
                    data.copyEditableAttributes(from: original)
                    request.setSessionContent(data)
                    return showEditContent(contentData: data, request: request)
                }
            }
        }
        return Response(code: .badRequest)
    }

    public func saveContentData(id: Int?, request: Request) -> Response {
        if let id = id, let data = request.getSessionContent(type: PageData.self), data.id == id {
            if (request.hasFormError) {
                return showEditContent(contentData: data, request: request)
            }
            if data.isNew {
                if !Right.hasUserEditRight(user: request.user, contentId: data.parentId) {
                    return Response(code: .forbidden)
                }
            } else {
                if !Right.hasUserEditRight(user: request.user, content: data) {
                    return Response(code: .forbidden)
                }
            }
            data.readRequest(request)
            if request.hasFormError {
                return showEditContent(contentData: data, request: request)
            }
            if data.isNew {
                if !ContentContainer.instance.addContent(data: data, userId: request.userId) {
                    Log.warn("data could not be added");
                    request.setMessage("_versionError", type: .danger)
                    return showEditContent(contentData: data, request: request)
                }
                data.isNew = false
            } else {
                if !ContentContainer.instance.updateContent(data: data, userId: request.userId) {
                    Log.warn("original data not found for update")
                    request.setMessage("_versionError", type: .danger)
                    return showEditContent(contentData: data, request: request)
                }
            }
            request.removeSessionContent()
            request.setMessage("_contentSaved", type: .success)
            return CloseDialogResponse(url: "/ctrl/admin/openContentAdministration?contentId=\(id)", request: request)
        }
        return Response(code: .badRequest)
    }

    public func openEditRights(id: Int?, request: Request) -> Response {
        if let id = id, let data = ContentContainer.instance.getContent(id: id) {
            if !Right.hasUserEditRight(user: request.user, contentId: data.id) {
                return Response(code: .forbidden)
            }
            request.setSessionContent(data)
            request.setContent(data)
            return showEditRights(contentData: data, request: request)
        }
        return Response(code: .badRequest)
    }

    public func saveRights(id: Int?, request: Request) -> Response {
        if let id = id, let data = ContentContainer.instance.getContent(id: id) {
            let version = request.getInt("version")
            if data.version != version {
                Log.warn("original data not found for update.")
                request.setMessage("_saveError", type: .danger)
                return showEditRights(contentData: data, request: request)
            }
            if !Right.hasUserEditRight(user: request.user, content: data) {
                return Response(code: .forbidden)
            }
            var rights = Dictionary<Int, Right>()
            let groups = UserContainer.instance.groups
            for group in groups {
                if group.id <= GroupData.ID_MAX_FINAL {
                    continue
                }
                let value = request.getInt("groupright_\(group.id)")
                if let right = Right(rawValue: value) {
                    rights[group.id] = right
                }
            }
            if !ContentContainer.instance.updateContentRights(data: data, rightDictionary: rights, userId: request.userId) {
                Log.warn("content rights could not be updated")
                request.setMessage("_saveError", type: .danger)
                return showEditRights(contentData: data, request: request)
            }
            request.removeSessionContent()
            request.setMessage("_rightsSaved", type: .success);
            return CloseDialogResponse(url: "/ctrl/admin/openContentAdministration?contentId=\(id)", request: request)
        }
        return Response(code: .badRequest)
    }

    public func cutContent(id: Int?, request: Request) -> Response {
        if let id = id {
            if id == ContentData.ID_ROOT {
                return showContentAdministration(contentId: ContentData.ID_ROOT, request: request)
            }
            if let data = ContentContainer.instance.getContent(id: id) {
                if !Right.hasUserEditRight(user: request.user, content: data) {
                    return Response(code: .forbidden)
                }
                Clipboard.instance.setData(type: .content, data: data)
                return showContentAdministration(contentId: data.id, request: request)
            }
        }
        return Response(code: .badRequest)
    }

    public func copyContent(id: Int?, request: Request) -> Response {
        if let id = id {
            if (id == ContentData.ID_ROOT) {
                return showContentAdministration(contentId: ContentData.ID_ROOT, request: request)
            }
            if let srcData = ContentContainer.instance.getContent(id: id) {
                if !Right.hasUserEditRight(user: request.user, content: srcData) {
                    return Response(code: .forbidden)
                }
                if let data = DataFactory.create(type: srcData.type) as? ContentData{
                    if ContentContainer.instance.getContent(id: srcData.parentId) != nil {
                        data.copyEditableAttributes(from: srcData)
                        data.setCreateValues(request: request)
                        //marking as copy
                        data.parentId = 0
                        data.parentVersion = 0
                        Clipboard.instance.setData(type: .content, data: data)
                        return showContentAdministration(contentId: data.id, request: request)
                    }
                }
            }
        }
        return Response(code: .badRequest)
    }

    public func pasteContent(request: Request) -> Response {
        let parentId = request.getInt("parentId")
        let parentVersion = request.getInt("parentVersion")
        if let data = Clipboard.instance.getData(type: .content) as? ContentData {
            if !Right.hasUserEditRight(user: request.user, contentId: parentId) {
                return Response(code: .forbidden)
            }
            let parentIds = ContentContainer.instance.collectParentIds(contentId: data.id)
            if parentIds.contains(data.id) {
                request.setMessage("_actionNotExcecuted", type: .danger)
                return showContentAdministration(request: request)
            }
            if data.parentId != 0 {
                //has been cut
                if !ContentContainer.instance.moveContent(data: data, newParentId: parentId, parentVersion: parentVersion, userId: request.userId) {
                    request.setMessage("_actionNotExcecuted", type: .danger)
                    return showContentAdministration(request: request)
                }
            } else {
                // has been copied
                data.parentId = parentId
                data.parentVersion = parentVersion
                if !ContentContainer.instance.addContent(data: data, userId: request.userId) {
                    request.setMessage("_actionNotExcecuted", type: .danger)
                    return showContentAdministration(request: request);
                }
            }
            Clipboard.instance.removeData(type: .content)
            request.setMessage("_contentPasted", type: .success)
            return showContentAdministration(contentId: data.id, request: request);
        }
        return Response(code: .badRequest)
    }

    public func deleteContent(id: Int?, request: Request) -> Response {
        if let id = id {
            if id == ContentData.ID_ROOT {
                request.setMessage("_notDeletable", type: .danger)
                return showContentAdministration(request: request)
            }
            if let data = ContentContainer.instance.getContent(id: id) {
                if !Right.hasUserEditRight(user: request.user, content: data) {
                    return Response(code: .forbidden)
                }
                if let parent = ContentContainer.instance.getContent(id: data.parentId) {
                    parent.children.remove(obj: data)
                    _ = ContentContainer.instance.removeContent(data: data)
                    request.setParam("contentId", String(parent.id))
                    request.setMessage("_contentDeleted", type: .success)
                    return showContentAdministration(contentId: parent.id, request: request)
                }
            }
        }
        return Response(code: .badRequest)
    }

    public func openSortChildPages(id: Int?, request: Request) -> Response {
        if let id = id {
            if let data = ContentContainer.instance.getContent(id: id) {
                if !Right.hasUserEditRight(user: request.user, content: data) {
                    return Response(code: .forbidden)
                }
                request.setSessionContent(data)
                return showSortChildContents(contentData: data, request: request)
            }
        }
        return Response(code: .badRequest)
    }

    public func saveChildPageRanking(id: Int?, request: Request) -> Response {
        if let id = id, let data = request.getSessionContent(), id == data.id {
            if !Right.hasUserEditRight(user: request.user, content: data) {
                return Response(code: .forbidden)
            }
            var rankMap = Dictionary<Int, Int>()
            for child in data.children {
                let ranking = request.getInt("select\(child.id)", def: -1)
                rankMap[child.id] = ranking
            }
            if !ContentContainer.instance.updateChildRanking(data: data, rankDictionary: rankMap, userId: request.userId) {
                Log.warn("sorting did not succeed");
                return showSortChildContents(contentData: data, request: request)
            }
            request.removeSessionContent()
            request.setMessage("_newRankingSaved", type: .success);
            return CloseDialogResponse(url: "/ctrl/admin/openContentAdministration?contentId=\(id)", request: request)
        }
        return Response(code: .badRequest)
    }

    public func showEditPage(id: Int?, request: Request) -> Response {
        if let id = id {
            if !Right.hasUserEditRight(user: request.user, contentId: id) {
                return Response(code: .forbidden)
            }
            request.viewType = .edit
            return show(id: id, request: request) ?? Response(code: .internalServerError)
        }
        return Response(code: .badRequest)
    }

    public func showDraft(id: Int?, request: Request) -> Response {
        if let id = id, let data = ContentContainer.instance.getContent(id: id) {
            if !Right.hasUserReadRight(user: request.user, contentId: data.id) {
                return Response(code: .forbidden)
            }
            request.viewType = .showDraft
            return show(id: data.id, request: request) ?? Response(code: .internalServerError)
        }
        return Response(code: .badRequest)
    }

    public func showPublished(id: Int?, request: Request) -> Response {
        if let id = id, let data = ContentContainer.instance.getContent(id: id) {
            if !Right.hasUserReadRight(user: request.user, contentId: data.id) {
                return Response(code: .forbidden)
            }
            request.viewType = .showPublished
            return show(id: data.id, request: request) ?? Response(code: .internalServerError)
        }
        return Response(code: .badRequest)
    }

    public func publishPage(id: Int?, request: Request) -> Response {
        if let id = id, let data = ContentContainer.instance.getContent(id: id) as? PageData {
            if !Right.hasUserApproveRight(user: request.user, contentId: data.id) {
                return Response(code: .forbidden)
            }
            data.createPublishedContent(request: request)
            data.changerId = request.userId
            data.changeDate = TimeService.instance.currentTime
            _ = ContentContainer.instance.publishContent(data: data)
            return show(id: data.id, request: request) ?? Response(code: .internalServerError)
        }
        return Response(code: .badRequest)
    }

    public func showEditContent(contentData: ContentData, request: Request) -> Response {
        if let cnt = request.getSessionContent() {
            request.setContent(cnt)
        }
        request.addPageString("url", "/ctrl/content/saveContentData/\(contentData.id)")
        setEditPageVars(contentData: contentData, request: request)
        return ForwardResponse(path: "content/editContentData.ajax", request: request)
    }

    public func setEditPageVars(contentData: ContentData, request: Request) {
        request.addPageString("id", String(contentData.id))
        request.addPageString("creationDate", contentData.creationDate.dateTimeString())
        if let user = UserContainer.instance.getUser(id: contentData.creatorId) {
            request.addPageString("creatorName", user.name.toHtml())
        }
        request.addPageString("changeDate", String(contentData.changeDate.dateTimeString()))
        if let user = UserContainer.instance.getUser(id: contentData.changerId) {
            request.addPageString("changerName", user.name.toHtml())
        }
        request.addPageString("displayName", contentData.displayName.toHtml())
        request.addPageString("description", contentData.description.trim().toHtml())
        request.addConditionalPageString("isOpenSelected", "selected", if: contentData.accessType == ContentData.ACCESS_TYPE_OPEN)
        request.addConditionalPageString("isInheritsSelected", "selected", if: contentData.accessType == ContentData.ACCESS_TYPE_INHERITS)
        request.addConditionalPageString("isIndividualSelected", "selected", if: contentData.accessType == ContentData.ACCESS_TYPE_INDIVIDUAL)
        request.addConditionalPageString("isNoneNavSelected", "selected", if: contentData.navType == ContentData.NAV_TYPE_NONE)
        request.addConditionalPageString("isHeaderNavSelected", "selected", if: contentData.navType == ContentData.NAV_TYPE_HEADER)
        request.addConditionalPageString("isFooterNavSelected", "selected", if: contentData.navType == ContentData.NAV_TYPE_FOOTER)
        request.addPageString("active", contentData.active ? "true" : "false")
        var str = FormSelectTag.getOptionHtml(request: request, value: "", isSelected: contentData.master.isEmpty, text: "_pleaseSelect".toLocalizedHtml(language: request.language))
        if let masters = TemplateCache.getTemplates(type: .master) {
            for masterName in masters.keys {
                str.append(FormSelectTag.getOptionHtml(request: request, value: masterName.toHtml(), isSelected: contentData.master == masterName, text: masterName.toHtml()))
            }
        }
        request.addPageString("masterOptions", str)
    }

    public func showEditRights(contentData: ContentData, request: Request) -> Response {
        request.addPageString("url", "/ctrl/\(contentData.type.rawValue)/saveRights/\(contentData.id)?version=\(contentData.version)")
        var html = ""
        for group in UserContainer.instance.groups {
            if group.id <= GroupData.ID_MAX_FINAL {
                continue
            }
            let name = "groupright_\(group.id)"
            let lineTag = FormLineTag()
            let rights = contentData.groupRights[group.id]
            lineTag.label = group.name.toHtml()
            lineTag.padded = true
            html.append(lineTag.getStartHtml(request: request))
            let radioTag = FormRadioTag()
            radioTag.name = name
            radioTag.checked = rights != nil
            radioTag.value = ""
            html.append(radioTag.getStartHtml(request: request))
            html.append("_rightnone".toLocalizedHtml(language: request.language))
            html.append(radioTag.getEndHtml(request: request))
            html.append("<br/>")
            radioTag.checked = rights?.includesRight(right: .READ) ?? false
            radioTag.value = String(Right.READ.rawValue)
            html.append(radioTag.getStartHtml(request: request))
            html.append("_rightread".toLocalizedHtml(language: request.language))
            html.append(radioTag.getEndHtml(request: request))
            html.append("<br/>")
            radioTag.checked = rights?.includesRight(right: .EDIT) ?? false
            radioTag.value = String(Right.EDIT.rawValue)
            html.append(radioTag.getStartHtml(request: request))
            html.append("_rightedit".toLocalizedHtml(language: request.language))
            html.append(radioTag.getEndHtml(request: request))
            html.append("<br/>")
            radioTag.checked = rights?.includesRight(right: .APPROVE) ?? false
            radioTag.value = String(Right.APPROVE.rawValue)
            html.append(radioTag.getStartHtml(request: request))
            html.append("_rightapprove".toLocalizedHtml(language: request.language))
            html.append(radioTag.getEndHtml(request: request))
            html.append(lineTag.getEndHtml(request: request))
        }
        request.addPageString("groupRights", html)
        return ForwardResponse(path: "content/editGroupRights.ajax", request: request);
    }

    public func showSortChildContents(contentData: ContentData, request: Request) -> Response {
        request.addPageString("url", "/ctrl/\(contentData.type.rawValue)/saveChildPageRanking/\(contentData.id)?version=\(contentData.version)")
        var childSortList = Array<(Int,String)>()
        for subpage in contentData.children {
            childSortList.append((subpage.id, subpage.name))
        }
        var idx = 0
        var html = ""
        for pair in childSortList {
            let name = "select" + String(pair.0)
            let onchange = "setRanking(" + pair.1 + ");"
            let lineTag = FormLineTag()
            lineTag.label = pair.1.toHtml()
            lineTag.padded = true
            html.append(lineTag.getStartHtml(request: request))
            let select = FormSelectTag()
            select.name = name
            select.label = String(idx)
            select.onChange = onchange
            html.append(FormSelectTag.preControlHtml.replacePlaceholders(language: request.language, [
                "name": name,
                "onchange": onchange]))
            for i in 0..<childSortList.count {
                html.append(FormSelectTag.getOptionHtml(request: request, value: String(i), isSelected: i == idx, text: String(i + 1)))
            }
            html.append(FormSelectTag.postControlHtml)
            html.append(lineTag.getEndHtml(request: request))
            idx += 1
        }
        request.addPageString("sortContents", html)
        return ForwardResponse(path: "content/sortChildContents.ajax", request: request);
    }

}
