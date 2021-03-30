/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

class FormEditorTag : FormLineTag{

    override class var type: TagType {
        .spgFormEditor
    }

    var type = "text"
    var hint = ""
    var height = ""

    override func getPreControlHtml(request: Request) -> String{
        type = getStringAttribute("type", request, def: "text")
        hint = getStringAttribute("hint", request)
        height = getStringAttribute("height", request)
        return """
               <textarea id="{{name}}" name="{{name}}" data-editor="{{type}}" data-gutter="1" {{height}}>
               """.format(language: request.language, [
                    "name" :  name,
                    "type" : type,
                    "height" : height.isEmpty ? "" : "style=\"height:\(height)\""]
        )
    }

    override func getPostControlHtml(request: Request) -> String{
        """
                </textarea>
                <small id="{{name}}Hint" class="form-text text-muted">{{hint}}</small>
        """.format(language: request.language, [
                "name" : name,
                "hint" : hint.hasPrefix("_") ? hint.toLocalizedHtml(language: request.language) : hint.toHtml()]
        )
    }

}