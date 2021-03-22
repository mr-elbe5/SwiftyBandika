//
// Created by Michael Rönnau on 27.02.21.
//

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
        return FormSelectTag.preControlHtml.format([
            "name" : name,
            "onchange" : onChange.isEmpty ? "" : "onchange=\"\(onChange)\""]
        )
    }

    override func getPostControlHtml(request: Request) -> String{
        FormSelectTag.postControlHtml
    }

    static func getOptionHtml(value: String, isSelected: Bool, text: String) -> String{
        """
        <option value="{{value}}" {{isSelected}}>{{text}}</option>
        """.format([
            "value" : value,
            "isSelected": isSelected ? "selected" : "",
            "text": text
        ])
    }

}