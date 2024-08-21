/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation



public class FormCheckTag: PageTag {

    override public class var type: TagType {
        "check"
    }

    public var name = ""
    public var value = ""
    public var checked = false

    public static var checkPreHtml =
            """
            <span>
                <input type="checkbox" name="{{name}}" value="{{value}}" {{checked}}/>
                <label class="form-check-label">
            """

    public func getPreHtml() -> String{
        FormCheckTag.checkPreHtml
    }

    public static var postHtml =
            """
                </label>
            </span>
            """

    override public func getHtml(request: Request) -> String {
        name = getStringAttribute("name", request)
        value = getStringAttribute("value", request)
        checked = getBoolAttribute("checked", request)
        var html = getStartHtml(request: request)
        html.append(getChildHtml(request: request))
        html.append(getEndHtml(request: request))
        return html
    }

    override public func getStartHtml(request: Request) -> String {
        var html = ""
        html.append(getPreHtml().replacePlaceholders(language: request.language, [
            "name": name.toHtml(),
            "value": value.toHtml(),
            "checked": checked ? "checked" : ""
        ]))
        return html
    }

    override public func getEndHtml(request: Request) -> String {
        var html = ""
        html.append(FormCheckTag.postHtml)
        return html
    }

    public static func getCheckHtml(request: Request, name: String, value: String, label: String, checked: Bool) -> String{
        var html = checkPreHtml.replacePlaceholders(language: request.language, [
            "name": name.toHtml(),
            "value": value.toHtml(),
            "checked": checked ? "checked" : ""])
        html.append(label.toHtml())
        html.append(FormCheckTag.postHtml)
        html.append("<br/>")
        return html
    }

}

public class FormCheckTagCreator : TagCreator{
    public func create() -> PageTag{
        FormCheckTag()
    }
}
