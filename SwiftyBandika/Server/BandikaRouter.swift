/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation



public protocol RouterDelegate{
    func getShutdownCode() -> String
    func stopApplication()
}

public class BandikaRouter : Router {

    public static let layoutPrefix = "/layout/"
    public static let filesPrefix = "/files/"
    public static let htmlSuffix = ".html"

    public var delegate : RouterDelegate? = nil
    
    override public func route(_ request: Request) -> Response?{
        let path = rewritePath(requestPath: request.path)
        // *.html
        if path.hasSuffix(BandikaRouter.htmlSuffix) {
            //Log.info("html path: \(path)")
            if let content = ContentContainer.instance.getContent(url: path){
                if let controller = ControllerCache.get(content.type.rawValue){
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
                if let controller = ControllerCache.get(controllerName) {
                    let method = pathSegments[2]
                    var id: Int? = nil
                    if pathSegments.count > 3 {
                        id = Int(pathSegments[3])
                    }
                    return controller.processRequest(method: method, id: id, request: request)
                }
            }
            return Response(code: .notFound)
        }
        // scontent files from files directory
        if path.hasPrefix(BandikaRouter.filesPrefix) {
            return FileController.instance.show(request: request)
        }
        // static layout files from layout directory
        if path.hasPrefix(BandikaRouter.layoutPrefix) {
            return StaticFileController.instance.processLayoutPath(path: path, request: request)
        }
        // shutdown request
        if path.hasPrefix(Router.shutdownPrefix), let delegate = delegate{
            let pathSegments = path.split("/")
            if pathSegments.count > 1 {
                let shutdownCode = pathSegments[1]
                if shutdownCode == delegate.getShutdownCode() {
                    DispatchQueue.global(qos: .userInitiated).async {
                        delegate.stopApplication()
                    }
                    return Response(code: .ok)
                }
                else{
                    Log.warn("shutdown codes don't match")
                    Log.debug("received \(shutdownCode) vs actual \(delegate.getShutdownCode())")
                }
            }
            return Response(code: .badRequest)
        }
        // static files from [resources]/web/
        return StaticFileController.instance.processPath(path: path, request: request)
    }
    
    override public func rewritePath(requestPath: String) -> String{
        switch requestPath{
        case "": fallthrough
        case "/": return "/home.html"
        default:
            return requestPath
        }
    }
    
}
