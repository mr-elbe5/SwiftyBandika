/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/
import Foundation

class FileController: Controller {

    static var instance = FileController()

    override class var type: ControllerType {
        get {
            .file
        }
    }

    override func processRequest(method: String, id: Int?, request: Request) -> Response? {
        switch method {
        case "show": return show(id: id, request: request)
        case "showPreview": return showPreview(id: id, request: request)
        case "openCreateFile": return openCreateFile(request: request)
        case "openEditFile": return openEditFile(id: id, request: request)
        case "saveFile": return saveFile(request: request)
        case "cutFile": return cutFile(id: id, request: request)
        case "copyFile": return copyFile(id: id, request: request)
        case "pasteFile": return pasteFile(request: request)
        case "deleteFile": return deleteFile(id: id, request: request)
        default:
            return nil
        }
    }

    func show(request: Request) -> Response {
        var path = request.path
        path.removeFirst(Router.filesPrefix.count)
        path = path.withoutExt()
        var isPreview = false
        if path.hasPrefix("preview"){
            isPreview = true
            path.removeFirst("preview".count)
        }
        if let id = Int(path) {
            if isPreview{
                return showPreview(id: id, request: request)
            }
            else {
                return show(id: id, request: request)
            }
        }
        else{
            Log.error("id in path not found: \(path)")
        }
        return Response(code: .notFound)
    }

    func show(id: Int?, request: Request) -> Response {
        if let id = id, let file = ContentContainer.instance.getFile(id: id) {
            if !Right.hasUserReadRight(user: request.user, contentId: file.parentId) {
                return Response(code: .forbidden)
            }
            Log.info("loading file \(id)")
            if let data: Data = Files.readFile(url: file.file.url) {
                let contentType = file.file.url.path.mimeType()
                return Response(data: data, contentType: contentType)
            }
            Log.info("reading file for id \(id) failed")
        }
        return Response(code: .notFound)
    }

    func showPreview(id: Int?, request: Request) -> Response {
        if let id = id, let file = ContentContainer.instance.getFile(id: id) {
            if !Right.hasUserReadRight(user: request.user, contentId: file.parentId) {
                return Response(code: .forbidden)
            }
            Log.info("loading preview file \(id)")
            if let pvf = file.previewFile, let data: Data = Files.readFile(url: pvf.url) {
                let contentType = file.file.url.path.mimeType()
                return Response(data: data, contentType: contentType)
            }
            Log.info("reading preview file for id \(id) failed")
        }
        return Response(code: .notFound)
    }

    func openCreateFile(request: Request) -> Response {
        let parentId = request.getInt("parentId")
        if let parent = ContentContainer.instance.getContent(id: parentId) {
            if !Right.hasUserEditRight(user: request.user, content: parent) {
                return Response(code: .forbidden)
            }
            let data = FileData()
            data.setCreateValues(request: request)
            data.parentId = parent.id
            data.parentVersion = parent.version
            request.setSessionFile(data)
            return showEditFile(file: data, request: request)
        }
        return Response(code: .badRequest)
    }

    func openEditFile(id: Int?, request: Request) -> Response {
        if let id = id, let original = ContentContainer.instance.getFile(id: id) {
            let data = FileData()
            data.copyFixedAttributes(from: original)
            data.copyEditableAttributes(from: original)
            if !Right.hasUserEditRight(user: request.user, contentId: original.parentId) {
                return Response(code: .forbidden)
            }
            request.setSessionFile(data)
            return showEditFile(file: data, request: request)
        }
        return Response(code: .badRequest)
    }

    func saveFile(request: Request) -> Response {
        if let data = request.getSessionFile() {
            if !Right.hasUserEditRight(user: request.user, contentId: data.parentId) {
                return Response(code: .forbidden)
            }
            data.readRequest(request)
            if (request.hasFormError) {
                return showEditFile(file: data,request: request)
            }
            if data.isNew {
                if !ContentContainer.instance.addFile(data:data, userId: request.userId) {
                    Log.warn("data could not be added")
                    request.setMessage("_versionError", type: .danger)
                    return showEditFile(file: data,request: request)
                }
            } else {
                if !ContentContainer.instance.updateFile(data: data, userId: request.userId) {
                    Log.warn("data could not be updated");
                    request.setMessage("_versionError", type: .danger)
                    return showEditFile(file: data,request: request);
                }
            }
            request.removeSessionFile()
            request.setMessage("_fileSaved", type: .success);
            request.setParam("fileId", String(data.id))
            return CloseDialogResponse(url: "/ctrl/admin/openContentAdministration", request: request)
        }
        return Response(code: .badRequest)
    }

    func cutFile(id: Int?, request: Request) -> Response {
        if let id = id, let data = ContentContainer.instance.getFile(id: id) {
            if !Right.hasUserEditRight(user: request.user, contentId: data.parentId) {
                return Response(code: .forbidden)
            }
            Clipboard.instance.setData(type: .file, data: data)
            return showContentAdministration(contentId: data.parentId, request: request)
        }
        return Response(code: .badRequest)
    }

    func copyFile(id: Int?, request: Request) -> Response {
        if let id = id, let original = ContentContainer.instance.getFile(id: id, type: FileData.self) {
            if !Right.hasUserEditRight(user: request.user, contentId: original.parentId) {
                return Response(code: .forbidden)
            }
            let data = FileData()
            data.copyEditableAttributes(from: original)
            data.setCreateValues(request: request)
            // marking as copy
            data.parentId = 0
            data.parentVersion = 0
            if original.file.live , data.file.live {
                var success = Files.copyFile(fromURL: original.file.url, toURL: data.file.url)
                if original.isImage, let opf = original.previewFile, let npf = data.previewFile {
                    success = success && Files.copyFile(fromURL: opf.url, toURL: npf.url)
                }
                if !success {
                    return Response(code: .internalServerError)
                }
                Clipboard.instance.setData(type: DataType.file, data: data)
                return showContentAdministration(contentId: data.id, request: request)
            }
        }
        return Response(code: .badRequest)
    }

    func pasteFile(request: Request) -> Response {
        let parentId = request.getInt("parentId")
        let parentVersion = request.getInt("parentVersion")
        if !Right.hasUserEditRight(user: request.user, contentId: parentId) {
            return Response(code: .forbidden)
        }
        if ContentContainer.instance.getContent(id: parentId) != nil {
            if let data = Clipboard.instance.getData(type: .file) as? FileData {
                if data.parentId != 0 {
                    //has been cut
                    if !ContentContainer.instance.moveFile(data: data, newParentId: parentId, newParentVersion: parentVersion, userId: request.userId) {
                        request.setMessage("_actionNotExcecuted", type: .danger)
                        return showContentAdministration(contentId: data.id,request: request)
                    }
                } else {
                    //has been copied
                    data.parentId = parentId
                    data.parentVersion = parentVersion
                    if !ContentContainer.instance.addFile(data: data, userId: request.userId) {
                        request.setMessage("_actionNotExcecuted", type: .danger);
                        return showContentAdministration(contentId: data.id,request: request)
                    }
                }
                Clipboard.instance.removeData(type: .file)
                request.setMessage("_filePasted", type: .success)
                return showContentAdministration(contentId: data.id, request: request)
            }
        }
        return Response(code: .badRequest)
    }

    func deleteFile(id: Int?, request: Request) -> Response {
        if let id = id, let file = ContentContainer.instance.getFile(id: id) {
            if !Right.hasUserReadRight(user: request.user, contentId: file.parentId) {
                return Response(code: .forbidden)
            }
            _ = ContentContainer.instance.removeFile(data: file)
            request.setParam("contentId", String(file.parentId))
            request.setMessage("_fileDeleted", type: .success)
            return showContentAdministration(contentId: file.parentId, request: request)
        }
        return Response(code: .badRequest)
    }

    func showEditFile(file: FileData, request: Request) -> Response {
        request.addPageVar("url", "/ctrl/file/saveFile/\(file.id)")
        setPageVars(file: file, request: request)
        return ForwardResponse(page: "file/editFile.ajax", request: request)
    }

    func setPageVars(file: FileData, request: Request) {
        request.addPageVar("id", String(file.id))
        request.addPageVar("creationDate", file.creationDate.dateTimeString())
        if let user = UserContainer.instance.getUser(id: file.creatorId) {
            request.addPageVar("creatorName", user.name.toHtml())
        }
        request.addPageVar("changeDate", String(file.changeDate.dateTimeString()))
        if let user = UserContainer.instance.getUser(id: file.changerId) {
            request.addPageVar("changerName", user.name.toHtml())
        }
        request.addPageVar("fileName", file.fileName.toHtml())
        request.addPageVar("fileRequired", String(file.isNew))
        request.addPageVar("displayName", file.displayName.toHtml())
        request.addPageVar("description", file.description.toHtmlMultiline())
    }

}
