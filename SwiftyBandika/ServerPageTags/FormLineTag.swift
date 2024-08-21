/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation



public class FormLineTag: PageTag {

    override public class var type: TagType {
        "line"
    }

    public var name = ""
    public var label = ""
    public var required = false
    public var padded = false

    override public func getHtml(request: Request) -> String {
        name = getStringAttribute("name", request)
        label = getStringAttribute("label", request)
        required = getBoolAttribute("public required", request)
        padded = getBoolAttribute("padded", request)
        var html = ""
        html.append(getStartHtml(request: request));
        html.append(getPreControlHtml(request: request))
        html.append(getChildHtml(request: request))
        html.append(getPostControlHtml(request: request))
        html.append(getEndHtml(request: request))
        return html
    }

    override public func getStartHtml(request: Request) -> String {
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
            html.append(label.hasPrefix("_") ? label.toLocalizedHtml(language: request.language) : label.toHtml())
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

    override public func getEndHtml(request: Request) -> String {
        var html = ""
        html.append("</div></div>")
        return html
    }

    public func getPreControlHtml(request: Request) -> String {
        ""
    }

    public func getPostControlHtml(request: Request) -> String {
        ""
    }

}

public class FormLineTagCreator : TagCreator{
    public func create() -> PageTag{
        FormLineTag()
    }
}
