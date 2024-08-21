/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation



public class FormTextAreaTag: FormLineTag {

    override public class var type: TagType {
        "textarea"
    }

    public var height = ""
    public var value = ""

    override public func getPreControlHtml(request: Request) -> String {
        height = getStringAttribute( "height", request)
        value = getStringAttribute("value", request)
        return """
               <textarea id="{{name}}" name="{{name}}" class="form-control" {{value}}>
               """.replacePlaceholders(language: request.language, [
                    "name": name,
                    "height": height.isEmpty ? "" : "style=\"height:\(height)\"",
                    "value": value]
        )
    }

    override public func getPostControlHtml(request: Request) -> String {
        """
        </textarea>
        """
    }

}

public class FormTextAreaTagCreator : TagCreator{
    public func create() -> PageTag{
        FormTextAreaTag()
    }
}
