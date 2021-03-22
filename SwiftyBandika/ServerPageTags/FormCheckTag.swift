//
// Created by Michael Rönnau on 27.02.21.
//

import Foundation

class FormCheckTag: ServerPageTag {

    override class var type: TagType {
        .spgFormCheck
    }

    var name = ""
    var value = ""
    var checked = false

    static var checkPreHtml =
            """
            <span>
                <input type="checkbox" name="{{name}}" value="{{value}}" {{checked}}/>
                <label class="form-check-label">
            """

    func getPreHtml() -> String{
        FormCheckTag.checkPreHtml
    }

    static var postHtml =
            """
                </label>
            </span>
            """

    override func getHtml(request: Request) -> String {
        name = getStringAttribute("name", request)
        value = getStringAttribute("value", request)
        checked = getBoolAttribute("checked", request)
        var html = getStartHtml(request: request)
        html.append(getChildHtml(request: request))
        html.append(getEndHtml(request: request))
        return html
    }

    override func getStartHtml(request: Request) -> String {
        var html = ""
        html.append(getPreHtml().format([
            "name": name.toHtml(),
            "value": value.toHtml(),
            "checked": checked ? "checked" : ""
        ]))
        return html
    }

    override func getEndHtml(request: Request) -> String {
        var html = ""
        html.append(FormCheckTag.postHtml)
        return html
    }

    static func getCheckHtml(name: String, value: String, label: String, checked: Bool) -> String{
        var html = checkPreHtml.format([
            "name": name.toHtml(),
            "value": value.toHtml(),
            "checked": checked ? "checked" : ""])
        html.append(label.toHtml())
        html.append(FormCheckTag.postHtml)
        html.append("<br/>")
        return html
    }

}