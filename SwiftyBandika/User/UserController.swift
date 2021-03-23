/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

class UserController: Controller {

    static var instance = UserController()

    override class var type: ControllerType {
        get {
            .user
        }
    }

    override func processRequest(method: String, id: Int?, request: Request) -> Response? {
        switch method {
        case "openLogin": return openLogin(request: request)
        case "login": return login(request: request)
        case "logout": return logout(request: request)
        case "openCreateUser": return openCreateUser(request: request)
        case "openEditUser": return openEditUser(id: id, request: request)
        case "saveUser": return saveUser(request: request)
        case "deleteUser": return deleteUser(id: id, request: request)
        case "openProfile": return openProfile(request: request)
        case "openChangePassword": return openChangePassword(request: request)
        case "changePassword": return changePassword(id: id, request: request)
        case "openChangeProfile": return openChangeProfile(request: request)
        case "changeProfile": return changeProfile(id: id, request: request)
        default: return nil
        }
    }

    func openLogin(request: Request) -> Response? {
        showLogin(request: request)
    }

    func login(request: Request) -> Response? {
        let login = request.getString("login")
        let password = request.getString("password")
        if let user = UserContainer.instance.getUser(login: login, pwd: password) {
            Log.info("user \(login) logged in")
            request.session?.user = user
        } else {
            Log.warn("login of user \(login) failed")
        }
        return CloseDialogResponse(url: "/", request: request)
    }

    func logout(request: Request) -> Response {
        request.session?.user = nil
        request.setMessage("_loggedOut", type: .success)
        return showHome(request: request)
    }

    func openCreateUser(request: Request) -> Response {
        if !SystemZone.hasUserSystemRight(user: request.user, zone: SystemZone.user) {
            return Response(code: .forbidden)
        }
        let data = UserData()
        data.setCreateValues(request: request)
        request.setSessionUser(data)
        return showEditUser(user: data, request: request)
    }

    func openEditUser(id: Int?, request: Request) -> Response {
        if !SystemZone.hasUserSystemRight(user: request.user, zone: SystemZone.user) {
            return Response(code: .forbidden)
        }
        if let id = id {
            let data = UserData()
            if let original = UserContainer.instance.getUser(id: id) {
                data.copyFixedAttributes(from: original)
                data.copyEditableAttributes(from: original)
                request.setSessionAttribute("user", value: data)
                return showEditUser(user: data, request: request)
            }
        }
        return Response(code: .badRequest)
    }

    func saveUser(request: Request) -> Response {
        if !SystemZone.hasUserSystemRight(user: request.user, zone: SystemZone.user) {
            return Response(code: .forbidden)
        }
        if let data = request.getSessionUser() {
            data.readRequest(request)
            if (request.hasFormError) {
                return showEditUser(user: data, request: request)
            }
            if data.isNew {
                _ = UserContainer.instance.addUser(data: data, userId: request.userId)
            } else {
                if (!UserContainer.instance.updateUser(data: data, userId: request.userId)) {
                    Log.warn("original data not found for update.")
                    request.setMessage("_versionError", type: .danger)
                    return showEditUser(user: data, request: request)
                }
            }
            if request.userId == data.id {
                request.session?.user = data
            }
            request.removeSessionUser()
            request.setMessage("_userSaved", type: .success)
            request.setParam("userId", data.id)
            return CloseDialogResponse(url: "/ctrl/admin/openUserAdministration", request: request)
        }
        return Response(code: .badRequest)
    }

    func deleteUser(id: Int?, request: Request) -> Response {
        if !SystemZone.hasUserSystemRight(user: request.user, zone: SystemZone.user) {
            return Response(code: .forbidden)
        }
        if let id = id {
            let version = request.getInt("version")
            if id == UserData.ID_ROOT {
                request.setMessage("_notDeletable", type: .danger)
                return showUserAdministration(request: request)
            }
            if let data = UserContainer.instance.getUser(id: id) {
                if data.version != version {
                    Log.warn("original data not found for update.")
                    request.setMessage("_deleteError", type: .danger)
                    return showUserAdministration(request: request)
                }
                if !UserContainer.instance.removeUser(data: data) {
                    Log.warn("user could not be deleted");
                    request.setMessage("_deleteError", type: .danger)
                    return showUserAdministration(request: request)
                }
                request.setMessage("_userDeleted", type: .success)
                return showUserAdministration(request: request)
            }
        }
        return Response(code: .badRequest)
    }

    func openProfile(request: Request) -> Response {
        if request.isLoggedIn {
            return showProfile(request: request)
        }
        return Response(code: .forbidden)
    }

    func openChangePassword(request: Request) -> Response {
        if request.isLoggedIn {
            return showChangePassword(request: request)
        }
        return Response(code: .forbidden)
    }

    func changePassword(id: Int?, request: Request) -> Response {
        if request.isLoggedIn, let id = id, id == request.userId {
            if let user = UserContainer.instance.getUser(id: id) {
                let oldPassword = request.getString("oldPassword")
                let newPassword = request.getString("newPassword1")
                let newPassword2 = request.getString("newPassword2")
                if newPassword.count < UserData.minPasswordLength {
                    request.addFormField("newPassword1")
                    request.addFormError("_passwordLengthError".localize())
                    return showChangePassword(request: request)
                }
                if newPassword != newPassword2 {
                    request.addFormField("newPassword1")
                    request.addFormField("newPassword2")
                    request.addFormError("_passwordsDontMatch".localize())
                    return showChangePassword(request: request)
                }
                if let data = UserContainer.instance.getUser(login: user.login, pwd: oldPassword) {
                    _ = UserContainer.instance.updateUserPassword(data: data, newPassword: newPassword)
                    request.setMessage("_passwordChanged", type: .success)
                    return CloseDialogResponse(url: "/ctrl/user/openProfile", request: request)
                } else {
                    request.addFormField("newPassword1");
                    request.addFormError("_badLogin".localize())
                    return showChangePassword(request: request)
                }
            }
            return Response(code: .forbidden)
        }
        return Response(code: .badRequest)
    }

    func openChangeProfile(request: Request) -> Response {
        if request.isLoggedIn {
            return showChangeProfile(request: request)
        }
        return Response(code: .forbidden)
    }

    func changeProfile(id: Int?, request: Request) -> Response {
        if let id = id {
            if request.isLoggedIn && request.userId == id {
                if let data = UserContainer.instance.getUser(id: id){
                    data.readProfileRequest(request)
                    if request.hasFormError {
                        return showChangeProfile(request: request)
                    }
                    if UserContainer.instance.updateUser(data: data, userId: request.userId) {
                        request.session?.user = UserContainer.instance.getUser(id: data.id)
                        request.setMessage("_userSaved", type: .success)
                        return CloseDialogResponse(url: "/ctrl/user/openProfile", request: request)
                    }
                    else{
                        Log.warn("original data not found for update.")
                        request.setMessage("_saveError", type: .danger)
                        return showChangeProfile(request: request)
                    }
                }
            }
            return Response(code: .forbidden)
        }
        return Response(code: .badRequest)
    }

    func showLogin(request: Request) -> Response {
        ForwardResponse(page: "user/login.ajax", request: request)
    }

    func showEditUser(user: UserData, request: Request) -> Response {
        request.addPageVar("url", "/ctrl/user/saveUser/\(user.id)")
        request.addPageVar("id", String(user.id))
        request.addPageVar("login", user.login.toHtml())
        request.addPageVar("firstName", user.firstName.toHtml())
        request.addPageVar("lastName", user.lastName.toHtml())
        request.addPageVar("title", user.title.toHtml())
        request.addPageVar("street", user.street.toHtml())
        request.addPageVar("zipCode", user.zipCode.toHtml())
        request.addPageVar("city", user.city.toHtml())
        request.addPageVar("country", user.country.toHtml())
        request.addPageVar("email", user.email.toHtml())
        request.addPageVar("phone", user.phone.toHtml())
        var str = ""
        for group in UserContainer.instance.groups{
            str.append(FormCheckTag.getCheckHtml(name: "groupIds", value: String(group.id), label: group.name, checked: group.userIds.contains(user.id)))
        }
        request.addPageVar("groupChecks", str)
        return ForwardResponse(page: "user/editUser.ajax", request: request)
    }

    func showProfile(request: Request) -> Response {
        TemplateController.instance.processPageInMaster(page: "user/profile", request: request)
    }

    func showChangePassword(request: Request) -> Response {
        return ForwardResponse(page: "user/editPassword.ajax", request: request)
    }

    func showChangeProfile(request: Request) -> Response {
        return ForwardResponse(page: "user/editProfile.ajax", request: request)
    }

}
