/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

class StaticFileController: Controller {
    
    static var instance = StaticFileController()
    
    func processPath(path: String, request: Request) -> Response?{
        //Log.info("loading static file \(path)")
        let fullURL = URL(fileURLWithPath: path.removeLeadingSlash(), relativeTo: Paths.webDirectory)
        if let data : Data = Files.readFile(url: fullURL){
            let contentType = fullURL.path.mimeType()
            return Response(data: data, contentType: contentType)
        }
        Log.info("reading file from \(fullURL.absoluteURL) failed")
        return Response(code: .notFound)
    }

    func processLayoutPath(path: String, request: Request) -> Response?{
        //Log.info("loading static file \(path)")
        var path = path
        path.removeFirst(Router.layoutPrefix.count)
        let fullURL = URL(fileURLWithPath: path, relativeTo: Paths.layoutDirectory)
        if let data : Data = Files.readFile(url: fullURL){
            let contentType = fullURL.path.mimeType()
            return Response(data: data, contentType: contentType)
        }
        Log.info("reading file from \(fullURL.absoluteURL) failed")
        return Response(code: .notFound)
    }

    func ensureLayout(){
        if Files.directoryIsEmpty(url: Paths.layoutDirectory) {
            for sourceUrl in Files.listAllURLs(dirURL: Paths.defaultLayoutDirectory){
                let targetUrl = URL(fileURLWithPath: sourceUrl.lastPathComponent, relativeTo: Paths.layoutDirectory)
                if !Files.copyFile(fromURL: sourceUrl, toURL: targetUrl){
                    Log.error("could not copy layout file \(sourceUrl.path)")
                }
            }
        }
    }
    
}
