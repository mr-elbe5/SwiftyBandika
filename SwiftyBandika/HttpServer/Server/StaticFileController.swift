/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation


public class StaticFileController: Controller {

    public static var instance = StaticFileController()

    public var basePath = "."
    public var bundle : Bundle? = Bundle.main

    public func processPath(path: String, request: Request) -> Response?{
        if let bundle = bundle{
            Log.debug("loading static bundled file \(path)")
            if let url = bundle.url(forResource: "resources/staticWeb/\(path)", withExtension: nil){
                if let source = try? Data.init(contentsOf: url) {
                    let contentType = MimeType.from(path)
                    Log.debug("mime type is \(contentType)")
                    return Response(data: source, fileName: path.lastPathComponent(), contentType: contentType)
                }
            }
        }
        else if !basePath.isEmpty {
            Log.debug("loading static file \(path)")
            let fullPath = basePath.appendPath(path.makeRelativePath())
            if let data : Data = FileManager.default.contents(atPath: fullPath) {
                let contentType = MimeType.from(path)
                Log.debug("mime type is \(contentType)")
                return Response(data: data, fileName: path.lastPathComponent(), contentType: contentType)
            }
        }
        Log.warn("reading file from \(path) failed")
        return Response(code: .notFound)
    }
    
    public func processLayoutPath(path: String, request: Request) -> Response?{
        var path = path
        path.removeFirst(BandikaRouter.layoutPrefix.count)
        let fullPath = Paths.layoutDirectory.appendPath(path)
        if let data : Data = Files.readFile(path: fullPath){
            let contentType = MimeType.from(fullPath)
            return Response(data: data, fileName: fullPath.lastPathComponent(), contentType: contentType)
        }
        Log.info("reading file from \(fullPath) failed")
        return Response(code: .notFound)
    }

    public func ensureLayout(){
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
