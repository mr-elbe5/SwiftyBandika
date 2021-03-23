/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

struct Router {

    static let controllerPrefix = "/ctrl/"
    static let ajaxPrefix = "/ajax/"
    static let layoutPrefix = "/layout/"
    static let filesPrefix = "/files/"
    static let htmlSuffix = ".html"
    
    static var instance = Router()
    
    func route(_ request: Request) -> Response?{
        let path = rewritePath(requestPath: request.path)
        // *.html
        if path.hasSuffix(Router.htmlSuffix) {
            //Log.info("html path: \(path)")
            if let content = ContentContainer.instance.getContent(url: path){
                if let controller = ControllerFactory.getDataController(type: content.type){
                    return controller.processRequest(method: "show", id: content.id, request: request)
                }
            }
            return Response(code: .notFound)
        }
        // controllers
        if path.hasPrefix(Router.controllerPrefix) || path.hasPrefix(Router.ajaxPrefix) {
            let pathSegments = path.split("/")
            //Log.info("controller path: \(String(describing: pathSegments))")
            if pathSegments.count > 2 {
                let controllerName = pathSegments[1]
                if let controllerType = ControllerType.init(rawValue: controllerName) {
                    if let controller = ControllerFactory.getController(type: controllerType) {
                        let method = pathSegments[2]
                        var id: Int? = nil
                        if pathSegments.count > 3 {
                            id = Int(pathSegments[3])
                        }
                        return controller.processRequest(method: method, id: id, request: request)
                    }
                }
            }
            return Response(code: .notFound)
        }
        // scontent files from files directory
        if path.hasPrefix(Router.filesPrefix) {
            return FileController.instance.show(request: request)
        }
        // static layout files from layout directory
        if path.hasPrefix(Router.layoutPrefix) {
            return StaticFileController.instance.processLayoutPath(path: path, request: request)
        }
        // static files from [resources]/web/
        return StaticFileController.instance.processPath(path: path, request: request)
    }
    
    func rewritePath(requestPath: String) -> String{
        switch requestPath{
        case "": fallthrough
        case "/": return "/home.html"
        default:
            return requestPath
        }
    }
    
}
