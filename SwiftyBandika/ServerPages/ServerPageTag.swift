/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

class ServerPageTag: ServerPageNode {

    var tagName: String = ""
    var attributes: [String: String] = [:]
    var childNodes = [ServerPageNode]()

    class var type: TagType {
        .spg
    }

    override func getHtml(request: Request) -> String {
        var s = ""
        s.append(getStartHtml(request: request))
        s.append(getChildHtml(request: request))
        s.append(getEndHtml(request: request))
        return s
    }

    func getStartHtml(request: Request) -> String {
        ""
    }

    func getChildHtml(request: Request) -> String {
        var s = ""
        for child in childNodes {
            s.append(child.getHtml(request: request))
        }
        return s
    }

    func getEndHtml(request: Request) -> String {
        ""
    }

    func getStringAttribute(_ name: String, _ request: Request, def: String = "") -> String {
        if let value = attributes[name] {
            return value.format(request.pageVars)
        }
        return def
    }

    func getIntAttribute(_ name: String, _ request: Request, def: Int = 0) -> Int {
        Int(getStringAttribute(name, request)) ?? def
    }

    func getBoolAttribute(_ name: String, _ request: Request) -> Bool {
        Bool(getStringAttribute(name, request)) == true
    }

}