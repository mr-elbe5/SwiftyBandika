//
// Created by Michael Rönnau on 25.02.21.
//

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