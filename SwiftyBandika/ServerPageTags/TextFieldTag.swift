//
//  SPTextFieldTag.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 15.02.21.
//

import Foundation

class TextFieldTag: ServerPageTag {

    override class var type: TagType {
        .spgTextField
    }

    var text = ""

    override func getHtml(request: Request) -> String {
        var html = ""
        if let partData = request.getPart(type: TemplatePartData.self) {
            if let field = partData.ensureTextField(name: tagName) {
                let editMode = request.viewType == ViewType.edit
                if (editMode) {
                    let rows = Int(attributes["rows"] ?? "1") ?? 1
                    if (rows > 1) {
                        html.append("""
                                   <textarea class="editField" name="{{identifier}}" rows="{{rows}}">{{content}}</textarea>
                                   """.format([
                                    "identifier": field.identifier.toHtml(),
                                    "rows": String(rows),
                                    "content": (field.content.isEmpty ? text : field.content).toHtml()]))
                    } else {
                        html.append("""
                                    <input type="text" class="editField" name="{{identifier}}" placeholder="{{identifier}}" value="{{content}}" />
                                    """.format([
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
