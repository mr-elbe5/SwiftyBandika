//
// Created by Michael Rönnau on 27.02.21.
//

import Foundation

class FormLineTag: ServerPageTag {

    override class var type: TagType {
        .spgFormLine
    }

    var name = ""
    var label = ""
    var required = false
    var padded = false

    override func getHtml(request: Request) -> String {
        name = getStringAttribute("name", request)
        label = getStringAttribute("label", request)
        required = getBoolAttribute("required", request)
        padded = getBoolAttribute("padded", request)
        var html = ""
        html.append(getStartHtml(request: request));
        html.append(getPreControlHtml(request: request))
        html.append(getChildHtml(request: request))
        html.append(getPostControlHtml(request: request))
        html.append(getEndHtml(request: request))
        return html
    }

    override func getStartHtml(request: Request) -> String {
        var html = ""
        html.append("<div class=\"form-group row")
        if request.hasFormErrorField(name) {
            html.append(" error")
        }
        html.append("\">\n")
        if label.isEmpty {
            html.append("<div class=\"col-md-3\"></div>")
        } else {
            html.append("<label class=\"col-md-3 col-form-label\"")
            if !name.isEmpty {
                html.append(" for=\"")
                html.append(name.toHtml())
                html.append("\"")
            }
            html.append(">")
            html.append(label.hasPrefix("_") ? label.toLocalizedHtml() : label.toHtml())
            if (required) {
                html.append(" <sup>*</sup>")
            }
            html.append("</label>\n")
        }
        html.append("<div class=\"col-md-9")
        if padded {
            html.append(" padded")
        }
        html.append("\">\n");
        return html
    }

    override func getEndHtml(request: Request) -> String {
        var html = ""
        html.append("</div></div>")
        return html
    }

    func getPreControlHtml(request: Request) -> String {
        ""
    }

    func getPostControlHtml(request: Request) -> String {
        ""
    }

}