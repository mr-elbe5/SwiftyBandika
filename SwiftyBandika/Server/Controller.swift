//
//  Controller.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 07.02.21.
//

import Foundation

enum ControllerType: String {
    case admin
    case ckeditor
    case file
    case fullpage
    case group
    case templatepage
    case user
}

class Controller {

    class var type: ControllerType {
        get {
            fatalError()
        }
    }

    func processRequest(method: String, id: Int?, request: Request) -> Response? {
        nil
    }

    func setSuccess(request: Request, _ name: String) {
        request.setMessage(name.toLocalizedHtml(), type: .success)
    }

    func setError(request: Request, _ name: String) {
        request.setMessage(name.toLocalizedHtml(), type: .danger)
    }

    func showHome(request: Request) -> Response{
        let home = ContentContainer.instance.contentRoot
        if let controller = ControllerFactory.getDataController(type: home.type) as? ContentController{
            return controller.show(id: home.id, request: request) ?? Response(code: .notFound)
        }
        return Response(code: .notFound)
    }

    func openAdminPage(page: String, request: Request) -> Response {
        request.addPageVar("title", (Configuration.instance.applicationName + " | " + "_administration".localize()).toHtml())
        request.addPageVar("includeUrl", page)
        request.addPageVar("hasUserRights", String(SystemZone.hasUserSystemRight(user: request.user, zone: .user)))
        request.addPageVar("hasContentRights", String(SystemZone.hasUserSystemRight(user: request.user, zone: .contentEdit)))
        return ForwardResponse(page: "administration/adminMaster", request: request)
    }

    func showUserAdministration(request: Request) -> Response {
        openAdminPage(page: "administration/userAdministration", request: request)
    }

    func showContentAdministration(request: Request) -> Response {
        return openAdminPage(page: "administration/contentAdministration", request: request)
    }

    func showContentAdministration(contentId: Int, request: Request) -> Response {
        request.setParam("contentId", contentId)
        return showContentAdministration(request: request)
    }

}
