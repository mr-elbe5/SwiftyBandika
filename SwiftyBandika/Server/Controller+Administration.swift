//
// Created by Michael Rönnau on 07.04.21.
//

import Foundation


extension Controller{

    public func showHome(request: Request) -> Response{
        let home = ContentContainer.instance.contentRoot
        if let controller = ControllerCache.get(home.type.rawValue) as? ContentController{
            return controller.show(id: home.id, request: request) ?? Response(code: .notFound)
        }
        return Response(code: .notFound)
    }

    public func openAdminPage(path: String, request: Request) -> Response {
        request.addPageString("title", (Configuration.instance.applicationName + " | " + "_administration".localize(language: request.language)).toHtml())
        request.addPageString("includeUrl", path)
        request.addPageBool("hasUserRights", SystemZone.hasUserSystemRight(user: request.user, zone: .user))
        request.addPageBool("hasContentRights", SystemZone.hasUserSystemRight(user: request.user, zone: .contentEdit))
        return ForwardResponse(path: "administration/adminMaster", request: request)
    }

    public func showUserAdministration(request: Request) -> Response {
        openAdminPage(path: "administration/userAdministration", request: request)
    }

    public func showContentAdministration(request: Request) -> Response {
        openAdminPage(path: "administration/contentAdministration", request: request)
    }

    public func showContentAdministration(contentId: Int, request: Request) -> Response {
        request.setParam("contentId", contentId)
        return showContentAdministration(request: request)
    }

}
