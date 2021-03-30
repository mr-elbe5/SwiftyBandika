/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

class FormSelectTag : FormLineTag{

    override class var type: TagType {
        .spgFormSelect
    }

    var onChange = ""

    static let preControlHtml =
            """
            <select id="{{name}}" name="{{name}}" class="form-control" {{onchange}}>
            """

    static let postControlHtml =
            """
            </select>
            """

    override func getPreControlHtml(request: Request) -> String{
        onChange = getStringAttribute("onchange", request)
        return FormSelectTag.preControlHtml.format(language: request.language, [
            "name" : name,
            "onchange" : onChange.isEmpty ? "" : "onchange=\"\(onChange)\""]
        )
    }

    override func getPostControlHtml(request: Request) -> String{
        FormSelectTag.postControlHtml
    }

    static func getOptionHtml(request: Request, value: String, isSelected: Bool, text: String) -> String{
        """
        <option value="{{value}}" {{isSelected}}>{{text}}</option>
        """.format(language: request.language, [
            "value" : value,
            "isSelected": isSelected ? "selected" : "",
            "text": text
        ])
    }

}