/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation



public class GroupController: TypedController {

    public static var instance = GroupController()

    override public class var type: ControllerType {
        get {
            "group"
        }
    }

    override public func processRequest(method: String, id: Int?, request: Request) -> Response? {
        switch method {
        case "openEditGroup": return openEditGroup(id: id, request: request)
        case "openCreateGroup": return openCreateGroup(request: request)
        case "saveGroup": return saveGroup(request: request)
        case "deleteGroup": return deleteGroup(id: id, request: request)
        default:
            return nil
        }
    }

    public func openCreateGroup(request: Request) -> Response {
        if !SystemZone.hasUserSystemRight(user: request.user, zone: SystemZone.user) {
            return Response(code: .forbidden)
        }
        let data = GroupData()
        data.isNew = true
        data.id = IdService.instance.getNextId()
        request.setSessionGroup(data)
        return showEditGroup(group: data, request: request)
    }

    public func openEditGroup(id: Int?, request: Request) -> Response {
        if !SystemZone.hasUserSystemRight(user: request.user, zone: SystemZone.user) {
            return Response(code: .forbidden)
        }
        if let id = id, let original = UserContainer.instance.getGroup(id: id) {
            let data = GroupData()
            data.copyFixedAttributes(from: original)
            data.copyEditableAttributes(from: original)
            request.setSessionGroup(data)
            return showEditGroup(group: data, request: request)
        }
        return Response(code: .badRequest)
    }

    public func saveGroup(request: Request) -> Response {
        if !SystemZone.hasUserSystemRight(user: request.user, zone: SystemZone.user) {
            return Response(code: .forbidden)
        }
        if let data = request.getSessionGroup() {
            data.readRequest(request)
            if (request.hasFormError) {
                return showEditGroup(group: data, request: request)
            }
            if data.isNew {
                _ = UserContainer.instance.addGroup(data: data, userId: request.userId)
            } else {
                if (!UserContainer.instance.updateGroup(data: data, userId: request.userId)) {
                    Log.warn("original data not found for update.");
                    request.setMessage("_versionError", type: .danger);
                    return showEditGroup(group: data, request: request)
                }
            }
            request.removeSessionGroup()
            request.setMessage("_groupSaved", type: .success);
            request.setParam("groupId", data.id)
            return CloseDialogResponse(url: "/ctrl/admin/openUserAdministration", request: request)
        }
        return Response(code: .noContent)
    }

    public func deleteGroup(id: Int?, request: Request) -> Response {
        if !SystemZone.hasUserSystemRight(user: request.user, zone: SystemZone.user) {
            return Response(code: .forbidden)
        }
        let version = request.getInt("version", def: 1)
        if let id = id, let data = UserContainer.instance.getGroup(id: id), data.version == version {
            if UserContainer.instance.removeGroup(data: data) {
                request.setMessage("_groupDeleted", type: .success)
            }
            return showUserAdministration(request: request)
        }
        Log.warn("original data not found for update.");
        request.setMessage("_deleteError", type: .danger)
        return showUserAdministration(request: request)
    }

    public func showEditGroup(group: GroupData, request: Request) -> Response {
        request.addPageString("url", "/ctrl/group/saveGroup/\(group.id)")
        request.addPageString("id", String(group.id))
        request.addPageString("name", group.name.toHtml())
        request.addPageString("notes", group.notes.trim().toHtml())
        var str = ""
        for zone in SystemZone.allCases {
            str.append(FormCheckTag.getCheckHtml(request: request, name: "zoneright_"+zone.rawValue, value: String(true), label: ("_zone."+zone.rawValue).toLocalizedHtml(language: request.language), checked: group.hasSystemRight(zone: zone)))
        }
        request.addPageString("rightChecks", str)
        str = ""
        for user in UserContainer.instance.users {
            str.append(FormCheckTag.getCheckHtml(request: request, name: "userIds", value: String(user.id), label: user.name, checked: group.userIds.contains(user.id)))
        }
        request.addPageString("userChecks", str)
        return ForwardResponse(path: "user/editGroup.ajax", request: request)
    }

}
