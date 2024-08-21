/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation


public class ServerPageController : Controller{

    public static var instance = ServerPageController()

    public var basePath = ""
    public var bundle : Bundle? = Bundle.main

    public func processPage(path: String, request: Request) -> String? {
        Log.debug("processing page \(path)")
        let page = ServerPage(path: path)
        if loadPage(page: page) {
            return page.getHtml(request: request)
        }
        return nil
    }

    public func loadPage(page: ServerPage) -> Bool{
        if let bundle = bundle{
            if let url = bundle.url(forResource: "resources/serverPages/\(page.path)", withExtension: "shtml"), let source = try? String(contentsOf: url){
                Log.debug("parsing bundled page \(url.path)")
                return page.parse(source: source)
            }
        }
        else if !basePath.isEmpty {
            let path = basePath.appendPath(page.path + ".shtml")
            Log.debug("loading page \(path)")
            if FileManager.default.fileExists(atPath: path), let url = path.toFileUrl(), let source = try? String(contentsOf: url, encoding: .utf8) {
                Log.debug("parsing page \(path)")
                return page.parse(source: source)
            }
        }
        Log.warn("reading server page from \(page.path) failed")
        return false
    }
    
}
