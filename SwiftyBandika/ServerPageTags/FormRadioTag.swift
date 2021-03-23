/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

class FormRadioTag: FormCheckTag {

    override class var type: TagType {
        .spgFormRadio
    }

    static let radioPreHtml =
            """
            <span>
                <input type="radio" name="{{name}}" value="{{value}}" {{checked}}/>
                <label class="form-check-label">
            """

    override func getPreHtml() -> String {
        FormRadioTag.radioPreHtml
    }

    static func getRadioHtml(name: String, value: String, label: String, checked: Bool) -> String{
        var html = radioPreHtml.format([
            "name": name.toHtml(),
            "value": value.toHtml(),
            "checked": checked ? "checked" : ""])
        html.append(label.toHtml())
        html.append(FormCheckTag.postHtml)
        html.append("<br/>")
        return html
    }

}