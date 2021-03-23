/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

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