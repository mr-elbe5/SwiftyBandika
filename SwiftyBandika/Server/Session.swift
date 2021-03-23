/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

class Session {

    var sessionId = ""
    var timestamp = Date()
    var user: UserData? = nil
    var attributes = Dictionary<String, Any>()

    init() {
        timestamp = Date()
        sessionId = generateID()
    }

    private static let asciiChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

    private func generateID() -> String {
        String((0..<32).map { _ in
            Session.asciiChars.randomElement()!
        })
    }

    func getAttribute(_ name: String) -> Any? {
        return attributes[name]
    }

    func getAttributeNames() -> Set<String> {
        Set(attributes.keys)
    }

    func setAttribute(_ name: String, value: Any) {
        attributes[name] = value
    }

    func removeAttribute(_ name: String) {
        attributes[name] = nil
    }

}