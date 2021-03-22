//
//  AdminController.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 08.02.21.
//

import Foundation

class AdminController: Controller {

    static var instance = AdminController()

    override class var type: ControllerType {
        get {
            .admin
        }
    }

    override func processRequest(method: String, id: Int?, request: Request) -> Response? {
        switch method {
        case "openUserAdministration": return openUserAdministration(request: request)
        case "openContentAdministration": return openContentAdministration(request: request)
        default:
            return nil
        }
    }

    func openUserAdministration(request: Request) -> Response {
        if !SystemZone.hasUserAnySystemRight(user: request.user){ return Response(code: .forbidden)}
        return showUserAdministration(request: request)
    }

    func openContentAdministration(request: Request) -> Response {
        if !SystemZone.hasUserAnySystemRight(user: request.user){ return Response(code: .forbidden)}
        return showContentAdministration(request: request)
    }

}
