/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

public class Session {

    public var sessionId = ""
    public var timestamp = Date()
    public var attributes = Dictionary<String, Any>()

    public init() {
        timestamp = Date()
    }

    public func getAttribute(_ name: String) -> Any? {
        return attributes[name]
    }

    public func getAttributeNames() -> Set<String> {
        Set(attributes.keys)
    }

    public func setAttribute(_ name: String, value: Any) {
        attributes[name] = value
    }

    public func removeAttribute(_ name: String) {
        attributes[name] = nil
    }

}