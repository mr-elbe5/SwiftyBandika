/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation



public class FormRadioTag: FormCheckTag {

    override public class var type: TagType {
        "radio"
    }

    public static let radioPreHtml =
            """
            <span>
                <input type="radio" name="{{name}}" value="{{value}}" {{checked}}/>
                <label class="form-check-label">
            """

    override public func getPreHtml() -> String {
        FormRadioTag.radioPreHtml
    }

    public static func getRadioHtml(request: Request, name: String, value: String, label: String, checked: Bool) -> String{
        var html = radioPreHtml.replacePlaceholders(language: request.language, [
            "name": name.toHtml(),
            "value": value.toHtml(),
            "checked": checked ? "checked" : ""])
        html.append(label.toHtml())
        html.append(FormCheckTag.postHtml)
        html.append("<br/>")
        return html
    }

}

public class FormRadioTagCreator : TagCreator{
    public func create() -> PageTag{
        FormRadioTag()
    }
}
