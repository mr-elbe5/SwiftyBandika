/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

public class AdminController: TypedController {

    public static var instance = AdminController()

    override public class var type: ControllerType {
        get {
            "admin"
        }
    }

    override public func processRequest(method: String, id: Int?, request: Request) -> Response? {
        switch method {
        case "openUserAdministration": return openUserAdministration(request: request)
        case "openContentAdministration": return openContentAdministration(request: request)
        case "clearClipboard": return clearClipboard(request: request)
        default:
            return nil
        }
    }

    public func openUserAdministration(request: Request) -> Response {
        if !SystemZone.hasUserAnySystemRight(user: request.user){ return Response(code: .forbidden)}
        return showUserAdministration(request: request)
    }

    public func openContentAdministration(request: Request) -> Response {
        if !SystemZone.hasUserAnySystemRight(user: request.user){ return Response(code: .forbidden)}
        return showContentAdministration(request: request)
    }

    public func clearClipboard(request: Request) -> Response {
        Clipboard.instance.removeData(type: .content)
        Clipboard.instance.removeData(type: .file)
        return showContentAdministration(request: request)
    }

}
