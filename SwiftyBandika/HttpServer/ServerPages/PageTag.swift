/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation


open class PageTag: PageNode {

    public var tagName: String = ""
    public var attributes: [String: String] = [:]
    public var childNodes = [PageNode]()

    open class var type: TagType {
        "unknown"
    }

    override open func getHtml(request: Request) -> String {
        var s = ""
        s.append(getStartHtml(request: request))
        s.append(getChildHtml(request: request))
        s.append(getEndHtml(request: request))
        return s
    }

    open func getStartHtml(request: Request) -> String {
        ""
    }

    open func getChildHtml(request: Request) -> String {
        var s = ""
        for child in childNodes {
            s.append(child.getHtml(request: request))
        }
        return s
    }

    open func getEndHtml(request: Request) -> String {
        ""
    }

    public func getStringAttribute(_ name: String, _ request: Request, def: String = "") -> String {
        if let value = attributes[name] {
            return value.replacePlaceholders(language: request.language, request.pageParams)
        }
        return def
    }

    public func getIntAttribute(_ name: String, _ request: Request, def: Int = 0) -> Int {
        Int(getStringAttribute(name, request)) ?? def
    }

    public func getBoolAttribute(_ name: String, _ request: Request) -> Bool {
        Bool(getStringAttribute(name, request)) == true
    }

}
