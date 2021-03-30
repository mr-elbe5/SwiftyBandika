/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

class TemplatePartData: PartData {

    private enum TemplatePartDataCodingKeys: CodingKey {
        case template
        case fields
    }

    var template: String
    var fields: Dictionary<String, PartField>

    override var type: DataType {
        get {
            .templatepart
        }
    }

    override var partType: PartType {
        get {
            .templatepart
        }
    }

    override init() {
        template = ""
        fields = Dictionary<String, PartField>()
        super.init()
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: TemplatePartDataCodingKeys.self)
        template = try values.decodeIfPresent(String.self, forKey: .template) ?? ""
        let dict = try values.decodeIfPresent(Dictionary<String, TypedFieldItem>.self, forKey: .fields) ?? Dictionary<String, TypedFieldItem>()
        fields = dict.toPartArray()
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: TemplatePartDataCodingKeys.self)
        try container.encode(template, forKey: .template)
        let dict = fields.toItemDictionary()
        try container.encode(dict, forKey: .fields)
    }

    override func copyEditableAttributes(from data: TypedData) {
        super.copyEditableAttributes(from: data)
        if let partData = data as? TemplatePartData {
            template = partData.template
            fields.removeAll()
            for key in partData.fields.keys {
                if let field = partData.fields[key] {
                    if let newField = DataFactory.create(type: field.type) as? PartField {
                        newField.copyFixedAttributes(from: field)
                        newField.copyEditableAttributes(from: field)
                        fields[key] = newField
                    }

                }
            }
        }
    }

    override func readRequest(_ request: Request) {
        position = request.getInt(partPositionName, def: -1)
        for field in fields.values {
            field.readRequest(request)
        }
    }

    override func setCreateValues(request: Request) {
        super.setCreateValues(request: request)
        template = request.getString("template")
    }

    func ensureTextField(name: String) -> TextField? {
        if let field = fields[name] as? TextField {
            return field
        }
        let textfield = TextField()
        textfield.name = name
        textfield.partId = id
        fields[name] = textfield
        return textfield
    }

    func ensureHtmlField(name: String) -> HtmlField {
        if let field = fields[name] as? HtmlField {
            return field
        }
        let htmlfield = HtmlField()
        htmlfield.name = name
        htmlfield.partId = id
        fields[name] = htmlfield
        return htmlfield
    }

    override func displayPart(request: Request) -> String {
        var html = ""
        if let partTemplate = TemplateCache.getTemplate(type: TemplateType.part, name: template) {
            request.setPart(self)
            if request.viewType == ViewType.edit {
                html.append("""
                            <div id="{{wrapperId}}" class="partWrapper {{css}}" title="{{title}}">
                            """.format(language: request.language, [
                    "wrapperId": partWrapperId,
                    "css": partTemplate.css.toHtml(),
                    "title": editTitle.toHtml()]
                ))
                html.append(getEditPartHeader(request: request))
            } else {
                html.append("""
                            <div id="{{wrapperId}}" class="partWrapper {{css}}">
                            """.format(language: request.language, [
                    "wrapperId": partWrapperId,
                    "css": partTemplate.css.toHtml()]
                ))
            }
            html.append(partTemplate.getHtml(request: request))
            html.append("</div>")
            request.removePart()
        }
        return html
    }

    override func getNewPartHtml(request: Request) -> String {
        request.viewType = .edit
        var html = displayPart(request: request)
        html.append("""
                    <script type="text/javascript">
                        updatePartEditors($('#{{wrapperId}}'));
                    </script>
                    """.format(language: request.language, [
                        "wrapperId": partWrapperId]))
        return html
    }
}
