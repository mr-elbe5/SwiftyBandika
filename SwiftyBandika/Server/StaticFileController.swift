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
        let fullPath = Paths.webDirectory.appendPath(path.makeRelativePath())
        if let data : Data = Files.readFile(path: fullPath){
            let contentType = fullPath.mimeType()
            return Response(data: data, fileName: fullPath.lastPathComponent(), contentType: contentType)
        }
        Log.info("reading file from \(fullPath) failed")
        return Response(code: .notFound)
    }

    func processLayoutPath(path: String, request: Request) -> Response?{
        //Log.info("loading static file \(path)")
        var path = path
        path.removeFirst(Router.layoutPrefix.count)
        let fullPath = Paths.layoutDirectory.appendPath(path)
        if let data : Data = Files.readFile(path: fullPath){
            let contentType = fullPath.mimeType()
            return Response(data: data, fileName: fullPath.lastPathComponent(), contentType: contentType)
        }
        Log.info("reading file from \(fullPath) failed")
        return Response(code: .notFound)
    }

    func ensureLayout(){
        if Files.directoryIsEmpty(path: Paths.layoutDirectory) {
            for sourcePath in Files.listAllFiles(dirPath: Paths.defaultLayoutDirectory){
                let targetPath = Paths.layoutDirectory.appendPath(sourcePath.lastPathComponent())
                if !Files.copyFile(from: sourcePath, to: targetPath){
                    Log.error("could not copy layout file \(sourcePath)")
                }
            }
        }
    }
    
}
