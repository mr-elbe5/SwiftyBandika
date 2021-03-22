//
// Created by Michael Rönnau on 27.02.21.
//

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