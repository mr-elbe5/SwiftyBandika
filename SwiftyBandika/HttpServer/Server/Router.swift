/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation


open class Router {

    public static let controllerPrefix = "/ctrl/"
    public static let ajaxPrefix = "/ajax/"
    public static let shutdownPrefix = "/shutdown/"
    
    public var shutdownCode: String = Router.generateShutdownCode()

    public init(){
    }

    open func route(_ request: Request) -> Response? {
        let path = rewritePath(requestPath: request.path)
        // controllers
        if path.hasPrefix(Router.controllerPrefix) || path.hasPrefix(Router.ajaxPrefix) {
            Log.debug("routing for controller")
            let pathSegments = path.split("/")
            if pathSegments.count > 2 {
                let controllerType = pathSegments[1]
                Log.debug("type is \(controllerType)")
                if let controller = ControllerCache.get(controllerType) {
                    let method = pathSegments[2]
                    Log.debug("method is \(method)")
                    var id: Int? = nil
                    if pathSegments.count > 3 {
                        id = Int(pathSegments[3])
                        Log.debug("id is \(id ?? 0)")
                    }
                    return controller.processRequest(method: method, id: id, request: request)
                }
            }
            return Response(code: .notFound)
        }
        // shutdown request
        if path.hasPrefix(Router.shutdownPrefix) {
            let pathSegments = path.split("/")
            if pathSegments.count > 1 {
                let shutdownCode = pathSegments[1]
                if shutdownCode == self.shutdownCode {
                    DispatchQueue.global(qos: .userInitiated).async {
                        HttpServer.instance.stop()
                    }
                    return Response(code: .ok)
                } else {
                    Log.warn("shutdown codes don't match")
                }
            }
            return Response(code: .badRequest)
        }
        // static files
        Log.debug("routing for static file")
        return StaticFileController.instance.processPath(path: path, request: request)
    }

    open func rewritePath(requestPath: String) -> String {
        return requestPath
    }
    
    public static func generateShutdownCode() -> String {
        String.generateRandomString(length: 16)
    }

}
