//
// Created by Michael Rönnau on 02.03.21.
//

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