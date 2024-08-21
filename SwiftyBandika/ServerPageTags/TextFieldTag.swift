/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation



public class TextFieldTag: PageTag {

    override public class var type: TagType {
        "textfield"
    }

    public var text = ""

    override public func getHtml(request: Request) -> String {
        var html = ""
        if let partData = request.getPart(type: TemplatePartData.self) {
            if let field = partData.ensureTextField(name: tagName) {
                let editMode = request.viewType == ViewType.edit
                if (editMode) {
                    let rows = Int(attributes["rows"] ?? "1") ?? 1
                    if (rows > 1) {
                        html.append("""
                                   <textarea class="editField" name="{{identifier}}" rows="{{rows}}">{{content}}</textarea>
                                   """.replacePlaceholders(language: request.language, [
                                    "identifier": field.identifier.toHtml(),
                                    "rows": String(rows),
                                    "content": (field.content.isEmpty ? text : field.content).toHtml()]))
                    } else {
                        html.append("""
                                    <input type="text" class="editField" name="{{identifier}}" placeholder="{{identifier}}" value="{{content}}" />
                                    """.replacePlaceholders(language: request.language, [
                                        "identifier": field.identifier.toHtml(),
                                        "content": (field.content.isEmpty ? text : field.content).toHtml()]))
                    }
                } else {
                    if field.content.isEmpty {
                        html.append("&nbsp;");
                    } else {
                        html.append(field.content.toHtml())
                    }
                }
            }
        }
        return html
    }

}

public class TextFieldTagCreator : TagCreator{
    public func create() -> PageTag{
        TextFieldTag()
    }
}
