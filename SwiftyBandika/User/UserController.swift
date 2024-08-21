/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation



public class UserController: TypedController {

    public static var instance = UserController()

    override public class var type: ControllerType {
        get {
            "user"
        }
    }

    override public func processRequest(method: String, id: Int?, request: Request) -> Response? {
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

    public func openLogin(request: Request) -> Response? {
        showLogin(request: request)
    }

    public func login(request: Request) -> Response? {
        let login = request.getString("login")
        let password = request.getString("password")
        if let user = UserContainer.instance.getUser(login: login, pwd: password) {
            Log.info("user \(login) logged in")
            request.session?.user = user
            return CloseDialogResponse(url: "/", request: request)
        }
        Log.warn("login of user \(login) failed")
        request.addFormError("_badLogin".localize(language: request.language))
        return showLogin(request: request)
    }

    public func logout(request: Request) -> Response {
        request.session?.user = nil
        request.setMessage("_loggedOut", type: .success)
        return showHome(request: request)
    }

    public func openCreateUser(request: Request) -> Response {
        if !SystemZone.hasUserSystemRight(user: request.user, zone: SystemZone.user) {
            return Response(code: .forbidden)
        }
        let data = UserData()
        data.setCreateValues(request: request)
        request.setSessionUser(data)
        return showEditUser(user: data, request: request)
    }

    public func openEditUser(id: Int?, request: Request) -> Response {
        if !SystemZone.hasUserSystemRight(user: request.user, zone: SystemZone.user) {
            return Response(code: .forbidden)
        }
        if let id = id {
            let data = UserData()
            if let original = UserContainer.instance.getUser(id: id) {
                data.copyFixedAttributes(from: original)
                data.copyEditableAttributes(from: original)
                request.setSessionUser(data)
                return showEditUser(user: data, request: request)
            }
        }
        return Response(code: .badRequest)
    }

    public func saveUser(request: Request) -> Response {
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

    public func deleteUser(id: Int?, request: Request) -> Response {
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

    public func openProfile(request: Request) -> Response {
        if request.isLoggedIn {
            return showProfile(user: request.user!, request: request)
        }
        return Response(code: .forbidden)
    }

    public func openChangePassword(request: Request) -> Response {
        if request.isLoggedIn {
            return showChangePassword(user: request.user!, request: request)
        }
        return Response(code: .forbidden)
    }

    public func changePassword(id: Int?, request: Request) -> Response {
        if request.isLoggedIn, let id = id, id == request.userId {
            if let user = UserContainer.instance.getUser(id: id) {
                let oldPassword = request.getString("oldPassword")
                if let data = UserContainer.instance.getUser(login: user.login, pwd: oldPassword) {
                    let newPassword = request.getString("newPassword1")
                    let newPassword2 = request.getString("newPassword2")
                    if newPassword.count < UserData.minPasswordLength {
                        request.addFormField("newPassword1")
                        request.addFormError("_passwordLengthError".localize(language: request.language))
                        return showChangePassword(user: request.user!, request: request)
                    }
                    if newPassword != newPassword2 {
                        request.addFormField("newPassword1")
                        request.addFormField("newPassword2")
                        request.addFormError("_passwordsDontMatch".localize(language: request.language))
                        return showChangePassword(user: request.user!, request: request)
                    }
                    _ = UserContainer.instance.updateUserPassword(data: data, newPassword: newPassword)
                    request.setMessage("_passwordChanged", type: .success)
                    return CloseDialogResponse(url: "/ctrl/user/openProfile", request: request)

                } else {
                    request.addFormField("oldPassword");
                    request.addFormError("_badLogin".localize(language: request.language))
                    return showChangePassword(user: request.user!, request: request)
                }
            }
            return Response(code: .forbidden)
        }
        return Response(code: .badRequest)
    }

    public func openChangeProfile(request: Request) -> Response {
        if request.isLoggedIn {
            return showChangeProfile(user: request.user!, request: request)
        }
        return Response(code: .forbidden)
    }

    public func changeProfile(id: Int?, request: Request) -> Response {
        if let id = id {
            if request.isLoggedIn && request.userId == id {
                if let data = UserContainer.instance.getUser(id: id){
                    data.readProfileRequest(request)
                    if request.hasFormError {
                        return showChangeProfile(user: request.user!, request: request)
                    }
                    if UserContainer.instance.updateUser(data: data, userId: request.userId) {
                        request.session?.user = UserContainer.instance.getUser(id: data.id)
                        request.setMessage("_userSaved", type: .success)
                        return CloseDialogResponse(url: "/ctrl/user/openProfile", request: request)
                    }
                    else{
                        Log.warn("original data not found for update.")
                        request.setMessage("_saveError", type: .danger)
                        return showChangeProfile(user: request.user!, request: request)
                    }
                }
            }
            return Response(code: .forbidden)
        }
        return Response(code: .badRequest)
    }

    public func showLogin(request: Request) -> Response {
        ForwardResponse(path: "user/login.ajax", request: request)
    }

    public func showEditUser(user: UserData, request: Request) -> Response {
        request.addPageString("url", "/ctrl/user/saveUser/\(user.id)")
        setUserVars(user: user, request: request)
        var str = ""
        for group in UserContainer.instance.groups{
            str.append(FormCheckTag.getCheckHtml(request: request, name: "groupIds", value: String(group.id), label: group.name, checked: group.userIds.contains(user.id)))
        }
        request.addPageString("groupChecks", str)
        return ForwardResponse(path: "user/editUser.ajax", request: request)
    }

    public func showProfile(user: UserData, request: Request) -> Response {
        setUserVars(user: user, request: request)
        return TemplateController.instance.processPageInMaster(page: "user/profile", request: request)
    }

    public func showChangePassword(user: UserData, request: Request) -> Response {
        request.addPageString("url", "/ctrl/user/changePassword/\(user.id)")
        return ForwardResponse(path: "user/editPassword.ajax", request: request)
    }

    public func showChangeProfile(user: UserData, request: Request) -> Response {
        request.addPageString("url", "/ctrl/user/changeProfile/\(user.id)")
        setUserVars(user: user, request: request)
        return ForwardResponse(path: "user/editProfile.ajax", request: request)
    }

    public func setUserVars(user: UserData, request: Request){
        request.addPageString("id", String(user.id))
        request.addPageString("login", user.login.toHtml())
        request.addPageString("firstName", user.firstName.toHtml())
        request.addPageString("lastName", user.lastName.toHtml())
        request.addPageString("title", user.title.toHtml())
        request.addPageString("street", user.street.toHtml())
        request.addPageString("zipCode", user.zipCode.toHtml())
        request.addPageString("city", user.city.toHtml())
        request.addPageString("country", user.country.toHtml())
        request.addPageString("email", user.email.toHtml())
        request.addPageString("phone", user.phone.toHtml())
    }

}
