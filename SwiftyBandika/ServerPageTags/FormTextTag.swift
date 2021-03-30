/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

class FormTextTag : FormLineTag{

    override class var type: TagType {
        .spgFormText
    }

    var value = ""
    var maxLength : Int = 0

    override func getPreControlHtml(request: Request) -> String{
        value = getStringAttribute("value", request)
        maxLength = getIntAttribute("maxLength", request, def: 0)
        return """
               <input type="text" id="{{name}}" name="{{name}}" class="form-control" value="{{value}}" {{maxLength}} />
               """.format(language: request.language, [
                    "name" : name,
                    "value" : value,
                    "maxLength" : maxLength > 0 ? "maxlength=\" \(maxLength)\"" : ""]
        )
    }

}